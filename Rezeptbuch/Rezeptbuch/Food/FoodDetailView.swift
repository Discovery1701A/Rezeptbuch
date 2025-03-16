//
//  FoodDetailView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.25.
//


import SwiftUI

struct FoodDetailView: View {
    @State var food: FoodStruct
    var modelView : ViewModel
    @State private var isEditing = false
    
    var body: some View {
        Form {
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
            
            if let tags = food.tags, !tags.isEmpty {
                Section(header: Text("Tags")) {
                    ForEach(tags, id: \..id) { tag in
                        Text(tag.name)
                    }
                }
            }
            
            Section {
                Button("Bearbeiten") {
                    isEditing = true
                }
            }
        }
        .navigationTitle("Lebensmittel Details")
        .sheet(isPresented: $isEditing) {
            FoodCreationView(modelView: modelView, existingFood: food
            ) {
                isEditing = false
                modelView.updateFood()
                modelView.updateRecipe()
                if let updatedFood = modelView.foods.first(where: { $0.id == food.id }) {
                    food = updatedFood
                }
                print("uuuuuuuuuuuu ", food.name)
                
            
            }
        }
    }
}
