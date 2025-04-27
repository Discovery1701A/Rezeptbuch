//
//  RecipeInstructionsView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import SwiftUI
/// Stellt die Kochanweisungen für ein Rezept grafisch schön dar.
struct RecipeInstructionsView: View {
    var instructions: [InstructionItem] // Liste der Anweisungen des Rezepts

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Überschrift
            Text("Anleitung")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 5)

            VStack(alignment: .leading, spacing: 8) {
                // Sortiert die Anweisungen nach Nummer, falls diese vorhanden sind
                let sortedInstructions = instructions.sorted { ($0.number ?? 0) < ($1.number ?? 0) }

                // Zeigt jede Anweisung einzeln an
                ForEach(Array(sortedInstructions.enumerated()), id: \.1.id) { index, item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 8) {
                            // Schritt-Nummer
                            Text("\(index + 1).")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)

                            // Beschreibung des Schritts
                            Text(item.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Wenn die Anweisung UUID-Verknüpfungen hat (z. B. zu Zutaten), werden sie angezeigt
                        if !item.uuids.isEmpty {
                            Text("Verknüpfte UUIDs: \(item.uuids.map { $0.uuidString.prefix(8) }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6)) // Grauer Hintergrund für jede Anweisung
                    .cornerRadius(8) // Abgerundete Ecken
                }
            }
        }
        .padding() // Gesamtpadding für die Ansicht
    }
}
