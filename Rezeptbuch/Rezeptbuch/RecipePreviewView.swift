//
//  RecipePreviewView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 17.03.25.
//


import SwiftUI

struct RecipePreviewView: View {
    let recipe: Recipe
    var onSave: () -> Void

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Text(recipe.title)
                    .font(.title)
                    .padding()

                List {
                    Section(header: Text("Zutaten")) {
                        ForEach(recipe.ingredients, id: \.food.id) { ingredient in
                            Text("\(ingredient.quantity) \(ingredient.unit.rawValue) \(ingredient.food.name)")
                        }
                    }

                    Section(header: Text("Zubereitung")) {
                        ForEach(recipe.instructions, id: \.self) { step in
                            Text(step)
                        }
                    }
                }
            }
            .navigationTitle("Rezept Vorschau")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
