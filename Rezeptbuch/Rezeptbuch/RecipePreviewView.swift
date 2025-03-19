//
//  RecipePreviewView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 17.03.25.
//

import SwiftUI

/// Eine Ansicht zur Vorschau eines Rezepts mit Optionen zum Speichern oder Abbrechen.
struct RecipePreviewView: View {
    let recipe: Recipe  // Das anzuzeigende Rezept
    var onSave: () -> Void  // Aktion, die ausgeführt wird, wenn das Rezept gespeichert wird
    var onCancel: () -> Void  // Aktion, die ausgeführt wird, wenn das Rezept abgebrochen wird
    @State private var saved: Bool = false  // Status, ob das Rezept gespeichert wurde

    @Environment(\.presentationMode) var presentationMode  // Umgebungseigenschaft zur Steuerung der Darstellung

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Falls das Rezept ein Bild hat, wird es angezeigt
                    if let imagePath = recipe.image, let uiImage = UIImage(contentsOfFile: imagePath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                    } else {
                        // Platzhalter-Text, falls kein Bild vorhanden ist
                        Text("Kein Bild verfügbar")
                            .foregroundColor(.gray)
                            .padding()
                    }

                    // Liste mit Zutaten und Zubereitungsschritten
                    List {
                        // Zutatenliste
                        Section(header: Text("Zutaten")) {
                            ForEach(recipe.ingredients, id: \.food.id) { ingredient in
                                Text("\(ingredient.quantity) \(ingredient.unit.rawValue) \(ingredient.food.name)")
                            }
                        }

                        // Zubereitungsschritte
                        Section(header: Text("Zubereitung")) {
                            ForEach(recipe.instructions, id: \.self) { step in
                                Text(step)
                            }
                        }
                    }
                }
            }
            .navigationTitle(recipe.title)  // Titel der Navigation ist der Rezeptname
            .toolbar {
                // Abbrechen-Button in der Navigationsleiste (links)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        onCancel()  // Abbruch-Aktion ausführen
                        presentationMode.wrappedValue.dismiss()  // Ansicht schließen
                    }
                }
                // Speichern-Button in der Navigationsleiste (rechts)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saved = true  // Speichern-Status setzen
                        onSave()  // Speichern-Aktion ausführen
                        presentationMode.wrappedValue.dismiss()  // Ansicht schließen
                    }
                }
            }
            .onDisappear {
                // Falls die Ansicht geschlossen wird, ohne dass gespeichert wurde, rufe `onCancel` auf
                if !saved {
                    onCancel()
                }
            }
        }
    }
}
