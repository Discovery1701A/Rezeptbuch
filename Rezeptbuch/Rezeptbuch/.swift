//
//  Ingredient.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.04.25.
//

struct IngredientBoardView: View {
    @State private var ungroupedIngredients: [EditableIngredient] = [
        EditableIngredient(), EditableIngredient()
    ]
    @State private var components: [IngredientComponent] = [
        IngredientComponent(name: "Creme", ingredients: [EditableIngredient(), EditableIngredient()]),
        IngredientComponent(name: "Boden", ingredients: [EditableIngredient(), EditableIngredient()])
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Button(action: {
                    components.append(IngredientComponent(name: "Neue Komponente", ingredients: []))
                }) {
                    Label("Komponente hinzufügen", systemImage: "plus.rectangle.on.rectangle")
                        .padding(.horizontal)
                }

                // Ungruppierte Zutaten
                ComponentColumnView(title: "", ingredients: $ungroupedIngredients)

                // Komponenten-Blöcke
                ForEach($components) { $component in
                    ComponentColumnView(title: component.name, ingredients: $component.ingredients)
                }
            }
            .padding()
        }
    }
}

struct ComponentColumnView: View {
    var title: String
    @Binding var ingredients: [EditableIngredient]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .padding(.vertical, 4)
            }

            ForEach($ingredients) { $ingredient in
                IngredientRow(
                    index: ingredients.firstIndex(where: { $0.id == ingredient.id }) ?? 0,
                    food: $ingredient.food,
                    quantity: $ingredient.quantity,
                    selectedUnit: $ingredient.unit,
                    allFoods: [], // später anpassen
                    modelView: ViewModel(),
                    onDelete: {
                        if let index = ingredients.firstIndex(of: ingredient) {
                            ingredients.remove(at: index)
                        }
                    }
                )
            }

            Button(action: {
                ingredients.append(EditableIngredient())
            }) {
                Label("Zutat hinzufügen", systemImage: "plus.circle")
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

