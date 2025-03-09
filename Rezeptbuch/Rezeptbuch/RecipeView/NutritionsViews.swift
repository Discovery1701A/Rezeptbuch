//
//  NutritionsViews.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 09.03.25.
//

import SwiftUICore

// Struktur zur Zusammenfassung der Nährwerte
struct NutritionSummary {
    var totalCalories: Int = 0
    var totalProtein: Double = 0.0
    var totalCarbohydrates: Double = 0.0
    var totalFat: Double = 0.0
    var missingStings: [String] = []

    mutating func calculate(from items: [FoodItemStruct]) {
        totalCalories = 0
        totalProtein = 0.0
        totalCarbohydrates = 0.0
        totalFat = 0.0
       
        for item in items {
            if item.food.density == nil || item.food.density ?? 0 <= 0 {
                missingStings.append("\(item.food.name) hat keine Dichte")
            }
            if item.food.nutritionFacts == nil || item.food.nutritionFacts?.calories == nil || item.food.nutritionFacts?.calories ?? 0 <= 0 || item.food.nutritionFacts?.protein == nil || item.food.nutritionFacts?.protein ?? 0 <= 0 || item.food.nutritionFacts?.carbohydrates == nil || item.food.nutritionFacts?.carbohydrates ?? 0 <= 0 || item.food.nutritionFacts?.fat == nil || item.food.nutritionFacts?.fat ?? 0 <= 0 {
                missingStings.append("\(item.food.name) hat fehlende Nährwerte")
            }
            
            if item.unit == .piece {
                missingStings.append("\(item.food.name) hat eine Stückmenge daher ist die Berechnung nicht vollständing")
            } else {
                if let nutrition = item.food.nutritionFacts {
                    print(nutrition)
                    totalCalories += Int(Double(nutrition.calories ?? 0) * (Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0) / 100)
                    totalProtein += (nutrition.protein ?? 0.0) * (Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0) / 100
                    totalCarbohydrates += (nutrition.carbohydrates ?? 0.0) * (Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0) / 100
                    
                    totalFat += (nutrition.fat ?? 0.0) * (Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0) / 100
                }
            }
        }
    }
}

struct NutritionSummaryView: View {
    let summary: NutritionSummary

    var body: some View {
        VStack {
            Text("Nährwerte")
                .font(.headline)
                .padding()
            if summary.missingStings.count > 0 {
                Text("Es wurden bei der Berechnung nicht alle Zutaten berücksichtigt.")
            }
            HStack {
                NutritionBar(value: summary.totalCalories, label: "Kalorien", color: .red)
                NutritionBar(value: Int(summary.totalProtein), label: "Protein", color: .blue)
                NutritionBar(value: Int(summary.totalCarbohydrates), label: "Kohlenhydrate", color: .green)
                NutritionBar(value: Int(summary.totalFat), label: "Fett", color: .yellow)
            }
            .padding()
        }
    }
}

// Hilfskomponente für Balkendiagramme
struct NutritionBar: View {
    var value: Int
    var label: String
    var color: Color

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .rotationEffect(.degrees(-45))
                .padding(.vertical)
            Text("\(value)")
                .font(.caption)
                .padding(.vertical)
        }
    }
}

