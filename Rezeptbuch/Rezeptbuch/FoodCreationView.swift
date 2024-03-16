//
//  FoodCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 16.03.24.
//

import SwiftUI

struct FoodCreationView: View {
    @ObservedObject var modelView: ViewModel
    @State private var foodName = ""
    @State private var foodCategory = ""
    @State private var foodInfo = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbohydrates = ""
    @State private var fat = ""
    @State private var quantity = ""
    @State private var selectedUnit: Unit = .gram
    
    var body: some View {
        Form {
            Section(header: Text("Allgemeine Informationen")) {
                TextField("Lebensmittelname", text: $foodName)
                TextField("Kategorie", text: $foodCategory)
                TextField("Info", text: $foodInfo)
            }
            
            Section(header: Text("Nährwertangaben auf 100g")) {
                TextField("Kalorien", text: $calories)
                    .keyboardType(.numberPad)
                TextField("Protein (g)", text: $protein)
                    .keyboardType(.decimalPad)
                TextField("Kohlenhydrate (g)", text: $carbohydrates)
                    .keyboardType(.decimalPad)
                TextField("Fett (g)", text: $fat)
                    .keyboardType(.decimalPad)
            }
            
            
            Section(header: Text("Menge")) {
                VStack {
                    TextField("Menge", text: $quantity)
                        .keyboardType(.decimalPad)
                    Picker("Einheit", selection: $selectedUnit) {
                        ForEach(Unit.allCases, id: \.self) { unit in
                            Text(unit.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding() // Optional, um den Inhalt zu zentrieren oder auszurichten
            }
            
            
            
            
            Section {
                Button("Speichern") {
                    saveFood()
                }
            }
        }
        .navigationTitle("Lebensmittel erstellen")
    }
    
    func saveFood() {
        guard !foodName.isEmpty else {
            // Handle validation errors
            return
        }
        
        let info = foodInfo.isEmpty ? nil : foodInfo
        let category = foodCategory.isEmpty ? nil : foodCategory
        // Convert string inputs to numeric values, or use nil if empty
           let caloriesValue = calories.isEmpty ? nil : Int(calories)
           let proteinValue = protein.isEmpty ? nil : Double(protein)
           let carbohydratesValue = carbohydrates.isEmpty ? nil : Double(carbohydrates)
           let fatValue = fat.isEmpty ? nil : Double(fat)

           // Nutritional facts with '-' for missing values
           let nutritionFacts = NutritionFacts(calories: caloriesValue, protein: proteinValue,
                                               carbohydrates: carbohydratesValue, fat: fatValue)
        let food = Food(name: foodName, category: foodCategory, info: info, nutritionFacts: nutritionFacts)
        print(food)
        modelView.foods.append(food)
    }
    
    
    struct FoodCreationView_Previews: PreviewProvider {
        static var previews: some View {
            let modelView = ViewModel()
            FoodCreationView(modelView: modelView)
        }
    }
}
