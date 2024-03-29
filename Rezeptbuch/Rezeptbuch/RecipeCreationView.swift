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
    @State private var ingredients: [FoodItem?] = []
    @State private var foodstring: [String] = []
    @State private var foods: [Food] = []
    @State private var instructions: [String] = []
    @State private var quantity: [String] = []
    @State private var selectedUnit: [Unit] = []

    #if os(macOS)
    @State private var editMode: EditMode = .inactive // Verwenden Sie den Bearbeitungsmodus von SwiftUI

    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement:.confirmationAction) {
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
        } .navigationViewStyle(StackNavigationViewStyle()) // Hier wird der Modifier hinzugefügt
    }
    #endif

    private func saveRecipe() {
        
        for i in 0..<ingredients.count{
            if foods[i] != emptyFood{
                ingredients[i] = FoodItem(food: foods[i],
                                          unit:  selectedUnit[i],
                                          quantity:  Double(quantity[i])!)
            }
        }
        
        ingredients.removeAll(where: { $0 == nil })
        let recipe = Recipe(id: modelView.recipes.count + 1, title: recipeTitle, ingredients: ingredients.compactMap { $0 }, instructions: instructions)
        modelView.appendToRecipes(recipe: recipe)
    }


    var content: some View {
        Form {
            Section(header: Text("Allgemeine Informationen")) {
                TextField("Rezept-Titel", text: $recipeTitle)
            }

            Section(header: Text("Zutaten")) {
                List {
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
//                            Picker("Zutat", selection: $foods[index]) {
//                                Text("") // Leere Zeichenfolge als Standardoption
//                                ForEach(modelView.foods, id: \.self) { food in
//                                    Text(food.name)
//                                }
//                            }
                            Section(header: Text("Menge")) {
                                VStack {
                                    TextField("Menge", text: $quantity[index])
                                        .keyboardType(.decimalPad)

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
