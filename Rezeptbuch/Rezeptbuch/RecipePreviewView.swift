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
    var onCancel: () -> Void
    @State private var saved: Bool = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Bildanzeige, falls vorhanden
                    if let imagePath = recipe.image, let uiImage = UIImage(contentsOfFile: imagePath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                    } else {
                        Text("Kein Bild verfügbar")
                            .foregroundColor(.gray)
                            .padding()
                    }

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
            }
            .navigationTitle(recipe.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        onCancel()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saved = true
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onDisappear {
                if !saved {
                    onCancel()
                }
            }
        }
    }
}

