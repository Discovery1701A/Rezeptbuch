//
//  IngredientRow.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.04.25.
//

import SwiftUI

// Diese View stellt eine einzelne Zutatenzeile dar.
struct IngredientRow: View {
    // Abfrage der horizontalen Größe (compact oder regular), z. B. auf iPhone oder iPad.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Index der Zutat in der Liste
    let index: Int
    
    // Bindings zu den relevanten Werten der Zutat: Lebensmittel, Menge, Einheit
    @Binding var food: FoodStruct
    @Binding var quantity: String
    @Binding var selectedUnit: Unit

    // Liste aller verfügbaren Zutaten (für die Suche)
    let allFoods: [FoodStruct]
    

    var modelView: ViewModel
    
    // Callback-Funktion, um die Zutat zu löschen
    let onDelete: () -> Void

    // Zeigt, ob das Suchsheet geöffnet ist
    @State private var showingIngredientSearch = false

    var body: some View {
        HStack {
            // Zeigt den Index der Zutat (beginnend bei 1)
            Text("\(index + 1).")
                .textSelection(.disabled) // Verhindert Textauswahl

            // Button zur Auswahl einer Zutat über ein Sheet
            Button(action: {
                showingIngredientSearch = true
            }) {
                Text(food.name.isEmpty ? "Zutat auswählen" : food.name)
                    .foregroundColor(.blue)
                    .textSelection(.disabled)
            }
            // Sheet zur Zutatensuche, wird angezeigt, wenn der Button gedrückt wird
            .sheet(isPresented: $showingIngredientSearch) {
                IngredientSearchView(
                    selectedFood: $food,
                    allFoods: allFoods,
                    modelView: modelView
                )
            }

            // Layout-Anpassung je nach Gerätegröße (iPhone vs. iPad)
            if horizontalSizeClass == .compact {
                // Kompakte Darstellung (z. B. iPhone): zwei vertikale Blöcke für Menge und Einheit
                VStack(alignment: .leading, spacing: 4) {
                    Text("Menge")
                        .textSelection(.disabled)
                    TextField("Menge", text: $quantity)
#if os(iOS)
                        .keyboardType(.decimalPad)
#endif
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Einheit")
                        .textSelection(.disabled)
                    Picker("", selection: $selectedUnit) {
                        ForEach(Unit.allCases, id: \.self) { unit in
                            Text(unit.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Menüauswahl bei kompaktem Layout
                }
            } else {
                // Breite Darstellung (z. B. iPad): Menge und Einheit in einer horizontalen Zeile
                HStack {
                    Text("Menge")
                        .textSelection(.disabled)
                    TextField("Menge", text: $quantity)
#if os(iOS)
                        .keyboardType(.decimalPad)
#endif
                    // Segmentierte Auswahl für Einheiten (direkte Auswahl sichtbar)
                    Picker("Einheit", selection: $selectedUnit) {
                        ForEach(Unit.allCases, id: \.self) { unit in
                            Text(unit.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding() // etwas Abstand innen für bessere Optik
            }
        }
    }
}
