//
//  RecipeCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 13.03.24.
//
import SwiftUI

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

    #if os(macOS)
    @State private var editMode: EditMode = .inactive // Verwenden Sie den Bearbeitungsmodus von SwiftUI

    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        saveRecipe()
                    }) {
                        Text("Speichern")
                    }
                    .disabled(editMode == .inactive || recipeTitle.isEmpty)
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
                            saveRecipe()
                        }) {
                            Text("Speichern")
                        }
                        .disabled(editMode == .inactive || recipeTitle.isEmpty)
                    }
                }
                .environment(\.editMode, $editMode)
        }.navigationViewStyle(StackNavigationViewStyle()) // Hier wird der Modifier hinzugefügt
    }
    #endif

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
        print("ja")
        CoreDataManager().saveRecipe(recipe)
//            modelView.appendToRecipes(recipe: recipe)
        modelView.updateRecipe()
    }

    var content: some View {
        Form {
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
