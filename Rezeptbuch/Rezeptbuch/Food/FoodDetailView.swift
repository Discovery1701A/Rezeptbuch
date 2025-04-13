//
//  FoodDetailView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.25.
//

import SwiftUI

/// Eine Detailansicht für ein Lebensmittel, das angezeigt und bearbeitet werden kann.
struct FoodDetailView: View {
    @State var food: FoodStruct  // Das anzuzeigende Lebensmittel
    var modelView: ViewModel  // Das ViewModel zur Verwaltung der Daten
    @State private var isEditing = false  // Status, ob sich die Ansicht im Bearbeitungsmodus befindet

    var body: some View {
        Form {
            // Allgemeine Informationen über das Lebensmittel
            Section(header: Text("Allgemeine Informationen")) {
                HStack {
                    Text("Lebensmittelname:")
                    Spacer()
                    Text(food.name)
                }
                if let category = food.category {
                    HStack {
                        Text("Kategorie:")
                        Spacer()
                        Text(category)
                    }
                }
                if let info = food.info {
                    HStack {
                        Text("Info:")
                        Spacer()
                        Text(info)
                    }
                }
                if let density = food.density {
                    HStack {
                        Text("Dichte (g/cm³):")
                        Spacer()
                        Text(String(format: "%.2f", density))
                    }
                }
            }
            
            // Nährwertangaben des Lebensmittels
            if let nutrition = food.nutritionFacts {
                Section(header: Text("Nährwertangaben pro 100g")) {
                    if let calories = nutrition.calories {
                        HStack {
                            Text("Kalorien:")
                            Spacer()
                            Text("\(calories) kcal")
                        }
                    }
                    if let protein = nutrition.protein {
                        HStack {
                            Text("Protein:")
                            Spacer()
                            Text("\(String(format: "%.2f", protein)) g")
                        }
                    }
                    if let carbohydrates = nutrition.carbohydrates {
                        HStack {
                            Text("Kohlenhydrate:")
                            Spacer()
                            Text("\(String(format: "%.2f", carbohydrates)) g")
                        }
                    }
                    if let fat = nutrition.fat {
                        HStack {
                            Text("Fett:")
                            Spacer()
                            Text("\(String(format: "%.2f", fat)) g")
                        }
                    }
                }
            }
            
            // Tags anzeigen, falls vorhanden
            if let tags = food.tags, !tags.isEmpty {
                Section(header: Text("Tags")) {
                    ForEach(tags, id: \.id) { tag in
                        Text(tag.name)
                    }
                }
            }
            
            // Bearbeiten-Button
            Section {
                Button("Bearbeiten") {
                    isEditing = true
                }
            }
        }
        .navigationTitle("Lebensmittel Details")
        .sheet(isPresented: $isEditing) {
            // Öffnet die Bearbeitungsansicht in einem Modal-Fenster
            FoodCreationView(modelView: modelView, existingFood: food) {_ in 
                isEditing = false  // Schließt die Bearbeitungsansicht
                
                // Aktualisiert die Lebensmittel- und Rezeptdaten im ViewModel
                modelView.updateFood()
                modelView.updateRecipe()
                
                // Falls das Lebensmittel bearbeitet wurde, aktualisiere die Ansicht mit den neuen Daten
                if let updatedFood = modelView.foods.first(where: { $0.id == food.id }) {
                    food = updatedFood
                }
                
                print("Lebensmittel aktualisiert:", food.name)
            }
        }
    }
}
