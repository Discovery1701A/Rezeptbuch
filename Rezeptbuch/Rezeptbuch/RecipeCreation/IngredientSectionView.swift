//
//  IngredientSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 25.04.25.
//

import SwiftUI
// Diese View bildet den Abschnitt für Zutaten im Rezeptformular ab.
// Jede Zutat ist editierbar (Name, Menge, Einheit) und kann verschoben oder gelöscht werden.
struct IngredientSectionView: View {
    // Liste aller aktuell bearbeitbaren Zutaten (mit Bindung an den übergeordneten View)
    @Binding var editableIngredients: [EditableIngredient]

    // Alle verfügbaren Lebensmittel – für die Auswahl in der IngredientRow
    let allFoods: [FoodStruct]

    // Zugriff auf das zentrale ModelView (z. B. für Datenverwaltung)
    var modelView: ViewModel

    var body: some View {
        // Abschnitt mit Überschrift „Zutaten“
        Section(header: Text("Zutaten")) {
            // Zutatenliste mit Bearbeitungsmöglichkeiten
            List {
                // Schleife durch alle Zutaten (mit Index, um Bindings korrekt zu adressieren)
                ForEach(Array(editableIngredients.enumerated()), id: \.element.id) { index, _ in
                    IngredientRow(
                        index: index, // Anzeigenummer der Zutat
                        food: $editableIngredients[index].food, // Binding zum FoodStruct der Zutat
                        quantity: $editableIngredients[index].quantity, // Binding zur Mengenangabe
                        selectedUnit: $editableIngredients[index].unit, // Binding zur Einheit
                        allFoods: allFoods, // Alle verfügbaren Lebensmittel (für Suche)
                        modelView: modelView, // Zugriff auf das ViewModel
                        onDelete: {
                            // Lösche diese Zutat (optional durch Button in IngredientRow)
                            editableIngredients.remove(at: index)
                        }
                    )
                }

                // Unterstützt Swipe-to-Delete
                .onDelete { indexSet in
                    editableIngredients.remove(atOffsets: indexSet)
                }

                // Ermöglicht das Verschieben der Zutaten (Drag & Drop)
                .onMove { indices, newOffset in
                    editableIngredients.move(fromOffsets: indices, toOffset: newOffset)
                }

                // Button zum Hinzufügen einer neuen Zutat
                Button(action: {
                    editableIngredients.append(EditableIngredient())
                }) {
                    Label("Zutat hinzufügen", systemImage: "plus.circle")
                }
            }
        }
    }
}
