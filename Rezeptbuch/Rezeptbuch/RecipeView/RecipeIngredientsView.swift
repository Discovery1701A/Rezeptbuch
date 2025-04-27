//
//  RecipeIngredientsView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import SwiftUI

/// Stellt die Zutaten eines Rezepts dar und ermöglicht das Bearbeiten einzelner Mengen.
struct RecipeIngredientsView: View {
    @Binding var ingredients: [FoodItemStruct] // Zutaten des Rezepts (bindet an die übergebene Quelle)
    @State private var orignIngredients: [FoodItemStruct] // Ursprüngliche Zutatenliste (zum Vergleich beim Anpassen)
    @State private var selectedIngredient: FoodItemStruct? = nil // Gewählte Zutat für Bearbeitung
    @State private var editedQuantity: String = "" // Bearbeitete Menge als Text
    @State private var selectedUnit: Unit = .gram // Gewählte Einheit beim Bearbeiten
    @State private var selectedFood: FoodStruct? = nil // Gewähltes Lebensmittel zur Detailansicht
    var modelView: ViewModel // Zugriff auf zentrale Daten

    /// Initialisiert die Ansicht und kopiert die originale Zutatenliste.
    init(ingredients: Binding<[FoodItemStruct]>, modelView: ViewModel) {
        self._ingredients = ingredients
        self._orignIngredients = State(initialValue: ingredients.wrappedValue)
        self.modelView = modelView
    }

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text("Zutaten:")
                .font(.headline)
                .multilineTextAlignment(.center)

            // Jede Zutat einzeln darstellen
            ForEach(Array(ingredients.indices), id: \.self) { index in
                ingredientRow(for: index)
            }
        }
        .padding()
        // Öffnet bei LongPress die Detailansicht einer Zutat
        .sheet(item: $selectedFood) { food in
            FoodDetailView(food: food, modelView: modelView)
        }
        // Öffnet bei LongPress die Bearbeitungsansicht für Menge/Einheit
        .sheet(item: $selectedIngredient) { ingredient in
            EditIngredientPopup(
                ingredient: binding(for: ingredient),
                editedQuantity: $editedQuantity,
                selectedUnit: $selectedUnit,
                onSave: { newQuantity, newUnit in
                    saveEditedIngredient(ingredient, newQuantity: newQuantity, newUnit: newUnit)
                },
                onClose: {
                    selectedIngredient = nil
                }
            )
        }
    }

    // MARK: - Views

    /// Baut die Ansicht einer einzelnen Zutat auf
    @ViewBuilder
    private func ingredientRow(for index: Int) -> some View {
        let ingredient = ingredients[index]

        HStack {
            VStack(alignment: .center) {
                // Name der Zutat
                Text("\(ingredient.food.name)")
                    .font(.body)
                    .onLongPressGesture {
                        selectedFood = ingredient.food
                    }

                // Menge + Einheit
                HStack {
                    Text(ingredient.quantity.cleanFormatted())
                        .font(.subheadline)
                    Text(ingredient.unit.rawValue)
                        .font(.subheadline)
                }
                .onLongPressGesture {
                    preparePopup(for: index)
                }
                .padding(.bottom, 5)
            }
        }
        .padding()
    }

    // MARK: - Binding

    /// Erzeugt ein Binding für eine bestimmte Zutat
    private func binding(for ingredient: FoodItemStruct) -> Binding<FoodItemStruct> {
        Binding(
            get: {
                ingredients.first(where: { $0.id == ingredient.id }) ?? ingredient
            },
            set: { updatedIngredient in
                if let index = ingredients.firstIndex(where: { $0.id == updatedIngredient.id }) {
                    ingredients[index] = updatedIngredient
                }
            }
        )
    }

    // MARK: - Actions

    /// Bereitet das Bearbeiten-Popup für eine Zutat vor
    private func preparePopup(for index: Int) {
        let ingredient = ingredients[index]
        selectedIngredient = ingredient
        editedQuantity = String(ingredient.quantity)
        selectedUnit = ingredient.unit
    }

    /// Speichert die bearbeitete Menge und passt ggf. die anderen Zutaten an
    private func saveEditedIngredient(_ ingredient: FoodItemStruct, newQuantity: Double, newUnit: Unit) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) else { return }

        ingredients[index].quantity = newQuantity
        ingredients[index].unit = newUnit
        print("✅ Neue Menge gespeichert: \(ingredients[index].quantity) \(ingredients[index].unit.rawValue)")

        adjustOtherIngredients(for: ingredient)
    }

    /// Passt die anderen Zutaten an, wenn eine Menge geändert wird (Skalierung)
    private func adjustOtherIngredients(for ingredient: FoodItemStruct) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) else { return }

        let oldQuantity = orignIngredients[index].quantity
        let newQuantity = Unit.convert(
            value: ingredients[index].quantity,
            from: ingredients[index].unit,
            to: orignIngredients[index].unit,
            density: ingredients[index].food.density ?? 0
        ) ?? ingredients[index].quantity

        let adjustmentFactor = newQuantity / oldQuantity

        for i in ingredients.indices where i != index {
            if ingredients[i].unit != .piece {
                // Umrechnen nur für Mengen, nicht für Stückzahlen
                ingredients[i].quantity = Unit.convert(
                    value: adjustmentFactor * orignIngredients[i].quantity,
                    from: orignIngredients[i].unit,
                    to: ingredients[i].unit,
                    density: ingredients[i].food.density ?? 0
                ) ?? ingredients[i].quantity
            } else {
                // Stückzahlen werden direkt skaliert
                ingredients[i].quantity = adjustmentFactor * orignIngredients[i].quantity
            }
        }
    }
}
