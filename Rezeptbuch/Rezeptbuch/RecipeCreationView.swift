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
    @State private var ingredients: [String] = []
    @State private var instructions: [String] = []
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

    private func saveRecipe() {
        modelView.appendToRecipes(recipe: Recipe(id: modelView.recepis.count + 1, title: recipeTitle, ingredients: ingredients, instructions: instructions))
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
                            TextField("Zutat \(index + 1)", text: $ingredients[index])
                        }
                    }
                    .onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        ingredients.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                Button(action: {
                    ingredients.append("")
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
