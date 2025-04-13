//
//  RecipePreviewView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 17.03.25.
//

import SwiftUI

/// Eine Ansicht zur Vorschau eines Rezepts mit Optionen zum Speichern oder Abbrechen.
struct RecipePreviewView: View {
    let recipe: Recipe // Das anzuzeigende Rezept
    var onSave: () -> Void // Aktion, die beim Speichern ausgeführt wird
    var onCancel: () -> Void // Aktion, die beim Abbrechen ausgeführt wird
    @State private var saved: Bool = false // Status, ob das Rezept gespeichert wurde

    @Environment(\.presentationMode) var presentationMode // Umgebungseigenschaft zur Steuerung der Ansicht

    var body: some View {
        NavigationView { // NavigationView ermöglicht eine Navigationsleiste oben
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // 📷 Rezeptbild anzeigen (falls vorhanden)
                    if let imagePath = recipe.image,
                       let uiImage = UIImage(contentsOfFile: imagePath)
                    {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                    } else {
                        // 🔲 Platzhaltertext, wenn kein Bild verfügbar ist
                        Text("Kein Bild verfügbar")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }

                    // 🧂 Zutatenliste
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🧂 Zutaten")
                            .font(.headline)
                            .padding(.horizontal)

                        // Alle Zutaten des Rezepts auflisten
                        ForEach(recipe.ingredients, id: \.food.id) { ingredient in
                            Text("• \(ingredient.quantity.cleanFormatted()) \(ingredient.unit.rawValue) \(ingredient.food.name)")
                                .padding(.horizontal)
                        }
                    }

                    // 👩‍🍳 Zubereitungsschritte
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("👩‍🍳 Zubereitung")
                                            .font(.headline)
                                            .padding(.horizontal)

                                        let sortedInstructions = recipe.instructions.sorted { ($0.number ?? 0) < ($1.number ?? 0) }

                                        ForEach(Array(sortedInstructions.enumerated()), id: \.1.id) { index, step in
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(index + 1). \(step.text)")
                                                    .padding(.horizontal)

                                                if !step.uuids.isEmpty {
                                                    Text("↪ Verknüpfte IDs: \(step.uuids.map { $0.uuidString.prefix(8) }.joined(separator: ", "))")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                        .padding(.horizontal)
                                                }
                                            }
                                        }
                                    }

                                }
                .padding(.vertical)
                .padding(.horizontal) // ➕ fügt links und rechts Abstand hinzu
            }
            .navigationTitle(recipe.title) // Titel der Navigation = Rezeptname
            .toolbar {
                // 🔙 Abbrechen-Button (links)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        onCancel() // Aktion ausführen
                        presentationMode.wrappedValue.dismiss() // Ansicht schließen
                    }
                }

                // 💾 Speichern-Button (rechts)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saved = true // Zustand speichern
                        onSave() // Aktion ausführen
                        presentationMode.wrappedValue.dismiss() // Ansicht schließen
                    }
                }
            }
            .onDisappear {
                // Wenn geschlossen wird, ohne zu speichern, Abbruchaktion ausführen
                if !saved {
                    onCancel()
                }
            }
        }
    }
}
