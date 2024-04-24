//
//  RecipeCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 13.03.24.
//
import AVFoundation
import SwiftUI
#if os(macOS)
import AppKit
#else

#endif

struct ValidationError: Identifiable {
    let id = UUID()
    var message: String
}

struct RecipeCreationView: View {
    @ObservedObject var modelView: ViewModel
    @State private var recipe: Recipe
    @State private var recipeTitle = ""
    @State private var ingredients: [FoodItemStruct?] = []
    @State private var foods: [FoodStruct] = []
    @State private var instructions: [String] = []
    @State private var quantity: [String] = []
    @State private var selectedUnit: [Unit] = []
    @State private var portionValue: String = ""
    @State private var isCake = false
    @State private var cakeForm: Formen = .rund
    @State private var size: [String] = ["0.0", "0.0", "0.0"]
    @State private var cakeSize: CakeSize = .round(diameter: 0.0)
    @State private var info: String = ""
#if os(macOS)
    @State private var recipeImage: NSImage?
#else
    @State private var recipeImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary // Neue State Variable
#endif
    @State private var showingImagePicker = false
    @State private var isTargeted = false
    @State private var validationError: ValidationError?
    
    @State private var showingCameraPicker = false
    @State private var showingPermissionAlert = false
    
    @State private var videoLink: String = ""
    @State private var id: UUID = UUID()
    
    @State private var selectedRecipeBookIDs: Set<UUID> = []
    
    @State private var showingNewRecipeBookDialog = false
    @State private var selectedRecipeBookID: UUID?
    @State private var newRecipeBookName = ""
    @State private var newRecipeBookDummyID = UUID()
    
    @State private var selectedTags: Set<UUID> = []
    @State private var allTags: [TagStruct]
    @State private var newTagName = ""
    @State private var showingAddTagField = false
    
    @State private var tagSearchText = ""
    @State private var filteredTags: [TagStruct] = []
    
    
    
    init(recipe: Recipe? = nil, modelView: ViewModel) {
            self.modelView = modelView
        allTags = modelView.tags
      
            if let recipe = recipe {
                _recipe = State(initialValue: recipe)
                _recipeTitle = State(initialValue: recipe.title)
                _ingredients = State(initialValue: recipe.ingredients)
                _instructions = State(initialValue: recipe.instructions)
                if case let .Portion(portionValue) = recipe.portion {
                           self._portionValue = State(initialValue: String(portionValue))
                       } else {
                           self._portionValue = State(initialValue: "0.0")
                       }
                _isCake = State(initialValue: recipe.cake != nil)
                _cakeForm = State(initialValue: recipe.cake?.form ?? .rund)
                _cakeSize = State(initialValue: recipe.cake?.size ?? .round(diameter: 0))
                _info = State(initialValue: recipe.info ?? "")
                _videoLink = State(initialValue: recipe.videoLink ?? "")
                _id = State(initialValue: recipe.id)
               
                _foods = State(initialValue: ingredients.compactMap { $0?.food })
                _quantity = State(initialValue: ingredients.compactMap { ingredient in
                            if let quantity = ingredient?.quantity {
                                return String(quantity)
                            } else {
                                return nil
                            }
                        })
                _selectedUnit = State(initialValue: ingredients.compactMap { $0?.unit })
                
                switch recipe.cake?.size {
                       case .round(diameter: let dia):
                           self._size = State(initialValue: [String(dia), "0.0", "0.0"])
                       case .rectangular(length: let len, width: let wid):
                           self._size = State(initialValue: ["0.0", String(len), String(wid)])
                       case .none:
                           self._size = State(initialValue: ["0.0", "0.0", "0.0"])
                       }
                
                if let imagePath = recipe.image, let uiImage = UIImage(contentsOfFile: imagePath) {
                               self._recipeImage = State(initialValue: uiImage) // Store UIImage directly
                           }
            } else {
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
            }
       
        }
    
#if os(macOS)
    @State private var editMode: EditMode = .inactive // Verwenden Sie den Bearbeitungsmodus von SwiftUI
    
    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if validateInputs() {
                            saveRecipe()
                        }
                    }) {
                        Text("Speichern")
                    }
                    .disabled((editMode == .inactive || recipeTitle.isEmpty) && validationError != nil)
                    
                    .alert(item: $validationError) { error in
                        Alert(title: Text("Fehler"), message: Text(error.message), dismissButton: .default(Text("OK")))
                    }
                }
            }
    }
#else
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Rezept erstellen")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if validateInputs() {
                                saveRecipe()
                            }
                            print(validationError)
                        }) {
                            Text("Speichern")
                        }
                        .disabled((editMode == .inactive || recipeTitle.isEmpty) && validationError != nil)
                        .alert(item: $validationError) { error in
                            Alert(title: Text("Fehler"), message: Text(error.message), dismissButton: .default(Text("OK")))
                        }
                       
                    }
                }
                .environment(\.editMode, $editMode)
        }.navigationViewStyle(StackNavigationViewStyle()) // Hier wird der Modifier hinzugefügt
    }
#endif
    private func resetFormFields() {
        recipeTitle = ""
        ingredients = []
        instructions = []
        portionValue = ""
        isCake = false
        size = ["0.0", "0.0", "0.0"]
        info = ""
        videoLink = ""
        foods = []
        quantity = []
        selectedUnit = []
        id = UUID()
    }
    private func validateInputs() -> Bool {
        var error: ValidationError? // Fehlerobjekt erstellen
        
        if recipeTitle.isEmpty {
            error = ValidationError(message: "Bitte geben Sie einen Titel für das Rezept ein.")
        } else if isCake {
            if cakeForm == .rund && Double(size[0])! <= 0 {
                error = ValidationError(message: "Bitte geben Sie einen gültigen Durchmesser für den Kuchen ein.")
            } else if cakeForm == .eckig && (Double(size[1])! <= 0 || Double(size[2])! <= 0) {
                error = ValidationError(message: "Bitte geben Sie eine gültige Länge und Breite für den Kuchen ein.")
            }
        } else if Double(portionValue) ?? 0.0 <= 0 {
            error = ValidationError(message: "Bitte geben Sie eine gültige Portionsgröße ein.")
        }
//        print(foods.count)
        if foods.isEmpty {
            error = ValidationError(message: "Bitte fügen Sie eine Zutate hinzu.")
        }
        for (index, ingredient) in foods.enumerated() {
            if ingredient == emptyFood {
//                print("neinnnn")
                error = ValidationError(message: "Bitte füllen Sie alle Zutaten aus.")
            } else if quantity[index].isEmpty || Double(quantity[index]) == nil || Double(quantity[index])! <= 0 {
                error = ValidationError(message: "Bitte geben Sie eine gültige Menge für alle Zutaten ein.")
            }
        }
        if instructions.isEmpty {
            error = ValidationError(message: "Bitte fügen Sie eine Zutate hinzu.")
        }
        for instruction in instructions {
            if instruction.isEmpty {
                error = ValidationError(message: "Bitte füllen Sie alle Anweisungen aus.")
            }
        }
        
        // Setze den Fehler in den Zustand
        validationError = error
        
        // Rückgabe, ob die Validierung erfolgreich war
        return error == nil
    }

#if os(iOS)
    private func saveImageLocally(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpeg"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("Bild gespeichert unter: \(fileURL.path)")
            return fileURL.path
        } catch {
            print("Fehler beim Speichern des Bildes: \(error)")
            return nil
        }
    }
#endif
    
#if os(macOS)
    
    private func saveImageLocally(image: NSImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpeg"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("Bild gespeichert unter: \(fileURL.path)")
            return fileURL.path
        } catch {
            print("Fehler beim Speichern des Bildes: \(error)")
            return nil
        }
    }
    
    func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["png", "jpg", "jpeg"]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // Verarbeite das ausgewählte Bild
                let image = NSImage(contentsOf: url)
                self.recipeImage = image
            }
        }
    }
#endif
    
    private func saveRecipe() {
        // Vorbereitung der Zutaten und Prüfung des Rezepts wie bisher
           for i in 0 ..< ingredients.count {
               if foods[i] != emptyFood {
                   ingredients[i] = FoodItemStruct(food: foods[i],
                                                   unit: selectedUnit[i],
                                                   quantity: Double(quantity[i])!)
               }
           }

           let videoLinkSav: String? = videoLink.isEmpty ? nil : videoLink
           let infoSav: String? = info.isEmpty ? nil : info

           let cakeInfo: CakeInfo = isCake ? .cake(form: cakeForm, size: cakeSize) : .notCake
           let portionInfo: PortionsInfo = isCake ? .notPortion : .Portion(Double(portionValue) ?? 0.0)

         
           // Nach dem Speichern, Formular zurücksetzen und eventuell zur Detailansicht navigieren
           resetFormFields()
        if let image = recipeImage, let imagePath = saveImageLocally(image: image) {
            recipe = Recipe(id: id,
                            title: recipeTitle,
                            ingredients: ingredients.compactMap { $0 },
                            instructions: instructions,
                            image: imagePath, // Pfad zur Bilddatei
                            portion: isCake ? .notPortion : .Portion(Double(portionValue) ?? 0.0),
                            cake: isCake ? .cake(form: cakeForm, size: cakeSize) : .notCake,
                            videoLink: videoLinkSav,
                            info: infoSav)
        } else {
            if isCake {
                recipe = Recipe(id: id,
                                title: recipeTitle,
                                ingredients: ingredients.compactMap { $0 },
                                instructions: instructions,
                                image: nil,
                                portion: .notPortion,
                                cake: .cake(form: cakeForm, size: cakeSize),
                                videoLink: videoLinkSav,
                                info: infoSav)
            } else {
                recipe = Recipe(id: id,
                                title: recipeTitle,
                                ingredients: ingredients.compactMap { $0 },
                                instructions: instructions,
                                image: nil,
                                portion: .Portion(Double(portionValue) ?? 0.0),
                                cake: .notCake,
                                videoLink: videoLinkSav,
                                info: infoSav)
            }
        }
        
//        print("ja")
        // Speichern des Rezepts im Datenmanager
       

        // Zuordnen des Rezepts zum ausgewählten Rezeptbuch
       

        CoreDataManager().saveRecipe(recipe)
        CoreDataManager().updateRecipe(recipe)
        modelView.updateRecipe()
        modelView.updateFood()
        if let bookID = selectedRecipeBookID {
            CoreDataManager.shared.addRecipe(recipe, toRecipeBookWithID: bookID)
        }
        resetFormFields()
        
    }
    func addNewRecipeBook() {
        let newBook = RecipebookStruct(name: newRecipeBookName, recipes: [])
        modelView.recipeBooks.append(newBook)
        selectedRecipeBookIDs.insert(newBook.id) // Optional: automatisch auswählen
        newRecipeBookName = "" // Reset
        showingNewRecipeBookDialog = false
    }
    private func loadImage() {
        guard let inputImage = recipeImage else { return }
        // Additional processing of the loaded image, if needed
    }

    func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCameraPicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showingCameraPicker = true
                    } else {
                        self.showingPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showingPermissionAlert = true
        @unknown default:
            break
        }
    }
    var recipeBookPicker: some View {
        Picker("Wählen Sie ein Rezeptbuch", selection: $selectedRecipeBookID) {
                     ForEach(modelView.recipeBooks, id: \.id) { book in
                         Text(book.name).tag(book.id as UUID?)
                     }
                     // Verwenden der konstanten Dummy-UUID
                     Text("Neues Rezeptbuch hinzufügen").tag(newRecipeBookDummyID as UUID?)
                 }
                 .onChange(of: selectedRecipeBookID) { newValue in
                     if newValue == newRecipeBookDummyID { // Überprüfen, ob die Dummy-UUID ausgewählt wurde
                         self.showingNewRecipeBookDialog = true
                         // Zurücksetzen der Auswahl
                         self.selectedRecipeBookID = nil
                     }
                 }
                 .pickerStyle(MenuPickerStyle())
    }

    var newRecipeBookView: some View {
        VStack {
            Text("Neues Rezeptbuch erstellen")
            TextField("Name des Rezeptbuchs", text: $newRecipeBookName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Hinzufügen") {
                let newBook = RecipebookStruct(id: UUID(), name: newRecipeBookName)
                modelView.recipeBooks.append(newBook)
                selectedRecipeBookID = newBook.id
                showingNewRecipeBookDialog = false
                newRecipeBookName = ""
                self.newRecipeBookDummyID = UUID()
            }
            .disabled(newRecipeBookName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }

    
    var content: some View {
        Form {
            Section(header: Text("Allgemeine Informationen")) {
                VStack {
                    TextField("Rezept-Titel", text: $recipeTitle)
                    
                    Section(header: Text("Bild auswählen")) {
                        HStack {
#if os(macOS)
                            Button("Bild auswählen", action: openFilePicker)
                          
#else
                            Button(action: {
                                checkCameraPermissions()
                            }) {
                                Label("Kamera", systemImage: "camera")
                            }
                            .alert(isPresented: $showingPermissionAlert) {
                                Alert(
                                    title: Text("Zugriff verweigert"),
                                    message: Text("Bitte erlaube den Zugriff auf die Kamera in den Einstellungen deines Geräts."),
                                    dismissButton: .default(Text("OK")))
                            }
                         
                            Button(action: {
                                self.showingImagePicker = true
                                self.sourceType = .photoLibrary
                            }) {
                                Label("Galerie", systemImage: "photo.on.rectangle")
                            }
#endif
                        }
                        
                        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
#if os(iOS)
                            ImagePicker(image: self.$recipeImage, sourceType: self.sourceType)
#else
                            ImagePicker(image: self.$recipeImage)
#endif
                        }
                    }
#if os(iOS)
                    .onDrop(of: ["public.image"], isTargeted: $isTargeted) { providers, _ in
                        providers.first?.loadObject(ofClass: UIImage.self, completionHandler: { image, _ in
                            DispatchQueue.main.async {
                                if let image = image as? UIImage {
                                    self.recipeImage = image
                                }
                            }
                        })
                        return true
                    }
#else
                    .onDrop(of: ["public.file-url"], isTargeted: $isTargeted) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, _ in
                                if let data = data, let path = String(data: data, encoding: .utf8), let url = URL(string: path) {
                                    DispatchQueue.main.async {
                                        if let image = NSImage(contentsOf: url) {
                                            self.recipeImage = image
                                        }
                                    }
                                }
                            })
                            return true
                        }
#endif
                    
#if os(iOS)
                    if let image = recipeImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    }
#else
                    if let image = recipeImage {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    }
#endif
                    Section(header: Text("info")) {
                        TextField("infos Zum Rezept", text: $info)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            
                    }
                    Section(header: Text("Rezeptbücher")) {
                                if modelView.recipeBooks.isEmpty {
                                    Button("Neues Rezeptbuch erstellen") {
                                        self.showingNewRecipeBookDialog = true
                                    }
                                } else {
                                    recipeBookPicker
                                }
                            }
                            .sheet(isPresented: $showingNewRecipeBookDialog) {
                                newRecipeBookView
                            }
                    
                    Section(header: Text("Tags")) {
                        TextField("Tag suchen...", text: $tagSearchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: tagSearchText) { newValue in
                                if newValue.isEmpty {
                                    filteredTags = allTags
                                } else {
                                    filteredTags = allTags.filter { $0.name.lowercased().contains(newValue.lowercased()) }
                                }
                            }
                            .onAppear {
                                filteredTags = allTags // Initialfüllung beim Erscheinen der Ansicht
                            }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(filteredTags, id: \.id) { tag in
                                    Text(tag.name)
                                        .padding()
                                        .background(selectedTags.contains(tag.id) ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                        .onTapGesture {
                                            if selectedTags.contains(tag.id) {
                                                selectedTags.remove(tag.id)
                                            } else {
                                                selectedTags.insert(tag.id)
                                            }
                                        }
                                }
                            }
                        }

                        Button("Neuen Tag hinzufügen") {
                            showingAddTagField = true
                        }
                    }

                    .sheet(isPresented: $showingAddTagField) {
                        VStack {
                            TextField("Neuen Tag eingeben", text: $newTagName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Tag hinzufügen") {
                                let newTag = TagStruct(name: newTagName, id: UUID())
                                allTags.append(newTag)
                                selectedTags.insert(newTag.id)
                                newTagName = ""
                                filteredTags = allTags
                                showingAddTagField = false
                            }
                            .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding()
                    }


                    
                   
                    Section(header: Text("YouTube_Link")) {
                        TextField("Geben Sie den YouTube-Link ein", text: $videoLink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    Toggle("Ist es ein Kuchen?", isOn: $isCake.animation())
                    if isCake {
                        Picker("Kuchenform", selection: $cakeForm) {
                            ForEach(Formen.allCases, id: \.self) { form in
                                Text(form.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        if cakeForm == .rund {
                            HStack {
                                Text("Durchmesser (cm):")
                                TextField("Durchmesser (cm)", text: $size[0] )
#if os(iOS)
                                    .keyboardType(.decimalPad)
#endif
                            }
                        } else {
                            HStack {
                                Text("Länge (cm):")
                                TextField("Länge (cm)", text: $size[1])
#if os(iOS)
                                    .keyboardType(.decimalPad)
#endif
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                Text("Breite (cm):")
                                TextField("Breite (cm)", text: $size[2])
#if os(iOS)
                                    .keyboardType(.decimalPad)
#endif
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                            }
                        }
                    } else {
                        TextField("Portion (Anzahl)", text: $portionValue)
#if os(iOS)
                            .keyboardType(.decimalPad)
#endif
                    }
                }
            }
            
            Section(header: Text("Zutaten")) {
                List {
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                            Picker("Zutat", selection: $foods[index]) {
                                Text("") // Leere Zeichenfolge als Standardoption
                                ForEach(modelView.foods, id: \.self) { food in
                                    Text(food.name)
                                }
                            }
                            Section(header: Text("Menge")) {
                                VStack {
                                    TextField("Menge", text: $quantity[index])
#if os(iOS)
                                        .keyboardType(.decimalPad)
#endif
                                    
                                    Picker("Einheit", selection: $selectedUnit[index]) {
                                        ForEach(Unit.allCases, id: \.self) { unit in
                                            Text(unit.rawValue)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                .padding() // Optional, um den Inhalt zu zentrieren oder auszurichten
                            }
                        }
                    }
                    .onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                        foods.remove(atOffsets: indexSet)
                        quantity.remove(atOffsets: indexSet)
                        selectedUnit.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        ingredients.move(fromOffsets: indices, toOffset: newOffset)
                        foods.move(fromOffsets: indices, toOffset: newOffset)
                        quantity.move(fromOffsets: indices, toOffset: newOffset)
                        selectedUnit.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                Button(action: {
                    ingredients.append(nil)
//                    print(ingredients.count)
                    foods.append(emptyFood)
                    quantity.append("")
                    selectedUnit.append(.gram)
                }) {
                    Label("Zutat hinzufügen", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("Anleitung")) {
                List {
                    ForEach(instructions.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                            TextField("Schritt \(index + 1)", text: $instructions[index])
                        }
                    }
                    .onDelete { indexSet in
                        instructions.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        instructions.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                Button(action: {
                    instructions.append("")
                }) {
                    Label("Schritt hinzufügen", systemImage: "plus.circle")
                }
            }
        }
        .onAppear {
            self.editMode = .active
        }
    }
}

struct OptionsListView: View {
    let options: [String]
    @Binding var selectedOption: String?
    @Binding var searchText: String

    var body: some View {
        List(options, id: \.self) { option in
            Button(action: {
                selectedOption = option
                searchText = option // Set the searchText to the selected option
            }) {
                Text(option)
            }
        }
    }
}
