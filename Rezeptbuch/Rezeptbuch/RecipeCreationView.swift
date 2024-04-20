//
//  RecipeCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 13.03.24.
//
import SwiftUI

struct ValidationError: Identifiable {
    let id = UUID()
    var message: String
}

struct RecipeCreationView: View {
    @ObservedObject var modelView: ViewModel
      @State private var recipeTitle = ""
      @State private var ingredients: [FoodItemStruct?] = []
      @State private var foods: [FoodStruct] = []
      @State private var instructions: [String] = []
      @State private var quantity: [String] = []
      @State private var selectedUnit: [Unit] = []
      @State private var portionValue: String = ""
      @State private var isCake = false
      @State private var cakeForm: Formen = .rund
      @State private var size: [Double] = [0.0, 0.0, 0.0]
      @State private var cakeSize: CakeSize = .round(diameter: 0.0)
      @State private var recipeImage: UIImage?
      @State private var showingImagePicker = false
      @State private var isTargeted = false
      @State private var validationError: ValidationError?
      @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary // Neue State Variable

       

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

    private func validateInputs() -> Bool {
        var error: ValidationError? // Fehlerobjekt erstellen

        if recipeTitle.isEmpty {
            error = ValidationError(message: "Bitte geben Sie einen Titel für das Rezept ein.")
        } else if isCake {
            if cakeForm == .rund && size[0] <= 0 {
                error = ValidationError(message: "Bitte geben Sie einen gültigen Durchmesser für den Kuchen ein.")
            } else if cakeForm == .eckig && (size[1] <= 0 || size[2] <= 0) {
                error = ValidationError(message: "Bitte geben Sie eine gültige Länge und Breite für den Kuchen ein.")
            }
        } else if Double(portionValue) ?? 0.0 <= 0 {
            error = ValidationError(message: "Bitte geben Sie eine gültige Portionsgröße ein.")
        }
        print(foods.count)
        if foods.isEmpty{
            error = ValidationError(message: "Bitte fügen Sie eine Zutate hinzu.")
        }
        for (index, ingredient) in foods.enumerated() {
            
            if ingredient == emptyFood {
                print("neinnnn")
                error = ValidationError(message: "Bitte füllen Sie alle Zutaten aus.")
            } else if quantity[index].isEmpty || Double(quantity[index]) == nil || Double(quantity[index])! <= 0 {
                error = ValidationError(message: "Bitte geben Sie eine gültige Menge für alle Zutaten ein.")
            }
        }
        if instructions.isEmpty{
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



        private func saveRecipe() {
            for i in 0 ..< ingredients.count {
                if foods[i] != emptyFood {
                    ingredients[i] = FoodItemStruct(food: foods[i],
                                                    unit: selectedUnit[i],
                                                    quantity: Double(quantity[i])!)
                    print(ingredients[i])
                }
            }

            ingredients.removeAll(where: { $0 == nil })
            let recipe: Recipe
          
            if let image = recipeImage, let imagePath = saveImageLocally(image: image) {
                recipe = Recipe(id: modelView.recipes.count + 1,
                                    title: recipeTitle,
                                    ingredients: ingredients.compactMap { $0 },
                                    instructions: instructions,
                                    image: imagePath, // Pfad zur Bilddatei
                                    portion: isCake ? .notPortion : .Portion(Double(portionValue) ?? 0.0),
                                    cake: isCake ? .cake(form: cakeForm, size: cakeSize) : .notCake)
            } else {
                if isCake {
                    recipe = Recipe(id: modelView.recipes.count + 1,
                                    title: recipeTitle,
                                    ingredients: ingredients.compactMap { $0 },
                                    instructions: instructions,
                                    image: nil,
                                    portion: .notPortion,
                                    cake: .cake(form: cakeForm, size: cakeSize))
                } else {
                    recipe = Recipe(id: modelView.recipes.count + 1,
                                    title: recipeTitle,
                                    ingredients: ingredients.compactMap { $0 },
                                    instructions: instructions,
                                    image: nil,
                                    portion: .Portion(Double(portionValue) ?? 0.0),
                                    cake: .notCake)
                }
            }
                    
            print("ja")
            CoreDataManager().saveRecipe(recipe)
            modelView.updateRecipe()
        }
    private func loadImage() {
            guard let inputImage = recipeImage else { return }
            // Additional processing of the loaded image, if needed
        }

    var content: some View {
        Form {
            Section(header: Text("Allgemeine Informationen")) {
                VStack {
                    TextField("Rezept-Titel", text: $recipeTitle)
                    
                    Section(header: Text("Bild auswählen")) {
                        HStack {
                            Button(action: {
                                self.showingImagePicker = true
                                self.sourceType = .camera
                            }) {
                                Label("Kamera", systemImage: "camera")
                            }
                            Button(action: {
                                self.showingImagePicker = true
                                self.sourceType = .photoLibrary
                            }) {
                                Label("Galerie", systemImage: "photo.on.rectangle")
                            }
                        }
                        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                            ImagePicker(image: self.$recipeImage, sourceType: self.sourceType)
                        }
                        .onDrop(of: ["public.image"], isTargeted: $isTargeted) { providers, location in
                            providers.first?.loadObject(ofClass: UIImage.self, completionHandler: { image, error in
                                DispatchQueue.main.async {
                                    if let image = image as? UIImage {
                                        self.recipeImage = image
                                    }
                                }
                            })
                            return true
                        }
                        
                        if let image = recipeImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                        }
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
                                TextField("Durchmesser (cm)", text: Binding(
                                    get: { "\(size[0])" },
                                    set: {
                                        if let value = Double($0) {
                                            cakeSize = .round(diameter: value)
                                        }
                                    }))
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                #endif
                            }
                        } else {
                            HStack {
                                Text("Länge (cm):")
                                TextField("Länge (cm)", text: Binding(
                                    get: { "\(size[1])" },
                                    set: {
                                        if let value = Double($0) {
                                            cakeSize = .rectangular(length: value, width: size[2])
                                        }
                                    }))
#if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                Text("Breite (cm):")
                                TextField("Breite (cm)", text: Binding(
                                    get: { "\(size[2])" },
                                    set: {
                                        if let value = Double($0) {
                                            cakeSize = .rectangular(length: size[1], width: value)
                                        }
                                    }))
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





struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
