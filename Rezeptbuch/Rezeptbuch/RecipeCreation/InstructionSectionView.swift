//
//  InstructionSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 25.04.25.
//

import SwiftUI
// Diese View stellt einen Abschnitt zur Verwaltung der Rezept-Anleitung (Schritt-für-Schritt) dar.
struct InstructionSectionView: View {
    // Liste aller Anweisungsschritte mit Bindung an den Haupt-View
    @Binding var instructions: [InstructionItem]

    var body: some View {
        // Formularabschnitt mit Überschrift
        Section(header: Text("Anleitung")) {
            List {
                // Für jeden Eintrag in der Anleitung wird eine Zeile dargestellt
                ForEach($instructions) { $item in
                    VStack(alignment: .leading, spacing: 4) {
                        // Zeigt die Schritt-Nummer, falls vorhanden
                        if let number = item.number {
                            Text("Schritt \(number)")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }

                        // Eingabefeld für die Beschreibung des Schritts
                        TextField("Schrittbeschreibung", text: $item.text)
                    }
                    .padding(.vertical, 4) // Etwas Abstand zwischen den Schritten
                }

                // Löschen einzelner Schritte (z. B. per Swipe)
                .onDelete { indexSet in
                    instructions.remove(atOffsets: indexSet)
                    updateInstructionNumbers() // Aktualisiert die Schritt-Nummerierung
                }

                // Verschieben von Schritten (Drag & Drop)
                .onMove { indices, newOffset in
                    instructions.move(fromOffsets: indices, toOffset: newOffset)
                    updateInstructionNumbers() // Aktualisiert die Schritt-Nummerierung
                }
            }

            // Button zum Hinzufügen eines neuen Schritts am Ende der Liste
            Button(action: {
                instructions.append(
                    InstructionItem(number: instructions.count + 1, text: "", uuids: [])
                )
            }) {
                Label("Schritt hinzufügen", systemImage: "plus.circle")
            }
        }
    }

    // Aktualisiert die Schritt-Nummern entsprechend der aktuellen Reihenfolge
    private func updateInstructionNumbers() {
        for (index, _) in instructions.enumerated() {
            instructions[index].number = index + 1
        }
    }
}
