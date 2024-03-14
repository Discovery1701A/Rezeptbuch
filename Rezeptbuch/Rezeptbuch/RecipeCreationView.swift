//
//  RecipeCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 13.03.24.
//

import SwiftUI

struct RecipeCreationView: View {
    @State private var recipeTitle = ""
    @State private var ingredients: [String] = []
    @State private var instructions: [String] = []

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Rezept erstellen")
                .toolbar {
                    #if !os(macOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    #endif
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        print(newOffset)
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
    }
}

struct RecipeCreationView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCreationView()
    }
}
