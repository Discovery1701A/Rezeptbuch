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
    @Binding var selectedTab: Int // Binding für Tab-Wechsel
    @Binding var selectedRecipe: UUID?
    @State private var recipe: Recipe
    var onSave: () -> Void // 🔄 Callback, um `RecipeView` zu aktualisieren
        
    
    @Environment(\.presentationMode) var presentationMode // Zugriff auf das PresentationMode Environment

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
    @State private var id: UUID = .init()
    @State private var idToOpen: UUID?
    
    @State private var selectedRecipeBookIDs: Set<UUID> = []
    
    @State private var showingNewRecipeBookDialog = false
    //    @State private var selectedRecipeBookID: UUID?
    @State private var newRecipeBookName = ""
    @State private var newRecipeBookDummyID = UUID()
    @State private var recipeBookSearchText: String = ""
    @State private var filteredRecipeBooks: [RecipebookStruct]
    
    @State private var selectedTags: Set<UUID> = []
    @State private var allTags: [TagStruct]
    @State private var newTagName = ""
    @State private var showingAddTagField = false
    
    @State private var tagSearchText = ""
    @State private var filteredTags: [TagStruct] = []
    @State private var newRecipe: Bool = true
    @State private var shouldNavigateBack = false // Zustand für die Navigation zurück
    @State private var showingIngredientSearch = false
    
    init(recipe: Recipe? = nil, modelView: ViewModel, selectedTab: Binding<Int> = .constant(0), selectedRecipe: Binding<UUID?> = .constant(nil), onSave: @escaping () -> Void) {
        self.modelView = modelView
        self.onSave = onSave
        self.allTags = modelView.tags
        self._selectedTab = selectedTab
        self._selectedRecipe = selectedRecipe
        self.filteredRecipeBooks = modelView.recipeBooks
        
        if let recipe = recipe {
            self.newRecipe = false
            _recipe = State(initialValue: recipe)
            _recipeTitle = State(initialValue: recipe.title)
            _ingredients = State(initialValue: recipe.ingredients)
            _instructions = State(initialValue: recipe.instructions)
            if case .Portion(let portionValue) = recipe.portion {
                self._portionValue = State(initialValue: String(portionValue))
            } else {
                self._portionValue = State(initialValue: "0.0")
            }
            _isCake = State(initialValue: recipe.cake != .notCake || (recipe.cake != nil && recipe.portion == .notPortion))
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
            if let tags = recipe.tags {
                _selectedTags = State(initialValue: Set(tags.map { $0.id }))
            }
            //                print(selectedTags)
            //                print(allTags)
            if let id = recipe.recipeBookIDs {
                _selectedRecipeBookIDs = State(initialValue: Set(id))
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
            _idToOpen = State(initialValue: id)
        }
    }
    
#if os(macOS)
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if validateInputs() {
                            saveRecipe()
                            presentationMode.wrappedValue.dismiss() // Schließt die Ansicht
                        }
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
                        Button("Speichern") {
                            if validateInputs() {
                                saveRecipe()
                                presentationMode.wrappedValue.dismiss() // Schließt die Ansicht
                                selectedRecipe = idToOpen
                                idToOpen = nil
//                                print("dddddddd ", selectedRecipe)
                                selectedTab = 0
                                onSave() // 🔄 Löst das Neuladen in `RecipeView` aus
                            }
                            print(validationError)
                        }
                        .disabled((editMode == .inactive || recipeTitle.isEmpty) && validationError != nil)
                        .alert(item: $validationError) { error in
                            Alert(title: Text("Fehler"), message: Text(error.message), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .environment(\.editMode, $editMode)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
#endif

    private func resetFormFields() {
        recipeTitle = ""
        ingredients = []
        foods = []
        instructions = []
        quantity = []
        selectedUnit = []
        portionValue = ""
        isCake = false
        cakeForm = .rund
        size = ["0.0", "0.0", "0.0"]
        cakeSize = .round(diameter: 0.0)
        info = ""
#if os(macOS)
        recipeImage = nil
#else
        recipeImage = nil
        sourceType = .photoLibrary // Neue State Variable
#endif
        showingImagePicker = false
        isTargeted = false
        validationError = nil
        
        showingCameraPicker = false
        showingPermissionAlert = false
        
        videoLink = ""
        id = UUID()
        
        selectedRecipeBookIDs = []
        
        showingNewRecipeBookDialog = false
        //    @State private var selectedRecipeBookID: UUID?
        newRecipeBookName = ""
        newRecipeBookDummyID = UUID()
        recipeBookSearchText = ""
        filteredRecipeBooks = modelView.recipeBooks
        
        selectedTags = []
        allTags = modelView.tags
        newTagName = ""
        showingAddTagField = false
        
        tagSearchText = ""
        filteredTags = []
        newRecipe = true
        shouldNavigateBack = false // Zustand für die Navigation zurück
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
        guard let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Konnte Application Support-Ordner nicht finden")
            return nil
        }

        // Sicherstellen, dass der Ordner existiert
        if !fileManager.fileExists(atPath: applicationSupport.path) {
            do {
                try fileManager.createDirectory(at: applicationSupport, withIntermediateDirectories: true, attributes: nil)
                print("Application Support-Ordner erstellt: \(applicationSupport.path)")
            } catch {
                print("Fehler beim Erstellen des Application Support-Ordners: \(error)")
                return nil
            }
        }

        let fileName = "\(id).jpeg" // Rezept-ID als Dateiname
        let fileURL = applicationSupport.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            UserDefaults.standard.set(fileName, forKey: "savedImageName") // ❗ Nur den Dateinamen speichern!
            print("Bild gespeichert unter: \(fileURL.path)")
            return fileName // Nur den Dateinamen zurückgeben, nicht den ganzen Pfad
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
                                                quantity: Double(quantity[i])!,
                                                id: UUID())
            }
        }
        
        let videoLinkSav: String? = videoLink.isEmpty ? nil : videoLink
        let infoSav: String? = info.isEmpty ? nil : info
        
        let cakeInfo: CakeInfo = isCake ? .cake(form: cakeForm, size: cakeSize) : .notCake
        let portionInfo: PortionsInfo = isCake ? .notPortion : .Portion(Double(portionValue) ?? 0.0)
        
        var tagsSav: [TagStruct] = []
        for tagID in selectedTags {
            let filteredTags = allTags.filter { $0.id == tagID }
            tagsSav.append(contentsOf: filteredTags)
        }
        var bookSav: [RecipebookStruct] = []
        for bookID in selectedRecipeBookIDs {
            let filteredBooks = filteredRecipeBooks.filter { $0.id == bookID }
            bookSav.append(contentsOf: filteredBooks)
        }
        var imagePath: String? = nil
        if let image = recipeImage, let Path = saveImageLocally(image: image) {
            imagePath = Path
        }
           
        recipe = Recipe(id: id,
                        title: recipeTitle,
                        ingredients: ingredients.compactMap { $0 },
                        instructions: instructions,
                        image: imagePath,
                        portion: portionInfo,
                        cake: cakeInfo,
                        videoLink: videoLinkSav,
                        info: infoSav,
                        tags: tagsSav,
                        recipeBookIDs: Array(selectedRecipeBookIDs))
         
        //        print("ja")
        // Speichern des Rezepts im Datenmanager
        
        // Zuordnen des Rezepts zum ausgewählten Rezeptbuch
        
        print(recipe)
        if newRecipe {
            CoreDataManager().saveRecipe(recipe)
        } else {
            print("updatteeeee")
            CoreDataManager().updateRecipe(recipe)
            print("perfekt")
        }
        
        for book in bookSav {
            CoreDataManager().addRecipe(recipe, toRecipeBook: book)
        }
        
        modelView.updateRecipe()
        modelView.updateFood()
        modelView.updateTags()
        modelView.updateBooks()
        resetFormFields()
        
        print("durch")
    }
    
    func addNewRecipeBook() {
        let newBook = RecipebookStruct(name: newRecipeBookName, recipes: [])
        modelView.recipeBooks.append(newBook)
        selectedRecipeBookIDs.insert(newBook.id) // Optional: automatisch auswählen
        newRecipeBookName = "" // Reset
        CoreDataManager().createNewRecipeBook(recipeBookStruct: newBook)
        modelView.updateBooks()
        filteredRecipeBooks = modelView.recipeBooks
        showingNewRecipeBookDialog = false
    }
    
    private func loadImage() {
        guard let inputImage = recipeImage else { return }
        // Additional processing of the loaded image, if needed
    }
    
    var recipeBookPicker: some View {
        VStack {
            TextField("Rezeptbuch suchen...", text: $recipeBookSearchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: recipeBookSearchText) { newValue in
                    if newValue.isEmpty {
                        filteredRecipeBooks = modelView.recipeBooks
                    } else {
                        filteredRecipeBooks = modelView.recipeBooks.filter { $0.name.lowercased().contains(newValue.lowercased()) }
                    }
                }
                .onAppear {
                    filteredRecipeBooks = modelView.recipeBooks // Initialfüllung beim Erscheinen der Ansicht
                }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filteredRecipeBooks, id: \.id) { book in
                        Text(book.name)
                            .padding()
                            .background(selectedRecipeBookIDs.contains(book.id) ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .onTapGesture {
                                if selectedRecipeBookIDs.contains(book.id) {
                                    selectedRecipeBookIDs.remove(book.id)
                                } else {
                                    selectedRecipeBookIDs.insert(book.id)
                                }
                            }
                    }
                }
            }
            
            Button("Neues Rezeptbuch hinzufügen") {
                showingNewRecipeBookDialog = true
            }
        }
    }
    
    var newRecipeBookView: some View {
        VStack {
            Text("Neues Rezeptbuch erstellen")
            TextField("Name des Rezeptbuchs", text: $newRecipeBookName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Hinzufügen") {
                let newBook = RecipebookStruct(id: UUID(), name: newRecipeBookName)
                modelView.recipeBooks.append(newBook)
                addNewRecipeBook()
                selectedRecipeBookIDs.insert(newBook.id)
                showingNewRecipeBookDialog = false
                newRecipeBookName = ""
                self.newRecipeBookDummyID = UUID()
            }
            .disabled(newRecipeBookName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
    
    var imagePickerSection: some View {
        VStack {
            Text("Bild auswählen")
                .font(.headline)
                .padding()

            HStack {
#if os(macOS)
                // Verwenden von Text und Image anstelle eines Buttons für macOS
                Text("Bild auswählen")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        openFilePicker()
                    }
#else
                // Kamera-Label als Tap-Geste für iOS
                Label("Kamera", systemImage: "camera")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        self.sourceType = .camera
                        closeOtherPicker(except: "camera")
                        checkCameraPermissions()
                    }
                    .alert(isPresented: $showingPermissionAlert) {
                        Alert(
                            title: Text("Zugriff verweigert"),
                            message: Text("Bitte erlaube den Zugriff auf die Kamera in den Einstellungen deines Geräts."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .sheet(isPresented: $showingCameraPicker) {
                        ImagePicker(image: $recipeImage, sourceType: .camera)
                    }

                Spacer()

                // Galerie-Label als Tap-Geste
                Label("Galerie", systemImage: "photo.on.rectangle")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        self.sourceType = .photoLibrary
                        closeOtherPicker(except: "gallery")
                    }
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: $recipeImage, sourceType: self.sourceType)
                    }
#endif
            }
            .padding()

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
            } else {
                Text("Kein Bild ausgewählt")
            }
#else
            if let image = recipeImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            } else {
                Text("Kein Bild ausgewählt")
            }
#endif
        }
    }

    // Diese Funktion schließt alle anderen Picker, außer dem aktuell ausgewählten
    private func closeOtherPicker(except picker: String) {
        switch picker {
        case "camera":
            showingImagePicker = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingCameraPicker = true
            }
        case "gallery":
            showingCameraPicker = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingImagePicker = true
            }
        default:
            break
        }
    }

    private func checkCameraPermissions() {
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
    
    var tagsSection: some View {
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
    }
    
    var bookSction: some View {
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
    }
    
    var infoSection: some View {
        Section(header: Text("info")) {
            TextField("infos Zum Rezept", text: $info)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
        }
    }
    
    var youTubeSection: some View {
        Section(header: Text("YouTube_Link")) {
            TextField("Geben Sie den YouTube-Link ein", text: $videoLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
    
    var allgemeines: some View {
        Section(header: Text("Allgemeine Informationen")) {
            VStack {
                TextField("Rezept-Titel", text: $recipeTitle)
                
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
                            TextField("Durchmesser (cm)", text: $size[0])
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
    }
    
    var ingriginsSection: some View {
        Section(header: Text("Zutaten")) {
            List {
                ForEach(ingredients.indices, id: \.self) { index in
                    IngredientRow(
                        index: index,
                        food: $foods[index],
                        quantity: $quantity[index],
                        selectedUnit: $selectedUnit[index],
                        allFoods: modelView.foods,
                        modelView: modelView,
                        
                        onDelete: {
                            ingredients.remove(at: index)
                            foods.remove(at: index)
                            quantity.remove(at: index)
                            selectedUnit.remove(at: index)
                        }
                    )
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
                foods.append(emptyFood)
                quantity.append("")
                selectedUnit.append(.gram)
            }) {
                Label("Zutat hinzufügen", systemImage: "plus.circle")
            }
        }
    }

    var insructionSection: some View {
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
    
    var content: some View {
        Form {
            allgemeines
               
            infoSection
               
            youTubeSection
               
            bookSction
               
            tagsSection
               
            imagePickerSection
               
            ingriginsSection

            insructionSection
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

struct IngredientSearchView: View {
    @Binding var selectedFood: FoodStruct // Das ausgewählte Food-Objekt
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedTag: String? = nil
    @State private var showingFoodCreation = false // Zustand für FoodCreationView
    @State private var editingFood: FoodStruct? // Die Zutat, die bearbeitet wird
    @State private var showingEditSheet = false // Zeigt die Bearbeitungsansicht

    @State var allFoods: [FoodStruct]

    var modelView: ViewModel
    var categories: [String] {
        Array(Set(allFoods.compactMap { $0.category })).sorted()
    }
    
    var tagsString: [String] {
        Array(Set(allFoods.compactMap { $0.tags }.flatMap { $0.map { $0.name } })).sorted()
    }

    @Environment(\.dismiss) var dismiss
    
    func updateFoods() {
        allFoods = modelView.foods // Jetzt ist die Zuweisung erlaubt
    }
    
    var filteredFoods: [FoodStruct] {
        allFoods.filter { food in
            (searchText.isEmpty || food.name.lowercased().contains(searchText.lowercased())) &&
                (selectedCategory == nil || food.category == selectedCategory) &&
                (selectedTag == nil || food.tags?.contains(where: { $0.name == selectedTag }) == true)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Suchfeld
                    TextField("Suchen", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
             
                    // Kategorie-Filter mit ScrollView
                    Section(header: Text("Kategorien")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                Button(action: {
                                    selectedCategory = nil
                                }) {
                                    Text("Alle")
                                        .padding()
                                        .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedCategory == nil ? Color.white : Color.primary)
                                        .cornerRadius(8)
                                }
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .padding()
                                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedCategory == category ? Color.white : Color.primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Tag-Filter mit ScrollView
                    Section(header: Text("Tag")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                Button(action: {
                                    selectedTag = nil
                                }) {
                                    Text("Alle")
                                        .padding()
                                        .background(selectedTag == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedTag == nil ? Color.white : Color.primary)
                                        .cornerRadius(8)
                                }
                                ForEach(tagsString, id: \.self) { tag in
                                    Button(action: {
                                        selectedTag = tag
                                    }) {
                                        Text(tag)
                                            .padding()
                                            .background(selectedTag == tag ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedTag == tag ? Color.white : Color.primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    List(filteredFoods) { food in
                        Button(action: {
                            selectedFood = food
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .font(.headline)
                                    if let category = food.category {
                                        Text(category)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer() // Füllt die gesamte Fläche aus
                            }
                            .padding() // Damit die Klickfläche größer ist
                            .contentShape(Rectangle()) // Macht den gesamten Bereich klickbar
                        }
                        .simultaneousGesture(LongPressGesture().onEnded { _ in
                            editingFood = food
                            showingEditSheet = true
                        })
                    }
                    .frame(minHeight: 300) // Optional: Mindesthöhe für die Liste
                }
            }
            .navigationTitle("Zutaten suchen")
            .navigationBarItems(
                leading: Button("Abbrechen", action: {
                    dismiss()
                }),
                trailing: Button(action: {
                    showingFoodCreation = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Neue Zutat")
                    }
                }
            )
            .sheet(isPresented: $showingFoodCreation) {
                FoodCreationView(
                    modelView: modelView,
                    onSave: {
                        showingFoodCreation = false
                        modelView.updateFood()
                        updateFoods()
                    }
                )
            }
            .sheet(isPresented: $showingEditSheet) {
                if let foodToEdit = editingFood {
                    FoodCreationView(
                        modelView: modelView,
                        existingFood: foodToEdit,
                        onSave: {
                            showingEditSheet = false
                            modelView.updateFood()
                            updateFoods()
                        }
                    )
                }
            }
        }
    }
}

struct IngredientRow: View {
    let index: Int
    @Binding var food: FoodStruct
    @Binding var quantity: String
    @Binding var selectedUnit: Unit

    let allFoods: [FoodStruct]
    var modelView: ViewModel
   
    let onDelete: () -> Void

    @State private var showingIngredientSearch = false

    var body: some View {
        HStack {
            Text("\(index + 1).")
            Button(action: {
                showingIngredientSearch = true
            }) {
                Text(food.name == "" ? "Zutat auswählen" : food.name)

                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showingIngredientSearch) {
                IngredientSearchView(
                    selectedFood: $food,
                    allFoods: allFoods,
                    modelView: modelView
                )
            }

            Section(header: Text("Menge")) {
                HStack {
                    TextField("Menge", text: $quantity)
#if os(iOS)
                        .keyboardType(.decimalPad)
#endif
                    Picker("Einheit", selection: $selectedUnit) {
                        ForEach(Unit.allCases, id: \.self) { unit in
                            Text(unit.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
            }
        }
    }
}
