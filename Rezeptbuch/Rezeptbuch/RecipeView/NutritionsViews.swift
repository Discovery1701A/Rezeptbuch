//
//  NutritionsViews.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 09.03.25.
//

import SwiftUICore

/// Struktur zur Berechnung und Speicherung der Nährwertzusammenfassung eines Rezepts oder einer Mahlzeit.
struct NutritionSummary {
    var totalCalories: Int = 0  // Gesamtanzahl der Kalorien
    var totalProtein: Double = 0.0  // Gesamtmenge an Protein in Gramm
    var totalCarbohydrates: Double = 0.0  // Gesamtmenge an Kohlenhydraten in Gramm
    var totalFat: Double = 0.0  // Gesamtmenge an Fett in Gramm
    var missingStings: [String] = []  // Liste der fehlenden Informationen

    /// Berechnet die Nährwerte basierend auf den angegebenen Zutaten.
    mutating func calculate(from items: [FoodItemStruct]) {
        // Setze Werte zurück, um neue Berechnung durchzuführen
        totalCalories = 0
        totalProtein = 0.0
        totalCarbohydrates = 0.0
        totalFat = 0.0

        for item in items {
            // Überprüfung auf fehlende Dichte oder unvollständige Nährwertangaben
            if item.food.density == nil || item.food.density ?? 0 <= 0 {
                missingStings.append("\(item.food.name) hat keine Dichte")
            }
            if item.food.nutritionFacts == nil || item.food.nutritionFacts?.calories == nil || item.food.nutritionFacts?.calories ?? 0 < 0 || item.food.nutritionFacts?.protein == nil || item.food.nutritionFacts?.protein ?? 0 < 0 || item.food.nutritionFacts?.carbohydrates == nil || item.food.nutritionFacts?.carbohydrates ?? 0 < 0 || item.food.nutritionFacts?.fat == nil || item.food.nutritionFacts?.fat ?? 0 < 0 {
                missingStings.append("\(item.food.name) hat fehlende Nährwerte")
            }
            
            // Falls die Einheit "Stück" ist, kann keine vollständige Berechnung erfolgen
            if item.unit == .piece {
                missingStings.append("\(item.food.name) hat eine Stückmenge, daher ist die Berechnung nicht vollständig.")
            } else {
                if let nutrition = item.food.nutritionFacts {
                    let convertedQuantity = Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0
                    
                    totalCalories += Int(Double(nutrition.calories ?? 0) * convertedQuantity / 100)
                    totalProtein += (nutrition.protein ?? 0.0) * convertedQuantity / 100
                    totalCarbohydrates += (nutrition.carbohydrates ?? 0.0) * convertedQuantity / 100
                    totalFat += (nutrition.fat ?? 0.0) * convertedQuantity / 100
                }
            }
        }
    }
}

/// Ansicht zur Darstellung einer zusammengefassten Nährwertübersicht.
struct NutritionSummaryView: View {
    let summary: NutritionSummary  // Berechnete Nährwerte
    let maxBarHeight: CGFloat = 150  // Maximale Höhe für die höchsten Balken

    var body: some View {
        let maxValue = max(summary.totalCalories,
                           Int(summary.totalProtein),
                           Int(summary.totalCarbohydrates),
                           Int(summary.totalFat),
                           1) // Verhindert Division durch 0

        VStack {
            Text("Nährwerte")
                .font(.headline)
                .padding()
            
            // Falls fehlende Daten existieren, wird eine Warnung ausgegeben
            if !summary.missingStings.isEmpty {
                Text("Es wurden bei der Berechnung nicht alle Zutaten berücksichtigt.")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            
            // Balkendiagramm zur Visualisierung der Nährwerte
            HStack {
                NutritionBar(value: summary.totalCalories, maxValue: maxValue, label: "Kalorien", color: .red, maxHeight: maxBarHeight)
                NutritionBar(value: Int(summary.totalProtein), maxValue: maxValue, label: "Protein", color: .blue, maxHeight: maxBarHeight)
                NutritionBar(value: Int(summary.totalCarbohydrates), maxValue: maxValue, label: "Kohlenhydrate", color: .green, maxHeight: maxBarHeight)
                NutritionBar(value: Int(summary.totalFat), maxValue: maxValue, label: "Fett", color: .yellow, maxHeight: maxBarHeight)
            }
            .padding()
        }
    }
}

/// Eine einzelne Balkendarstellung für die Nährwerte.
struct NutritionBar: View {
    var value: Int  // Wert für den Balken
    var maxValue: Int  // Höchster Wert zur relativen Skalierung
    var label: String  // Name des Nährstoffs
    var color: Color  // Farbe des Balkens
    let maxHeight: CGFloat  // Maximale Balkenhöhe

    var body: some View {
        let barHeight = CGFloat(value) / CGFloat(maxValue) * maxHeight  // Relative Skalierung

        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
            
            Rectangle()
                .fill(color)
                .frame(width: 20, height: max(10, barHeight)) // Mindestens 10, damit der Balken nicht unsichtbar wird
                .cornerRadius(5)
            
            Text("\(value)")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(5)
    }
}
