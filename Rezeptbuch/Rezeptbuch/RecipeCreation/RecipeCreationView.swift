//
//  RecipeCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 13.03.24.
//
import AVFoundation
import SwiftUI

// Struktur zur Darstellung eines Validierungsfehlers (z. B. bei leerem Titel)
struct ValidationError: Identifiable {
    let id = UUID()                // Eindeutige ID zur Identifikation (für SwiftUI Alerts)
    var message: String           // Fehlermeldung, die angezeigt werden soll
}

// Die Hauptansicht zum Erstellen oder Bearbeiten eines Rezepts
struct RecipeCreationView: View {
    // Zugriff auf das zentrale ViewModel
    @ObservedObject var modelView: ViewModel

    // Tabwechsel (z. B. nach Speichern automatisch zurückspringen)
    @Binding var selectedTab: Int

    // Bindung zum aktuell ausgewählten Rezept (z. B. für Rücksprung nach Bearbeitung)
    @Binding var selectedRecipe: UUID?

    // Rezeptdaten, mit der View intern arbeitet
    @State private var recipe: Recipe

    // Callback-Funktion, die nach dem Speichern aufgerufen wird
    var onSave: () -> Void

    // PresentationMode (für `.dismiss()`)
    @Environment(\.presentationMode) var presentationMode

    // Zustand des Bearbeitungsmodus (z. B. für Drag & Drop)
    @State private var editModeState: EditMode = .inactive

    // Eingabefelder und Zustände
    @State private var recipeTitle = ""
    @State private var ingredients: [FoodItemStruct?] = []
    @State private var editableIngredients: [EditableIngredient] = []
    @State private var instructions: [InstructionItem] = []

    // Portionen (oder Kuchengröße)
    @State private var portionValue: String = ""
    @State private var isCake = false
    @State private var cakeForm: Formen = .rund
    @State private var size: [String] = ["0.0", "0.0", "0.0"] // [Durchmesser, Länge, Breite]
    @State private var cakeSize: CakeSize = .round(diameter: 0.0)

    @State private var info: String = "" // Zusatzinformationen zum Rezept
    @State private var recipeImage: UIImage? // Bild des Rezepts

    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    // Zustände für Bildaufnahme und -auswahl
    @State private var showingImagePicker = false
    @State private var isTargeted = false
    @State private var validationError: ValidationError?

    @State private var showingCameraPicker = false
    @State private var showingPermissionAlert = false

    // YouTube-Link zum Rezeptvideo
    @State private var videoLink: String = ""

    // ID des Rezepts
    @State private var id: UUID = .init()
    @State private var idToOpen: UUID?

    // Rezeptbücher (Mehrfachauswahl)
    @State private var selectedRecipeBookIDs: Set<UUID> = []
    @State private var showingNewRecipeBookDialog = false
    @State private var newRecipeBookName = ""
    @State private var newRecipeBookDummyID = UUID()
    @State private var recipeBookSearchText: String = ""
    @State private var filteredRecipeBooks: [RecipebookStruct]

    // Tags (z. B. „Vegan“, „Herzhaft“)
    @State private var selectedTags: Set<UUID> = []
    @State private var allTags: [TagStruct]
    @State private var newTagName = ""
    @State private var showingAddTagField = false
    @State private var tagSearchText = ""
    @State private var filteredTags: [TagStruct] = []

    // Handelt es sich um ein neues oder ein bestehendes Rezept?
    @State private var newRecipe: Bool = true
    @State private var shouldNavigateBack = false

    @State private var showingIngredientSearch = false

    // Initialisierung der View – mit optionalem bestehendem Rezept (z. B. für Bearbeitung)
    init(recipe: Recipe? = nil,
         modelView: ViewModel,
         selectedTab: Binding<Int> = .constant(0),
         selectedRecipe: Binding<UUID?> = .constant(nil),
         onSave: @escaping () -> Void) {

        self.modelView = modelView
        self.onSave = onSave
        self.allTags = modelView.tags
        self._selectedTab = selectedTab
        self._selectedRecipe = selectedRecipe
        self.filteredRecipeBooks = modelView.recipeBooks

        // Bearbeitungsmodus: vorhandenes Rezept wird geladen
        if let recipe = recipe {
            self.newRecipe = false
            _recipe = State(initialValue: recipe)
            _recipeTitle = State(initialValue: recipe.title)

            // Zutaten laden und sortieren
            _ingredients = State(initialValue: recipe.ingredients.sorted { $0.number ?? 0 < $1.number ?? 1 })
            _editableIngredients = State(initialValue:
                recipe.ingredients
                    .sorted { ($0.number ?? 0) < ($1.number ?? 1) }
                    .map { EditableIngredient(from: $0) }
            )

            _instructions = State(initialValue: recipe.instructions)

            // Portion oder Kuchenform?
            if case .Portion(let portionValue) = recipe.portion {
                _portionValue = State(initialValue: String(portionValue))
            } else {
                _portionValue = State(initialValue: "0.0")
            }

            // Wenn Kucheninformationen vorhanden sind
            _isCake = State(initialValue: recipe.cake != .notCake || (recipe.cake != nil && recipe.portion == .notPortion))
            _cakeForm = State(initialValue: recipe.cake?.form ?? .rund)
            _cakeSize = State(initialValue: recipe.cake?.size ?? .round(diameter: 0))
            _info = State(initialValue: recipe.info ?? "")
            _videoLink = State(initialValue: recipe.videoLink ?? "")
            _id = State(initialValue: recipe.id)

            // Kuchengröße in lesbare Strings umwandeln
            switch recipe.cake?.size {
            case .round(diameter: let dia):
                _size = State(initialValue: [String(dia), "0.0", "0.0"])
            case .rectangular(length: let len, width: let wid):
                _size = State(initialValue: ["0.0", String(len), String(wid)])
            case .none:
                _size = State(initialValue: ["0.0", "0.0", "0.0"])
            }

            // Bild vom Pfad laden (aus Application Support)
            let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let fileURL = applicationSupport.appendingPathComponent(recipe.image ?? "")
            if let imagePath = recipe.image, let uiImage = UIImage(contentsOfFile: fileURL.path) {
                _recipeImage = State(initialValue: uiImage)
            }

            // Tags übernehmen
            if let tags = recipe.tags {
                _selectedTags = State(initialValue: Set(tags.map { $0.id }))
            }

            // Zugeordnete Rezeptbücher übernehmen
            if let id = recipe.recipeBookIDs {
                _selectedRecipeBookIDs = State(initialValue: Set(id))
            }

        } else {
            // Neuanlage eines leeren Rezepts
            _recipe = State(initialValue: Recipe.empty)
            _recipeTitle = State(initialValue: "")
            _ingredients = State(initialValue: [])
            _instructions = State(initialValue: [])
            _portionValue = State(initialValue: "")
            _isCake = State(initialValue: false)
            _cakeForm = State(initialValue: .rund)
            _cakeSize = State(initialValue: .round(diameter: 0))
            _info = State(initialValue: "")
            _videoLink = State(initialValue: "")
            _idToOpen = State(initialValue: id)
        }
    }
    
    // Zustand des Bearbeitungsmodus – z. B. für die Reorder-Funktion in Zutaten
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        NavigationView {
            content // Deine Hauptansicht mit Feldern & Sektionen
                
                .navigationBarTitle("Rezept erstellen") // Titel der Ansicht

                // Toolbar oben rechts
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Speichern-Button
                        Button("Speichern") {
                            if validateInputs() { // Eingaben validieren
                                saveRecipe() // Speichern in Datenstruktur
                                presentationMode.wrappedValue.dismiss() // Schließt die Ansicht
                                
                                selectedRecipe = idToOpen // Markiert das neue Rezept zur Anzeige
                                idToOpen = nil
                                
                                selectedTab = 0 // Springt auf ersten Tab (z. B. Übersicht)
                                onSave() // Callback → z. B. Reload im Rezept-View
                            }

                            // Debug-Ausgabe bei Bedarf
                            print(validationError)
                        }

                        // Deaktiviert den Button, wenn Eingaben ungültig oder leer
                        .disabled((editMode == .inactive || recipeTitle.isEmpty) && validationError != nil)

                        // Zeigt Alert bei Fehlern
                        .alert(item: $validationError) { error in
                            Alert(
                                title: Text("Fehler"),
                                message: Text(error.message),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }

                // Übergibt den EditMode in die untergeordneten Views (z. B. für .onMove bei Zutaten)
                .environment(\.editMode, $editMode)
        }
        // Für iPhone nötig, damit der `NavigationView` korrekt funktioniert
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Setzt alle Felder zurück, z. B. nach erfolgreichem Speichern oder bei Abbruch
    private func resetFormFields() {
        // Basisdaten
        recipeTitle = ""
        ingredients = []
        editableIngredients = []
        instructions = []

        // Portion / Kuchenform
        portionValue = ""
        isCake = false
        cakeForm = .rund
        size = ["0.0", "0.0", "0.0"]
        cakeSize = .round(diameter: 0.0)

        info = ""

        // Bild
        recipeImage = nil
        sourceType = .photoLibrary
        showingImagePicker = false
        isTargeted = false
        validationError = nil

        // Kamera / Berechtigungen
        showingCameraPicker = false
        showingPermissionAlert = false

        // Video-Link
        videoLink = ""

        // Neue ID generieren
        id = UUID()

        // Rezeptbuchverwaltung
        selectedRecipeBookIDs = []
        showingNewRecipeBookDialog = false
        newRecipeBookName = ""
        newRecipeBookDummyID = UUID()
        recipeBookSearchText = ""
        filteredRecipeBooks = modelView.recipeBooks

        // Tag-Verwaltung
        selectedTags = []
        allTags = modelView.tags
        newTagName = ""
        showingAddTagField = false
        tagSearchText = ""
        filteredTags = []

        // Rezeptstatus
        newRecipe = true
        shouldNavigateBack = false
    }
    
    // Validiert alle Eingaben im Rezeptformular und gibt true zurück, wenn alles korrekt ist.
    // Bei Fehler wird eine entsprechende Fehlermeldung gesetzt (für Alert-Anzeige).
    private func validateInputs() -> Bool {
        // Lokale Fehler-Variable – wird nur gesetzt, wenn ein Problem auftritt
        var error: ValidationError?

        // 🔴 Titel darf nicht leer sein
        if recipeTitle.isEmpty {
            error = ValidationError(message: "Bitte geben Sie einen Titel für das Rezept ein.")
        }
        // 🔍 Wenn es sich um einen Kuchen handelt, müssen gültige Maße eingegeben werden
        else if isCake {
            // Rundform → Durchmesser muss > 0
            if cakeForm == .rund && Double(size[0]) ?? 0.0 <= 0 {
                error = ValidationError(message: "Bitte geben Sie einen gültigen Durchmesser für den Kuchen ein.")
            }
            // Eckige Form → Länge & Breite müssen > 0
            else if cakeForm == .eckig && (Double(size[1]) ?? 0.0 <= 0 || Double(size[2]) ?? 0.0 <= 0) {
                error = ValidationError(message: "Bitte geben Sie eine gültige Länge und Breite für den Kuchen ein.")
            }
        }
        // 🔢 Wenn kein Kuchen → Portionsgröße muss > 0 sein
        else if Double(portionValue) ?? 0.0 <= 0 {
            error = ValidationError(message: "Bitte geben Sie eine gültige Portionsgröße ein.")
        }

        // 🧂 Mindestens eine Zutat muss vorhanden sein
        if editableIngredients.isEmpty {
            error = ValidationError(message: "Bitte fügen Sie eine Zutat hinzu.")
        }

        // ✅ Jede Zutat muss gültig sein (Zutat gewählt, Menge vorhanden und > 0)
        for ingredient in editableIngredients {
            if ingredient.food == nil {
                error = ValidationError(message: "Bitte füllen Sie alle Zutaten aus.")
                break
            } else if ingredient.quantity.isEmpty
                      || Double(ingredient.quantity.replacingOccurrences(of: ",", with: ".")) == nil
                      || Double(ingredient.quantity.replacingOccurrences(of: ",", with: "."))! <= 0 {
                error = ValidationError(message: "Bitte geben Sie eine gültige Menge für alle Zutaten ein.")
                break
            }
        }

        // 🔧 Anweisungen: mindestens eine muss vorhanden sein
        if instructions.isEmpty {
            error = ValidationError(message: "Bitte fügen Sie mindestens einen Zubereitungsschritt hinzu.")
        }

        // 🔁 Doppelte oder leere Anweisungen prüfen
        var seenKeys = Set<String>()
        for instruction in instructions {
            let trimmed = instruction.text.trimmingCharacters(in: .whitespacesAndNewlines)

            // Anweisung darf nicht leer sein
            if trimmed.isEmpty {
                error = ValidationError(message: "Bitte füllen Sie alle Anweisungen aus.")
                break
            }

            // Keine doppelten Anweisungen (z. B. Copy-Paste)
            if seenKeys.contains(trimmed) {
                error = ValidationError(message: "Doppelte Anweisung gefunden: '\(trimmed)'. Bitte eindeutige Schritte verwenden.")
                break
            }

            seenKeys.insert(trimmed)
        }

        // 📌 Setze die gefundene Fehlernachricht für Alert
        validationError = error

        // ✅ Wenn kein Fehler: true zurückgeben
        return error == nil
    }

    // Speichert das aktuelle Rezept – entweder als neues Rezept oder als Aktualisierung eines bestehenden
    private func saveRecipe() {
        // 🔁 Zutaten in FoodItemStruct umwandeln und nummerieren (Reihenfolge festhalten)
        let convertedIngredients = editableIngredients.enumerated().compactMap { index, item -> FoodItemStruct? in
            var updated = item
            updated.number = Int64(index) // Reihenfolge speichern
            print(updated.number) // Debug-Ausgabe
            return updated.toFoodItem() // Konvertierung
        }

        // 🎥 Optionaler YouTube-Link – wird nur gesetzt, wenn nicht leer
        let videoLinkSav: String? = videoLink.isEmpty ? nil : videoLink

        // 📝 Info-Feld – ebenfalls optional
        let infoSav: String? = info.isEmpty ? nil : info

        // 🍰 Kucheninfos oder nicht, je nach Auswahl
    
        if cakeForm == .rund{
            cakeSize = .round(diameter: Double(size[0]) ?? 0)
        } else if cakeForm == .eckig{
            cakeSize = .rectangular(length: Double(size[1]) ?? 0, width: Double(size[2]) ?? 0)
        }
        
        let cakeInfo: CakeInfo = isCake
            ? .cake(form: cakeForm, size: cakeSize)
            : .notCake
        
        
           

        // 🍽️ Portioneninfo, nur wenn es **kein** Kuchen ist
        let portionInfo: PortionsInfo = isCake
            ? .notPortion
            : .Portion(Double(portionValue) ?? 0.0)

        // 🏷️ Tags aus der Auswahl in die vollständige Struktur umwandeln
        var tagsSav: [TagStruct] = []
        for tagID in selectedTags {
            let filteredTags = allTags.filter { $0.id == tagID }
            tagsSav.append(contentsOf: filteredTags)
        }

        // 📚 Zugeordnete Rezeptbücher ebenfalls vollständig ermitteln
        var bookSav: [RecipebookStruct] = []
        for bookID in selectedRecipeBookIDs {
            let filteredBooks = filteredRecipeBooks.filter { $0.id == bookID }
            bookSav.append(contentsOf: filteredBooks)
        }

        // 🖼️ Bild lokal speichern, falls vorhanden → Speicherpfad merken
        var imagePath: String? = nil
        if let image = recipeImage,
           let Path = saveImageLocally(image: image, id: id) {
            imagePath = Path
        }

        // 🧠 Neue Rezeptstruktur erzeugen mit allen Informationen
        recipe = Recipe(
            id: id,
            title: recipeTitle,
            ingredients: convertedIngredients,
            instructions: instructions,
            image: imagePath,
            portion: portionInfo,
            cake: cakeInfo,
            videoLink: videoLinkSav,
            info: infoSav,
            tags: tagsSav,
            recipeBookIDs: Array(selectedRecipeBookIDs)
        )

        // 💾 Neues Rezept speichern oder bestehendes aktualisieren
        if newRecipe {
            CoreDataManager.shared.saveRecipe(recipe)
        } else {
            CoreDataManager.shared.updateRecipe(recipe)
        }

        // 🔗 Rezept den ausgewählten Büchern zuordnen
        for book in bookSav {
            CoreDataManager.shared.addRecipe(recipe, toRecipeBook: book)
        }

        // 🔄 ViewModel aktualisieren, damit UI reagiert
        modelView.updateRecipe()
        modelView.updateFood()
        modelView.updateTags()
        modelView.updateBooks()

        // 🧹 Alle Formularfelder zurücksetzen für nächstes Rezept oder Abschluss
        resetFormFields()
    }
   
    // Diese Property bildet den gesamten Formularinhalt für die Rezept-Erstellung ab.
    var content: some View {
        Form {
            // 🧾 Allgemeine Informationen (Titel, Kuchen/Portionen, Form & Größe)
            GeneralInfoSectionView(
                recipeTitle: $recipeTitle,
                isCake: $isCake,
                cakeForm: $cakeForm,
                size: $size,
                portionValue: $portionValue
            )

            // 📝 Zusatzinfos zum Rezept
            InfoSectionView(info: $info)

            // 🎥 YouTube-Video-Link (optional)
            YouTubeSectionView(videoLink: $videoLink)

            // 📚 Rezeptbücher – Auswahl + Erstellung
            RecipeBookSectionView(
                selectedRecipeBookIDs: $selectedRecipeBookIDs,
                newRecipeBookName: $newRecipeBookName,
                recipeBookSearchText: $recipeBookSearchText,
                filteredRecipeBooks: $filteredRecipeBooks,
                showingNewRecipeBookDialog: $showingNewRecipeBookDialog,
                newRecipeBookDummyID: $newRecipeBookDummyID,
                modelView: modelView
            )

            // 🏷️ Tags – Auswahl (z. B. „Vegan“, „Schnell“, „Süß“)
            TagsSectionView(
                allTags: $allTags,
                selectedTags: $selectedTags
            )

            // 🖼️ Bildauswahl (Kamera, Galerie, Drag & Drop)
            ImagePickerSectionView(
                recipeImage: $recipeImage,
                showingImagePicker: $showingImagePicker,
                showingCameraPicker: $showingCameraPicker,
                showingPermissionAlert: $showingPermissionAlert,
                isTargeted: $isTargeted,
                sourceType: $sourceType
            )

            // 🧂 Zutatenverwaltung (hinzufügen, bearbeiten, löschen, verschieben)
            IngredientSectionView(
                editableIngredients: $editableIngredients,
                allFoods: modelView.foods,
                modelView: modelView
            )

            // 🔢 Zubereitungsschritte (Schritt-für-Schritt)
            InstructionSectionView(instructions: $instructions)
        }
        // Aktiviert den Editiermodus automatisch beim Anzeigen (z. B. für Reordering)
        .onAppear {
            self.editMode = .active
        }
    }
}

// Erweiterung für Array, die einen sicheren Zugriff auf Elemente erlaubt.
// Verhindert Abstürze bei ungültigen Indizes.
extension Array {
    // Neuer Subscript-Zugriff: array[safe: index]
    subscript(safe index: Int) -> Element? {
        // Prüft, ob der Index im gültigen Bereich des Arrays liegt
        return indices.contains(index) ? self[index] : nil
        // Wenn ja → gibt das Element zurück
        // Wenn nein → gibt nil zurück (statt Absturz)
    }
}

