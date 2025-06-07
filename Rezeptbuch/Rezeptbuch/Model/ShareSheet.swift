//
//  ShareSheet.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 03.05.24.
//

import Foundation
import PDFKit
import SwiftUI
import UIKit
/// Ein Wrapper für den `UIActivityViewController`, um Inhalte (z. B. Dateien, Bilder, Texte) zu teilen.
/// Kann in SwiftUI als `.sheet` verwendet werden.
struct ShareSheet: UIViewControllerRepresentable {
    /// Die Inhalte, die geteilt werden sollen (z. B. `URL`, `UIImage`, `String` usw.)
    var activityItems: [Any]

    /// Erstellt den View Controller für das Teilen
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // 🛠 Optional: Ausschluss bestimmter Aktionen (z. B. Lesezeichen, Kontakte)
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact
        ]

        return controller
    }

    /// Wird verwendet, um den View Controller zu aktualisieren (hier nicht nötig)
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Kein dynamisches Update notwendig
    }
}

/// Eine View, die einen Button darstellt, über den ein Rezept als PDF oder .recipe-Datei exportiert und geteilt werden kann.
struct ShareSheetView: View {
    var recipe: Recipe // Das zu exportierende Rezept

    @State private var showingActionSheet = false // Zeigt die Auswahl für das Dateiformat (PDF vs. recipe)
    @State private var showingShareSheet = false // Steuert das Anzeigen des UIActivityViewControllers
    @State private var selectedFileURL: URL? // Temporär gesetzte URL der zu teilenden Datei
    @State private var errorMessage: String? // Optional: Fehlermeldung

    var body: some View {
        // 📤 Share-Button mit Symbol
        Button(action: {
            showingActionSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 24))
                .foregroundColor(.blue)
        }
        .buttonStyle(PlainButtonStyle()) // Kein extra Button-Styling

        // 📑 Auswahl zwischen PDF oder Plist (Rezeptformat)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Dateiformat wählen"),
                message: Text("Möchtest du das Rezept als PDF oder Rezeptdatei exportieren?"),
                buttons: [
                    .default(Text("Als PDF exportieren")) {
                        exportRecipeAsPDF()
                    },
                    .default(Text("Als Rezeptdatei exportieren")) {
                        exportRecipeAsPlist()
                    },
                    .cancel()
                ]
            )
        }

        // 🟢 Trigger: Sobald `selectedFileURL` gesetzt wird, öffnet sich der Teilen-Sheet automatisch
        .onChange(of: selectedFileURL) { newValue in
            if newValue != nil {
                DispatchQueue.main.async {
                    showingShareSheet = true
                }
            }
        }

        // 📤 Zeigt das Teilen-Menü (ShareSheet), wenn eine Datei vorliegt
        .sheet(item: $selectedFileURL) { fileURL in
            ShareSheet(activityItems: [fileURL])
        }

        // ⚠️ Fehleranzeige als Alert
        .alert(isPresented: Binding<Bool>.constant(errorMessage != nil)) {
            Alert(
                title: Text("Fehler"),
                message: Text(errorMessage ?? "Unbekannter Fehler"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    /// Exportiert das Rezept als PDF-Datei
    private func exportRecipeAsPDF() {
        if let pdfURL = generatePDF(for: recipe) {
            DispatchQueue.main.async {
                selectedFileURL = pdfURL
            }
        } else {
            errorMessage = "PDF-Erstellung fehlgeschlagen."
        }
    }

    /// Exportiert das Rezept als .recipe-Datei (Plist) und bereitet sie für das Teilen vor
    private func exportRecipeAsPlist() {
        // 📦 Exportiere das Rezept als .recipe-Datei
        serializeRecipeToPlist(recipe: recipe) { fileURL, _ in
            if let fileURL = fileURL {
                debugFilePaths() // 📂 Zeige Dateiinhalt im Debug an

                // 🔁 Kopiere die Datei in ein temporäres Verzeichnis zum Teilen
                if let shareableURL = prepareFileForSharing(originalURL: fileURL) {
                    DispatchQueue.main.async {
                        print("🟢 Datei existiert wirklich: \(shareableURL.path)")
                        print("📂 Teste Lesezugriff: \(FileManager.default.isReadableFile(atPath: shareableURL.path))")

                        selectedFileURL = shareableURL
                        showingShareSheet = true
                    }
                } else {
                    errorMessage = "Fehler beim Vorbereiten der Datei für das Teilen."
                }
            } else {
                errorMessage = "Fehler beim Speichern der Rezeptdatei."
            }
        }
    }
}

// extension URL {
//    var queryParameters: [String: String] {
//        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
//            return [:]
//        }
//        guard let queryItems = components.queryItems else { return [:] }
//
//        return queryItems.reduce(into: [String: String]()) { (result, item) in
//            result[item.name] = item.value
//        }
//    }
// }

// ✅ Erweitert URL um Identifiable, damit SwiftUI die sheet-Ansicht erkennt
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

// AppDelegate: Einstiegspunkt für App-Lifecycle und Dateiimport über "Öffnen mit..."
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var contentView: ContentView? // Referenz zur ContentView (für spätere Weitergabe)

    /// Wird aufgerufen, wenn die App über eine Datei geöffnet wird (z. B. über "Öffnen mit...").
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("📂 Datei-Öffnen-Event über AppDelegate erhalten: \(url)")

        // Stelle sicher, dass die Datei asynchron verarbeitet wird (auf dem Main Thread)
        DispatchQueue.main.async {
            self.openRecipeFile(at: url)
        }

        return true
    }

    /// Verarbeitet die übergebene Datei-URL (Plist-basiertes Rezeptformat).
    /// Kopiert die Datei temporär, liest sie ein, deserialisiert das Rezept und schickt es per Notification.
    private func openRecipeFile(at url: URL) {
        print("📂 Datei wird verarbeitet: \(url)")

        // 🔒 Zugriff auf Security-Scoped Resource (z. B. iCloud-Dateien, externe Speicherorte)
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() } // Zugriff wieder freigeben

            do {
                let fileManager = FileManager.default
                let tempDirectory = fileManager.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)

                // Falls Datei bereits im tmp-Verzeichnis existiert, löschen
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                // ✅ Kopiere die Datei ins tmp-Verzeichnis (dort hast du sicheren Zugriff)
                try fileManager.copyItem(at: url, to: destinationURL)
                print("✅ Datei erfolgreich nach: \(destinationURL) kopiert")

                // 📥 Datei einlesen
                let data = try Data(contentsOf: destinationURL)
                print("📂 Dateigröße: \(data.count) Bytes")

                // 🧩 Deserialisiere das Rezept aus der .plist
                if let recipe = deserializePlistToRecipe(plistData: data) {
                    print("🎉 Rezept erfolgreich geladen: \(recipe.title)")

                    // 📬 Benachrichtige z. B. `ContentView` oder andere Komponenten
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .recipeOpened, object: recipe)
                    }
                } else {
                    print("❌ Fehler: Konnte Rezept nicht deserialisieren.")
                }

            } catch {
                print("❌ Fehler beim Kopieren oder Öffnen der Datei: \(error)")
            }

        } else {
            print("❌ Fehler: Kein Zugriff auf die Datei möglich (Security-Scoped Resource)")
        }
    }
}

/// Deserialisiert eine Rezept-Plist-Datei (als `Data`) zurück in ein `Recipe`-Objekt.
/// - Parameter plistData: Die geladene `.recipe`-Datei als Data.
/// - Returns: Ein vollständiges `Recipe`-Objekt oder `nil` bei Fehlern.
func deserializePlistToRecipe(plistData: Data) -> Recipe? {
    do {
        // 🧾 Versuche, das plistData in ein Dictionary umzuwandeln
        if let dict = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
            // 🔑 Basisdaten
            let id = UUID(uuidString: dict["id"] as? String ?? "") ?? UUID()
            let title = dict["title"] as? String ?? ""

            // 📋 Anleitungsschritte – mit Unterstützung für verschiedene Formate (alt & neu)
            var instructions: [InstructionItem] = []
            if let rawInstructions = dict["instructions"] {
                if let array = rawInstructions as? [String] {
                    // 🔹 Sehr altes Format: Nur Texte als Array
                    instructions = array.enumerated().map { index, text in
                        InstructionItem(number: index + 1, text: text, uuids: [])
                    }

                } else if let dict = rawInstructions as? [String: [String]] {
                    // 🔸 Etwas neueres Format: Dictionary (Text → UUID-Array)
                    var items: [InstructionItem] = []
                    var index = 1
                    for (text, uuidStrings) in dict {
                        let uuids = uuidStrings.compactMap { UUID(uuidString: $0) }
                        items.append(InstructionItem(number: index, text: text, uuids: uuids))
                        index += 1
                    }
                    instructions = items.sorted { ($0.number ?? 0) < ($1.number ?? 0) }

                } else if let arrayOfDicts = rawInstructions as? [[String: Any]] {
                    // ✅ Neues Format: Vollständige Dictionaries pro Schritt
                    instructions = arrayOfDicts.compactMap { entry in
                        guard let text = entry["text"] as? String else { return nil }
                        let number = entry["number"] as? Int
                        let uuids = (entry["uuids"] as? [String])?.compactMap(UUID.init) ?? []
                        return InstructionItem(number: number, text: text, uuids: uuids)
                    }.sorted { ($0.number ?? 0) < ($1.number ?? 0) }

                } else {
                    print("❌ 'instructions' hat ein unerwartetes Format: \(type(of: rawInstructions))")
                }
            }

            // 🏷 Tags wiederherstellen
            var tags: [TagStruct] = []
            if let tagArray = dict["tags"] as? [[String: Any]] {
                for tagDict in tagArray {
                    if let idString = tagDict["id"] as? String,
                       let id = UUID(uuidString: idString),
                       let name = tagDict["name"] as? String
                    {
                        tags.append(TagStruct(name: name, id: id))
                    } else {
                        print("⚠️ Fehler beim Parsen eines Tags: \(tagDict)")
                    }
                }
            }

            // 🔗 Weitere optionale Felder
            let videoLink = dict["videoLink"] as? String
            let info = dict["info"] as? String
            let recipeBookIDs = (dict["recipeBookIDs"] as? [String])?.compactMap(UUID.init)

            // 🍽 Portion & 🍰 Kuchen
            let portion: PortionsInfo? = (dict["portion"] as? String).flatMap(PortionsInfo.fromString)
            let cake: CakeInfo? = (dict["cake"] as? String).flatMap(CakeInfo.fromString)

            // 🖼 Bilddaten als Base64 → speichern im App-Support-Verzeichnis
            var imagePath: String?
            if let base64ImageString = dict["imageData"] as? String,
               let imageData = Data(base64Encoded: base64ImageString),
               let image = UIImage(data: imageData)
            {
                let fileManager = FileManager.default
                let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let imageFileURL = applicationSupport.appendingPathComponent("\(id)_import.jpeg")

                do {
                    if !fileManager.fileExists(atPath: applicationSupport.path) {
                        try fileManager.createDirectory(at: applicationSupport, withIntermediateDirectories: true, attributes: nil)
                    }

                    if fileManager.fileExists(atPath: imageFileURL.path) {
                        try fileManager.removeItem(at: imageFileURL)
                    }

                    try imageData.write(to: imageFileURL)
                    imagePath = imageFileURL.path
                    print("✅ Rezeptbild erfolgreich gespeichert: \(imageFileURL.path)")

                } catch {
                    print("❌ Fehler beim Speichern des Rezeptbilds: \(error)")
                }
            } else {
                print("⚠️ Kein Bild vorhanden oder fehlerhafte Base64-Daten")
            }

            // 🧂 Zutaten verarbeiten
            var ingredients = [FoodItemStruct]()
            if let ingredientsArray = dict["ingredients"] as? [[String: Any]] {
                for ingredientDict in ingredientsArray {
                    guard
                        let ingredientIdString = ingredientDict["id"] as? String,
                        let ingredientId = UUID(uuidString: ingredientIdString),
                        let foodDict = ingredientDict["food"] as? [String: Any],
                        let foodIdString = foodDict["id"] as? String,
                        let foodId = UUID(uuidString: foodIdString),
                        let name = foodDict["name"] as? String,
                        let unitString = ingredientDict["unit"] as? String,
                        let unit = Unit(rawValue: unitString),
                        let quantity = ingredientDict["quantity"] as? Double
                    else {
                        print("⚠️ Fehler beim Dekodieren eines Ingredients: \(ingredientDict)")
                        continue
                    }

                    let nutritionFacts = NutritionFactsStruct(
                        calories: (foodDict["nutritionFacts"] as? [String: Any])?["calories"] as? Int ?? 0,
                        protein: (foodDict["nutritionFacts"] as? [String: Any])?["protein"] as? Double ?? 0.0,
                        carbohydrates: (foodDict["nutritionFacts"] as? [String: Any])?["carbohydrates"] as? Double ?? 0.0,
                        fat: (foodDict["nutritionFacts"] as? [String: Any])?["fat"] as? Double ?? 0.0
                    )

                    let food = FoodStruct(
                        id: foodId,
                        name: name,
                        category: foodDict["category"] as? String,
                        density: foodDict["density"] as? Double ?? 0.0,
                        info: foodDict["info"] as? String,
                        nutritionFacts: nutritionFacts
                    )

                    let foodItem = FoodItemStruct(food: food, unit: unit, quantity: quantity, id: ingredientId)
                    ingredients.append(foodItem)
                }
            }

            // ✅ Alle Daten vorhanden → Rezeptobjekt erzeugen
            return Recipe(
                id: id,
                title: title,
                ingredients: ingredients,
                instructions: instructions,
                image: imagePath,
                portion: portion,
                cake: cake,
                videoLink: videoLink,
                info: info,
                tags: tags,
                recipeBookIDs: recipeBookIDs
            )
        }
    } catch {
        print("❌ Fehler beim Parsen der plist: \(error)")
    }

    // Im Fehlerfall: nil zurückgeben
    return nil
}

/// Kopiert eine Datei in das temporäre Verzeichnis, um sie für das Teilen freizugeben (z. B. via UIActivityViewController).
/// - Parameter originalURL: Die Originaldatei, die geteilt werden soll.
/// - Returns: Die URL zur temporären Kopie oder `nil` im Fehlerfall.
private func prepareFileForSharing(originalURL: URL) -> URL? {
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory

    // 📄 Ziel-URL im tmp-Ordner vorbereiten
    var destinationURL = tempDirectory.appendingPathComponent(originalURL.lastPathComponent)

    // 🔍 Prüfen, ob die Originaldatei überhaupt existiert
    guard fileManager.fileExists(atPath: originalURL.path) else {
        print("❌ Fehler: Die Originaldatei existiert nicht! Pfad: \(originalURL.path)")
        return nil
    }

    // 🧹 Falls im tmp-Verzeichnis bereits eine Datei mit dem Namen existiert, löschen
    if fileManager.fileExists(atPath: destinationURL.path) {
        do {
            try fileManager.removeItem(at: destinationURL)
            print("🔄 Alte temporäre Datei gelöscht: \(destinationURL.path)")
        } catch {
            print("❌ Fehler beim Löschen der existierenden Datei: \(error)")
            return nil
        }
    }

    // ✅ Datei aus dem Dokumentenverzeichnis ins temporäre Verzeichnis kopieren
    do {
        try fileManager.copyItem(at: originalURL, to: destinationURL)
        print("✅ Datei erfolgreich kopiert nach: \(destinationURL.path)")

        // 🔒 Datei darf (optional) in Backups aufgenommen werden
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = false
        try destinationURL.setResourceValues(resourceValues)

        // 👥 POSIX-Dateiberechtigungen setzen (für maximalen Zugriff bei externem Teilen)
        try FileManager.default.setAttributes([.posixPermissions: 0o777], ofItemAtPath: destinationURL.path)

        return destinationURL

    } catch {
        print("❌ Fehler beim Kopieren der Datei für das Teilen: \(error)")
        return nil
    }
}

/// Gibt die URL zum Dokumentenverzeichnis der App zurück.
/// Dieses Verzeichnis ist für den Benutzer sichtbar (z. B. über die Dateien-App bei iOS).
/// Hier kannst du eigene Dateien wie `.recipe`, `.pdf` etc. speichern.
func getDocumentsDirectory() -> URL {
    // 🔍 Ruft eine Liste mit Verzeichnissen für `.documentDirectory` ab
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // 📁 Gibt das erste (und einzige) Ergebnis zurück
    return paths[0]
}

/// Debug-Funktion: Gibt alle Dateien im Dokumentenverzeichnis in der Konsole aus.
/// Nützlich zur Kontrolle, ob Dateien korrekt gespeichert wurden.
private func debugFilePaths() {
    let fileManager = FileManager.default
    let documentsDirectory = getDocumentsDirectory() // 📁 Dokumentenordner holen

    do {
        // 📋 Hole alle Dateinamen im Verzeichnis
        let files = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)

        print("📂 Dateien im Dokumentenverzeichnis:")
        for file in files {
            print("- \(file)") // ✅ Gib jede Datei einzeln aus
        }

    } catch {
        // ❌ Fehler beim Lesen des Verzeichnisses
        print("❌ Fehler beim Abrufen der Dateiliste: \(error)")
    }
}

/// Serialisiert ein Rezept als `.plist`-Datei im XML-Format inklusive eingebettetem Base64-Bild.
/// - Parameters:
///   - recipe: Das zu exportierende `Recipe`-Objekt.
///   - completion: Rückgabeschließer mit URL zur gespeicherten Datei oder `nil` im Fehlerfall.
func serializeRecipeToPlist(recipe: Recipe, completion: @escaping (URL?, URL?) -> Void) {
    // 🧱 Grundstruktur des Rezepts als Dictionary
    var dict: [String: Any] = [
        "id": recipe.id.uuidString,
        "title": recipe.title,

        // 🔢 Anleitungsschritte als Array von Dictionaries
        "instructions": recipe.instructions.map { item in
            [
                "number": item.number ?? 0,
                "text": item.text,
                "uuids": item.uuids.map { $0.uuidString }
            ]
        },

        // 🔗 Zusatzinfos
        "videoLink": recipe.videoLink ?? "",
        "info": recipe.info ?? "",

        // 📚 Rezeptbuch-IDs
        "recipeBookIDs": recipe.recipeBookIDs?.map { $0.uuidString } ?? [],

        // 🧂 Zutaten (über Hilfsfunktion)
        "ingredients": serializeIngredients(ingredients: recipe.ingredients),

        // 🏷 Tags
        "tags": recipe.tags?.map {
            ["id": $0.id.uuidString, "name": $0.name]
        } ?? []
    ]

    // 🖼 Bild einbetten (als Base64, wenn vorhanden)
    if let imagePath = recipe.image {
        print("📂 Überprüfe Bildpfad: \(imagePath)")

        let fileManager = FileManager.default
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let imageFileURL = applicationSupport.appendingPathComponent(imagePath)

        if fileManager.fileExists(atPath: imageFileURL.path) {
            // ✅ Bild laden und in Base64 konvertieren
            if let image = UIImage(contentsOfFile: imageFileURL.path),
               let imageData = image.jpegData(compressionQuality: 1.0)
            {
                dict["imageData"] = imageData.base64EncodedString()
                print("✅ Bild erfolgreich in Base64 konvertiert und in Rezept gespeichert")
            } else {
                print("⚠️ Kein Bild vorhanden oder Fehler beim Laden des Bildes")
            }
        } else {
            print("❌ Fehler: Bild konnte nicht geladen werden")
        }
    } else {
        print("⚠️ Kein Bildpfad im Rezept vorhanden")
    }

    // 🍽 Portionen (als lesbarer String, z. B. "2 Portionen")
    if let portion = recipe.portion {
        dict["portion"] = portion.stringValue()
    }

    // 🍰 Kucheninfo (als String, z. B. "rund ∅ 24 cm")
    if let cake = recipe.cake {
        dict["cake"] = cake.stringValue()
    }

    // 📁 Zieldatei vorbereiten
    let fileManager = FileManager.default
    let documentsDirectory = getDocumentsDirectory()
    let fileURL = documentsDirectory.appendingPathComponent("\(recipe.title).recipe")

    do {
        // 📝 Property-List (XML) aus Dictionary generieren
        let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)

        // 🧹 Alte Datei entfernen, falls vorhanden
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("🔄 Alte Rezeptdatei gelöscht: \(fileURL.path)")
        }

        // 💾 Neue Datei speichern
        try data.write(to: fileURL)
        print("✅ Rezept erfolgreich gespeichert: \(fileURL.path)")

        // ✅ Optional nochmal prüfen, ob Datei jetzt wirklich existiert
        if fileManager.fileExists(atPath: fileURL.path) {
            print("📂 Datei wurde erfolgreich gespeichert: \(fileURL.path)")
        } else {
            print("❌ Fehler: Datei wurde NICHT gespeichert!")
        }

        // 🎯 Rückgabe per Completion Handler
        completion(fileURL, fileURL)

    } catch {
        // ❌ Fehlerbehandlung bei Dateischreibvorgang
        print("❌ Fehler beim Speichern der Rezeptdatei: \(error)")
        completion(nil, nil)
    }
}

/// Wandelt eine Liste von `FoodItemStruct`-Zutaten in ein Array von Dictionaries um.
/// Jedes Dictionary enthält die Zutateninformationen inklusive eingebetteter `food`-Daten.
/// Ideal zur JSON-Speicherung oder Datenweitergabe.
///
/// - Parameter ingredients: Eine Liste von `FoodItemStruct`-Objekten (Zutaten)
/// - Returns: Eine Liste von Dictionaries im `[String: Any]`-Format.
func serializeIngredients(ingredients: [FoodItemStruct]) -> [[String: Any]] {
    return ingredients.map { ingredient in
        // 🔁 Serialize das enthaltene `FoodStruct` mit der vorher definierten Funktion
        let foodDict = serializeFood(food: ingredient.food)

        // 🧂 Erzeuge ein Dictionary für die einzelne Zutat
        let ingredientDict: [String: Any] = [
            "food": foodDict, // Eingebettetes Lebensmittel
            "id": ingredient.id.uuidString, // Eindeutige Zutat-ID
            "unit": ingredient.unit.rawValue, // Einheit als String (z. B. "g", "ml")
            "quantity": ingredient.quantity // Mengenangabe
        ]

        // 📦 Gib das Zutatendictionary zurück
        return ingredientDict
    }
}

/// Wandelt ein `FoodStruct`-Objekt in ein Dictionary (`[String: Any]`) um.
/// Ideal für das Speichern, Übertragen (z. B. JSON), oder Serialisieren.
/// - Parameter food: Das Lebensmittelobjekt, das serialisiert werden soll.
/// - Returns: Ein Dictionary mit allen relevanten Feldern.
func serializeFood(food: FoodStruct) -> [String: Any] {
    // 🧱 Haupt-Container für das Lebensmittel
    var foodDict = [String: Any]()

    // 🔑 Basisinformationen
    foodDict["id"] = food.id.uuidString // UUID als String
    foodDict["name"] = food.name // Name
    foodDict["category"] = food.category ?? "" // Kategorie (optional → leerer String)
    foodDict["info"] = food.info ?? "" // Zusatzinfo (optional → leerer String)
    foodDict["density"] = food.density ?? 0 // Dichte (optional → 0)

    // 🧪 Nährwerte (optional)
    var nutritionFactsDict = [String: Any]()
    if let nutritionFacts = food.nutritionFacts {
        nutritionFactsDict["calories"] = nutritionFacts.calories ?? 0
        nutritionFactsDict["protein"] = nutritionFacts.protein ?? 0
        nutritionFactsDict["carbohydrates"] = nutritionFacts.carbohydrates ?? 0
        nutritionFactsDict["fat"] = nutritionFacts.fat ?? 0
    }
    foodDict["nutritionFacts"] = nutritionFactsDict

    // 🏷 Tags (optional) → Liste von Dictionaries mit ID und Name
    if let tags = food.tags {
        foodDict["tags"] = tags.map { tag -> [String: Any] in
            [
                "id": tag.id.uuidString,
                "name": tag.name
            ]
        }
    }

    return foodDict
}

/// Generiert ein PDF-Dokument für das angegebene Rezept.
/// - Parameter recipe: Das Rezept, das exportiert werden soll.
/// - Returns: Die URL zur erzeugten PDF-Datei im Dokumentenverzeichnis, oder `nil` bei Fehler.
func generatePDF(for recipe: Recipe) -> URL? {
    // 📄 Dateiname und Speicherort vorbereiten
    let fileName = "\(recipe.title).pdf"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let pdfURL = documentsDirectory.appendingPathComponent(fileName)

    // 📐 Standardgröße für eine A4-Seite (in Punkten)
    let pageWidth: CGFloat = 612
    let pageHeight: CGFloat = 792
    let margin: CGFloat = 40
    let contentWidth = pageWidth - 2 * margin
    let lineHeight: CGFloat = 20
    var yOffset: CGFloat = 50 // Startposition auf der Seite

    // 📦 PDF-Renderer vorbereiten
    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

    do {
        // 🖨 PDF erzeugen und in Datei schreiben
        try pdfRenderer.writePDF(to: pdfURL, withActions: { context in

            // 👀 Hilfsfunktion: Startet neue Seite, wenn nicht genug Platz
            func checkPageSpace(_ requiredSpace: CGFloat) {
                if yOffset + requiredSpace > pageHeight - margin {
                    context.beginPage()
                    yOffset = margin
                }
            }

            context.beginPage()

            // 🧾 Titel (zentriert, groß, rot)
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.alignment = .center
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .paragraphStyle: titleStyle,
                .foregroundColor: UIColor.systemRed
            ]
            let titleString = NSAttributedString(string: recipe.title, attributes: titleAttributes)
            titleString.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: 30))
            yOffset += 35

            // ➖ Trennlinie
            context.cgContext.setStrokeColor(UIColor.systemGray.cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.move(to: CGPoint(x: margin, y: yOffset))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yOffset))
            context.cgContext.strokePath()
            yOffset += 15

            // 🖼 Bild laden und einfügen (falls vorhanden)
            if let imagePath = recipe.image {
                let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let imageFileURL = applicationSupport.appendingPathComponent(imagePath)

                if FileManager.default.fileExists(atPath: imageFileURL.path),
                   let image = UIImage(contentsOfFile: imageFileURL.path)
                {
                    let maxHeight: CGFloat = 200
                    let aspectRatio = image.size.height / image.size.width
                    var imageWidth = contentWidth
                    var imageHeight = imageWidth * aspectRatio

                    if imageHeight > maxHeight {
                        imageHeight = maxHeight
                        imageWidth = maxHeight / aspectRatio
                    }

                    checkPageSpace(imageHeight + 10)

                    let imageRect = CGRect(
                        x: margin + (contentWidth - imageWidth) / 2,
                        y: yOffset,
                        width: imageWidth,
                        height: imageHeight
                    )

                    image.draw(in: imageRect)
                    yOffset += imageHeight + 15
                }
            }

            // ℹ️ Info-Block: Portion, Form, Tags, Beschreibung, Video-Link
            let leftAlignStyle = NSMutableParagraphStyle()
            leftAlignStyle.alignment = .left

            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .paragraphStyle: leftAlignStyle
            ]

            var infoLines: [String] = []

            // 🍽 Portionen anzeigen
            if recipe.portion != .notPortion {
                if case let .Portion(portionValue) = recipe.portion {
                    infoLines.append("Portionen: \(portionValue)")
                }
            }

            // 🍰 Kuchenmaße anzeigen
            if case let .cake(_, size) = recipe.cake, recipe.cake != .notCake {
                switch size {
                case let .rectangular(length, width):
                    infoLines.append("Rechteckige Form: \(length) x \(width) cm")
                case let .round(diameter):
                    infoLines.append("Runde Form: \(diameter) cm")
                }
            }

            // 🏷 Tags anzeigen
            if let tags = recipe.tags, !tags.isEmpty {
                let tagText = tags.map { $0.name }.joined(separator: ", ")
                infoLines.append("Tags: \(tagText)")
            }

            // 📝 Zusatzinfo
            if let extraInfo = recipe.info, !extraInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                infoLines.append("Info: \(extraInfo)")
            }

            // 🎥 Video-Link anzeigen (falls vorhanden)
            var videoLinkString: NSAttributedString?
            if let link = recipe.videoLink, let url = URL(string: link), !link.isEmpty {
                let linkAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.systemBlue,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .paragraphStyle: leftAlignStyle,
                    .link: url
                ]
                videoLinkString = NSAttributedString(string: "▶ Video ansehen: \(link)", attributes: linkAttributes)
            }

            // 🧱 Info-Block zeichnen (wenn vorhanden)
            if !infoLines.isEmpty || videoLinkString != nil {
                let infoText = infoLines.joined(separator: "\n")
                let infoTextHeight = CGFloat(infoLines.count) * lineHeight + 10

                if !infoLines.isEmpty {
                    let boxRect = CGRect(x: margin - 5, y: yOffset - 5, width: contentWidth + 10, height: infoTextHeight + 10)
                    context.cgContext.setFillColor(UIColor(white: 0.95, alpha: 1.0).cgColor)
                    context.cgContext.fill(boxRect)

                    let infoString = NSAttributedString(string: infoText, attributes: infoAttributes)
                    checkPageSpace(infoTextHeight)
                    infoString.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: infoTextHeight))
                    yOffset += infoTextHeight + 10
                }

                if let videoLinkString = videoLinkString {
                    let estimatedLinkHeight: CGFloat = 25
                    checkPageSpace(estimatedLinkHeight)
                    videoLinkString.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: estimatedLinkHeight))
                    yOffset += estimatedLinkHeight + 10
                }
            }

            // 🧂 Abschnitt "Zutaten"
            let sectionTitleStyle = NSMutableParagraphStyle()
            sectionTitleStyle.alignment = .left
            let sectionTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .paragraphStyle: sectionTitleStyle,
                .foregroundColor: UIColor.systemBlue
            ]

            let ingredientsTitle = NSAttributedString(string: "Zutaten:", attributes: sectionTitleAttributes)
            checkPageSpace(25)
            ingredientsTitle.draw(at: CGPoint(x: margin, y: yOffset))
            yOffset += 25

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: sectionTitleStyle
            ]

            for ingredient in recipe.ingredients {
                let text = "- \(ingredient.food.name) \(ingredient.quantity) \(ingredient.unit.rawValue)"
                let ingredientString = NSAttributedString(string: text, attributes: bodyAttributes)
                checkPageSpace(lineHeight)
                ingredientString.draw(at: CGPoint(x: margin, y: yOffset))
                yOffset += lineHeight
            }

            yOffset += 25

            // 👩‍🍳 Abschnitt "Zubereitung"
            let instructionsTitle = NSAttributedString(string: "Zubereitung:", attributes: sectionTitleAttributes)
            checkPageSpace(25)
            instructionsTitle.draw(at: CGPoint(x: margin, y: yOffset))
            yOffset += 25

            for (index, step) in recipe.instructions.enumerated() {
                let stepText = "\(index + 1). \(step.text)"
                let stepString = NSAttributedString(string: stepText, attributes: bodyAttributes)
                let estimatedHeight: CGFloat = 50
                checkPageSpace(estimatedHeight)
                stepString.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: estimatedHeight))
                yOffset += 40
            }
        })

        return pdfURL
    } catch {
        print("❌ Fehler beim Erzeugen des PDFs: \(error)")
        return nil
    }
}

// extension UIColor {
//    func darker(by percentage: CGFloat = 20.0) -> UIColor {
//        return self.adjust(by: -abs(percentage))
//    }
//
//    func adjust(by percentage: CGFloat = 20.0) -> UIColor {
//        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
//        if getRed(&r, green: &g, blue: &b, alpha: &a) {
//            return UIColor(red: min(r + percentage/100, 1.0),
//                           green: min(g + percentage/100, 1.0),
//                           blue: min(b + percentage/100, 1.0),
//                           alpha: a)
//        }
//        return self
//    }
// }

// Erweiterung des Typs Notification.Name zur Definition eigener Benachrichtigungen
extension Notification.Name {
    /// Eigene Benachrichtigung, die z. B. beim Öffnen eines Rezepts gesendet werden kann.
    /// Verwendung: NotificationCenter.default.post(name: .recipeOpened, object: ...)
    static let recipeOpened = Notification.Name("recipeOpened")
}

// func moveFileToTempDirectory(originalURL: URL) -> URL? {
//    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(originalURL.lastPathComponent)
//    let fileManager = FileManager.default
//
//    do {
//        if fileManager.fileExists(atPath: tempURL.path) {
//            try fileManager.removeItem(at: tempURL)
//        }
//        try fileManager.copyItem(at: originalURL, to: tempURL)
//        print("✅ Datei erfolgreich nach tmp verschoben: \(tempURL.path)")
//        return tempURL
//    } catch {
//        print("❌ Fehler beim Verschieben der Datei: \(error)")
//        return nil
//    }
// }

//
// func setFileAttributes(for url: URL) {
//    var mutableURL = url // URL als veränderbare Variable kopieren
//    var resourceValues = URLResourceValues()
//    resourceValues.isExcludedFromBackup = false // Datei nicht aus iCloud-Backup ausschließen
//    do {
//        try mutableURL.setResourceValues(resourceValues)
//        try FileManager.default.setAttributes([.posixPermissions: 0o777], ofItemAtPath: mutableURL.path)
//        print("🔓 Datei-Berechtigungen wurden aktualisiert")
//    } catch {
//        print("❌ Fehler beim Setzen der Datei-Berechtigungen: \(error)")
//    }
// }

/// Löscht das gespeicherte Bild eines Rezepts anhand seiner ID.
/// - Parameter recipe: Das Rezept, dessen Bild gelöscht werden soll.
func deleteRecipeImage(recipe: Recipe) {
    // Übergibt die UUID des Rezepts als String an die eigentliche Löschfunktion
    deleteImage(id: recipe.id.uuidString)
}

/// Löscht eine Bilddatei mit dem gegebenen Dateinamen (basiert auf UUID) im Application Support-Verzeichnis.
/// - Parameter id: Die ID (als String), die als Dateiname verwendet wird.
func deleteImage(id: String) {
    let fileManager = FileManager.default

    // 📁 Speicherort ermitteln – Application Support-Verzeichnis der App
    let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

    // 🔗 Bildpfad zusammensetzen (z. B. "1234-5678.jpg")
    let imageFileURL = applicationSupport.appendingPathComponent("\(id).jpg")

    // 🔍 Prüfen, ob die Datei existiert
    if fileManager.fileExists(atPath: imageFileURL.path) {
        do {
            // 🗑 Bild löschen
            try fileManager.removeItem(atPath: imageFileURL.path)
            print("✅ Bild erfolgreich gelöscht: \(imageFileURL.path)")
        } catch {
            // ❌ Fehler beim Löschen ausgeben
            print("❌ Fehler beim Löschen der Bilddatei: \(error)")
        }
    } else {
        // ⚠️ Kein Bild vorhanden → Hinweis ausgeben
        print("⚠️ Kein Bild vorhanden zum Löschen: \(imageFileURL.path)")
    }

    // 🧾 Ausgabe des aktuellen Inhalts des Verzeichnisses (Debug-Zweck)
    do {
        let files = try fileManager.contentsOfDirectory(atPath: applicationSupport.path)
        print("📂 Verzeichnisinhalt nach Löschung:")
        for file in files {
            print("- \(file)")
        }
    } catch {
        print("❌ Fehler beim Abrufen des Verzeichnisinhalts: \(error)")
    }
}
