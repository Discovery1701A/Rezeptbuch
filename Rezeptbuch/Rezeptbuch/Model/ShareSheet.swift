//
//  ShareSheet.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 03.05.24.
//

import SwiftUI
import UIKit
import PDFKit
import Foundation

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.excludedActivityTypes = [.addToReadingList, .assignToContact]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareSheetView: View {
    var recipe: Recipe
    @State private var showingActionSheet = false
    @State private var showingShareSheet = false
    @State private var selectedFileURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 24))
                .foregroundColor(.blue)
        }
        .buttonStyle(PlainButtonStyle())
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
        // ✅ Stellt sicher, dass der Teilen-Dialog angezeigt wird, sobald selectedFileURL gesetzt wird
        .onChange(of: selectedFileURL) { newValue in
            if newValue != nil {
                DispatchQueue.main.async {
                    showingShareSheet = true
                }
            }
        }
        // ✅ Sheet wird nur angezeigt, wenn selectedFileURL vorhanden ist
        .sheet(item: $selectedFileURL) { fileURL in
            ShareSheet(activityItems: [fileURL])
        }
        // ✅ Fehler als Alert anzeigen
        .alert(isPresented: Binding<Bool>.constant(errorMessage != nil), content: {
            Alert(title: Text("Fehler"), message: Text(errorMessage ?? "Unbekannter Fehler"), dismissButton: .default(Text("OK")))
        })
    }

    private func exportRecipeAsPDF() {
        if let pdfURL = generatePDF(for: recipe) {
            DispatchQueue.main.async {
                selectedFileURL = pdfURL
            }
        } else {
            errorMessage = "PDF-Erstellung fehlgeschlagen."
        }
    }
    private func exportRecipeAsPlist() {
      

        // 🛠 Stelle sicher, dass das Rezept gespeichert wird
        serializeRecipeToPlist(recipe: recipe) { fileURL, _ in
            if let fileURL = fileURL {
                debugFilePaths() // 🔍 Listet alle Dateien im Verzeichnis auf

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

extension URL {
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return [:]
        }
        guard let queryItems = components.queryItems else { return [:] }

        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

// ✅ Erweitert URL um Identifiable, damit SwiftUI die sheet-Ansicht erkennt
extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}

/// iOS App Delegate - URL Scheme Handling:
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var contentView: ContentView? // Referenz zur ContentView für importedRecipe

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("📂 Datei-Öffnen-Event über AppDelegate erhalten: \(url)")

        DispatchQueue.main.async {
            self.openRecipeFile(at: url)
        }

        return true
    }

    private func openRecipeFile(at url: URL) {
        print("📂 Datei wird verarbeitet: \(url)")

        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let fileManager = FileManager.default
                let tempDirectory = FileManager.default.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)

                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                try fileManager.copyItem(at: url, to: destinationURL)
                print("✅ Datei erfolgreich nach: \(destinationURL) kopiert")

                let data = try Data(contentsOf: destinationURL)
                print("📂 Dateigröße: \(data.count) Bytes")

                if let recipe = deserializePlistToRecipe(plistData: data) {
                    print("🎉 Rezept erfolgreich geladen: \(recipe.title)")

                    // 📌 Rezept NUR temporär speichern und an ContentView übergeben
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

func deserializePlistToRecipe(plistData: Data) -> Recipe? {
    do {
        if let dict = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
            let id = UUID(uuidString: dict["id"] as? String ?? "") ?? UUID()
            let title = dict["title"] as? String ?? ""
            let instructions = dict["instructions"] as? [String] ?? []
            let videoLink = dict["videoLink"] as? String
            let info = dict["info"] as? String
            let recipeBookIDs = (dict["recipeBookIDs"] as? [String])?.compactMap(UUID.init)

            let portion: PortionsInfo? = dict["portion"] as? String != nil ? PortionsInfo.fromString(dict["portion"] as! String) : nil
            let cake: CakeInfo? = dict["cake"] as? String != nil ? CakeInfo.fromString(dict["cake"] as! String) : nil

            var imagePath: String? = nil
                        if let base64ImageString = dict["imageData"] as? String {
                            if let imageData = Data(base64Encoded: base64ImageString) {
                                print("ud83dudcf8 Bild-Daten erfolgreich decodiert (Größe: \(imageData.count) Bytes)")
                                if let image = UIImage(data: imageData) {
                                    let fileManager = FileManager.default
                                    let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                                    let imageFileURL = applicationSupport.appendingPathComponent("\(id)_import.jpeg")

                                    do {
                                        // Erstelle das Verzeichnis falls es nicht existiert
                                        if !fileManager.fileExists(atPath: applicationSupport.path) {
                                            try fileManager.createDirectory(at: applicationSupport, withIntermediateDirectories: true, attributes: nil)
                                        }

                                        // Falls eine alte Datei existiert, löschen
                                        if fileManager.fileExists(atPath: imageFileURL.path) {
                                            try fileManager.removeItem(at: imageFileURL)
                                        }

                                        // Speichere das neue Bild
                                        try imageData.write(to: imageFileURL)
                                        print("✅ Rezeptbild erfolgreich gespeichert: \(imageFileURL.path)")
                                        imagePath = imageFileURL.path
                                    } catch {
                                        print("❌ Fehler beim Speichern des Rezeptbilds: \(error)")
                                    }
                                } else {
                                    print("❌ Fehler: UIImage konnte nicht aus den Bilddaten erstellt werden")
                                }
                            } else {
                                print("❌ Fehler: Base64-Daten konnten nicht in `Data` konvertiert werden")
                            }
                        } else {
                            print("⚠️ Kein `imageData` Eintrag in der Rezeptdatei gefunden")
                        }

            var ingredients = [FoodItemStruct]()
            if let ingredientsArray = dict["ingredients"] as? [[String: Any]] {
                for ingredientDict in ingredientsArray {
                    guard let ingredientIdString = ingredientDict["id"] as? String,
                          let ingredientId = UUID(uuidString: ingredientIdString),
                          let foodDict = ingredientDict["food"] as? [String: Any],
                          let foodIdString = foodDict["id"] as? String,
                          let foodId = UUID(uuidString: foodIdString),
                          let name = foodDict["name"] as? String,
                          let unitString = ingredientDict["unit"] as? String,
                          let unit = Unit(rawValue: unitString),
                          let quantity = ingredientDict["quantity"] as? Double else {
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

            return Recipe(id: id, title: title, ingredients: ingredients, instructions: instructions, image: imagePath, portion: portion, cake: cake, videoLink: videoLink, info: info, tags: [], recipeBookIDs: recipeBookIDs)
        }
    } catch {
        print("Error parsing plist: \(error)")
    }
    return nil
}


private func prepareFileForSharing(originalURL: URL) -> URL? {
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory
    var destinationURL = tempDirectory.appendingPathComponent(originalURL.lastPathComponent)

    // 🔍 Prüfen, ob die Originaldatei existiert
    guard fileManager.fileExists(atPath: originalURL.path) else {
        print("❌ Fehler: Die Originaldatei existiert nicht! Pfad: \(originalURL.path)")
        return nil
    }

    // Falls Datei bereits existiert, vorher löschen
    if fileManager.fileExists(atPath: destinationURL.path) {
        do {
            try fileManager.removeItem(at: destinationURL)
            print("🔄 Alte temporäre Datei gelöscht: \(destinationURL.path)")
        } catch {
            print("❌ Fehler beim Löschen der existierenden Datei: \(error)")
            return nil
        }
    }

    // ✅ Neue Datei in tmp-Ordner kopieren
    do {
        try fileManager.copyItem(at: originalURL, to: destinationURL)
        print("✅ Datei erfolgreich kopiert nach: \(destinationURL.path)")

        // 🔹 Wichtig: Datei für UIActivityViewController freigeben
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = false // Datei nicht von iCloud Backup ausschließen
        try destinationURL.setResourceValues(resourceValues)

        // 🔹 Zugriff für das Teilen erzwingen
        try FileManager.default.setAttributes([.posixPermissions: 0o777], ofItemAtPath: destinationURL.path)
        
        return destinationURL
    } catch {
        print("❌ Fehler beim Kopieren der Datei für das Teilen: \(error)")
        return nil
    }
}
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
private func debugFilePaths() {
    let fileManager = FileManager.default
    let documentsDirectory = getDocumentsDirectory()

    do {
        let files = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
        print("📂 Dateien im Dokumentenverzeichnis:")
        for file in files {
            print("- \(file)")
        }
    } catch {
        print("❌ Fehler beim Abrufen der Dateiliste: \(error)")
    }
}
func serializeRecipeToPlist(recipe: Recipe, completion: @escaping (URL?, URL?) -> Void) {
    var dict: [String: Any] = [
        "id": recipe.id.uuidString,
        "title": recipe.title,
        "instructions": recipe.instructions,
        "videoLink": recipe.videoLink ?? "",
        "info": recipe.info ?? "",
        "recipeBookIDs": recipe.recipeBookIDs?.map { $0.uuidString } ?? [],
        "ingredients": serializeIngredients(ingredients: recipe.ingredients),
        "tags": recipe.tags?.map { ["id": $0.id.uuidString, "name": $0.name] } ?? []
    ]

    if let imagePath = recipe.image {
        print("📂 Überprüfe Bildpfad: \(imagePath)")

        
        let fileManager = FileManager.default
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let imageFileURL = applicationSupport.appendingPathComponent(imagePath)

        if fileManager.fileExists(atPath: imageFileURL.path) {
            
            if let image = UIImage(contentsOfFile: imageFileURL.path),
                   let imageData = image.jpegData(compressionQuality: 1.0) {
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
    
    if let portion = recipe.portion {
        dict["portion"] = portion.stringValue()
    }

    if let cake = recipe.cake {
        dict["cake"] = cake.stringValue()
    }

    let fileManager = FileManager.default
    let documentsDirectory = getDocumentsDirectory()
    let fileURL = documentsDirectory.appendingPathComponent("\(recipe.title).recipe")

    do {
        let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("🔄 Alte Rezeptdatei gelöscht: \(fileURL.path)")
        }

        try data.write(to: fileURL)
        print("✅ Rezept erfolgreich gespeichert: \(fileURL.path)")

        if fileManager.fileExists(atPath: fileURL.path) {
            print("📂 Datei wurde erfolgreich gespeichert: \(fileURL.path)")
        } else {
            print("❌ Fehler: Datei wurde NICHT gespeichert!")
        }

        completion(fileURL, fileURL)
    } catch {
        print("❌ Fehler beim Speichern der Rezeptdatei: \(error)")
        completion(nil, nil)
    }
}


func serializeIngredients(ingredients: [FoodItemStruct]) -> [[String: Any]] {
    return ingredients.map { ingredient in
        let foodDict = serializeFood(food: ingredient.food)
        let ingredientDict: [String: Any] = [
            "food": foodDict,
            "id": ingredient.id.uuidString,
            "unit": ingredient.unit.rawValue,
            "quantity": ingredient.quantity
        ]
        return ingredientDict
    }
}

func serializeFood(food: FoodStruct) -> [String: Any] {
    var foodDict = [String: Any]()
    foodDict["id"] = food.id.uuidString
    foodDict["name"] = food.name
    foodDict["category"] = food.category ?? ""
    foodDict["info"] = food.info ?? ""
    foodDict["density"] = food.density ?? 0

    var nutritionFactsDict = [String: Any]()
    if let nutritionFacts = food.nutritionFacts {
        nutritionFactsDict["calories"] = nutritionFacts.calories ?? 0
        nutritionFactsDict["protein"] = nutritionFacts.protein ?? 0
        nutritionFactsDict["carbohydrates"] = nutritionFacts.carbohydrates ?? 0
        nutritionFactsDict["fat"] = nutritionFacts.fat ?? 0
    }
    foodDict["nutritionFacts"] = nutritionFactsDict

    if let tags = food.tags {
        foodDict["tags"] = tags.map { tag -> [String: Any] in
            ["id": tag.id.uuidString, "name": tag.name]
        }
    }

    return foodDict
}

func generatePDF(for recipe: Recipe) -> URL? {
    let fileName = "\(recipe.title).pdf"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let pdfURL = documentsDirectory.appendingPathComponent(fileName)

    let pageWidth: CGFloat = 612
    let pageHeight: CGFloat = 792
    let margin: CGFloat = 40
    let contentWidth = pageWidth - 2 * margin
    let lineHeight: CGFloat = 20
    var yOffset: CGFloat = 50

    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

    do {
        try pdfRenderer.writePDF(to: pdfURL, withActions: { context in
            func checkPageSpace(_ requiredSpace: CGFloat) {
                if yOffset + requiredSpace > pageHeight - margin {
                    context.beginPage()
                    yOffset = margin
                }
            }

            context.beginPage()

            // Titel
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

            // Trennlinie
            context.cgContext.setStrokeColor(UIColor.systemGray.cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.move(to: CGPoint(x: margin, y: yOffset))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yOffset))
            context.cgContext.strokePath()
            yOffset += 15

            // Bild
            if let imagePath = recipe.image {
                let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let imageFileURL = applicationSupport.appendingPathComponent(imagePath)

                if FileManager.default.fileExists(atPath: imageFileURL.path),
                   let image = UIImage(contentsOfFile: imageFileURL.path) {

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

            // Info-Abschnitt
            let leftAlignStyle = NSMutableParagraphStyle()
            leftAlignStyle.alignment = .left

            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .paragraphStyle: leftAlignStyle
            ]

            var infoLines: [String] = []

            if recipe.portion != .notPortion {
                if case let .Portion(portionValue) = recipe.portion {
                    infoLines.append("Portionen: \(portionValue)")
                }
            }

            if case let .cake(_, size) = recipe.cake, recipe.cake != .notCake {
                switch size {
                case .rectangular(let length, let width):
                    infoLines.append("Rechteckige Form: \(length) x \(width) cm")
                case .round(let diameter):
                    infoLines.append("Runde Form: \(diameter) cm")
                }
            }

            if let tags = recipe.tags, !tags.isEmpty {
                let tagText = tags.map { $0.name }.joined(separator: ", ")
                infoLines.append("Tags: \(tagText)")
            }

            if let extraInfo = recipe.info, !extraInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                infoLines.append("Info: \(extraInfo)")
            }

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

            if !infoLines.isEmpty || videoLinkString != nil {
                // Hintergrundbox für Info
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

            // Abschnittsüberschrift "Zutaten"
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

            // Abschnitt "Zubereitung"
            let instructionsTitle = NSAttributedString(string: "Zubereitung:", attributes: sectionTitleAttributes)
            checkPageSpace(25)
            instructionsTitle.draw(at: CGPoint(x: margin, y: yOffset))
            yOffset += 25

            for (index, step) in recipe.instructions.enumerated() {
                let stepText = "\(index + 1). \(step)"
                let stepString = NSAttributedString(string: stepText, attributes: bodyAttributes)
                let estimatedHeight: CGFloat = 50
                checkPageSpace(estimatedHeight)
                stepString.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: estimatedHeight))
                yOffset += 40
            }
        })

        return pdfURL
    } catch {
        print("Error generating PDF: \(error)")
        return nil
    }
}



extension UIColor {
    func darker(by percentage: CGFloat = 20.0) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }

    func adjust(by percentage: CGFloat = 20.0) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }
        return self
    }
}


extension Notification.Name {
    static let recipeOpened = Notification.Name("recipeOpened")
}


func moveFileToTempDirectory(originalURL: URL) -> URL? {
    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(originalURL.lastPathComponent)
    let fileManager = FileManager.default

    do {
        if fileManager.fileExists(atPath: tempURL.path) {
            try fileManager.removeItem(at: tempURL)
        }
        try fileManager.copyItem(at: originalURL, to: tempURL)
        print("✅ Datei erfolgreich nach tmp verschoben: \(tempURL.path)")
        return tempURL
    } catch {
        print("❌ Fehler beim Verschieben der Datei: \(error)")
        return nil
    }
}


func setFileAttributes(for url: URL) {
    var mutableURL = url // URL als veränderbare Variable kopieren
    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = false // Datei nicht aus iCloud-Backup ausschließen
    do {
        try mutableURL.setResourceValues(resourceValues)
        try FileManager.default.setAttributes([.posixPermissions: 0o777], ofItemAtPath: mutableURL.path)
        print("🔓 Datei-Berechtigungen wurden aktualisiert")
    } catch {
        print("❌ Fehler beim Setzen der Datei-Berechtigungen: \(error)")
    }
}


func deleteRecipeImage(recipe: Recipe) {
    deleteImage(id: recipe.id.uuidString)
}


func deleteImage(id : String) {
    let fileManager = FileManager.default
    let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let imageFileURL = applicationSupport.appendingPathComponent("\(id).jpg")

    if fileManager.fileExists(atPath: imageFileURL.path) {
        do {
            try fileManager.removeItem(atPath: imageFileURL.path)
            print("✅ Bild erfolgreich gelöscht: \(imageFileURL.path)")
        } catch {
            print("❌ Fehler beim Löschen der Bilddatei: \(error)")
        }
    } else {
        print("⚠️ Kein Bild vorhanden zum Löschen: \(imageFileURL.path)")
    }
    // 🔍 Inhalte des Verzeichnisses ausgeben
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
