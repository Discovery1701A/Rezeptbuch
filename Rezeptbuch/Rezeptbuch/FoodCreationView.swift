//
//  FoodCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 16.03.24.
//

import SwiftUI

struct FoodCreationView: View {
    @ObservedObject var modelView: ViewModel
    var onSave: () -> Void // Closure hinzugefügt
    @State private var foodName = ""
    @State private var foodCategory = ""
    @State private var foodInfo = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbohydrates = ""
    @State private var fat = ""
    @State private var fooddensity: String = ""
    @State private var allTags: [TagStruct]
    @State private var selectedTags: Set<UUID>
    var existingFood: FoodStruct? = nil
    
    init(modelView: ViewModel, existingFood: FoodStruct? = nil, onSave: @escaping () -> Void) {
        self.modelView = modelView
        self.existingFood = existingFood
        self.onSave = onSave
        self.allTags = modelView.tags
        self.selectedTags = []

        // Lade die bestehenden Daten, falls vorhanden
        if let existingFood = existingFood {
            _foodName = State(initialValue: existingFood.name)
            _foodCategory = State(initialValue: existingFood.category ?? "")
            _foodInfo = State(initialValue: existingFood.info ?? "")
            _fooddensity = State(initialValue: "\(existingFood.density ?? 0)")
            _calories = State(initialValue: "\(existingFood.nutritionFacts?.calories ?? 0)")
            _protein = State(initialValue: "\(existingFood.nutritionFacts?.protein ?? 0.0)")
            _carbohydrates = State(initialValue: "\(existingFood.nutritionFacts?.carbohydrates ?? 0.0)")
            _fat = State(initialValue: "\(existingFood.nutritionFacts?.fat ?? 0.0)")
            let tagStructs = existingFood.tags!.compactMap {  $0}
            _selectedTags = State(initialValue: Set(tagStructs.map(\.id)))

        
        }
    }


#if os(macOS)
    
    var body: some View {
        
        content
        
        
    }
    
    
#else
    
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Lebensmittel erstellen")
            
        } .navigationViewStyle(StackNavigationViewStyle()) // Hier wird der Modifier hinzugefügt
    }
    
#endif
    
    
    
    var content: some View {
        Form {
            Section(header: Text("Allgemeine Informationen")) {
                TextField("Lebensmittelname", text: $foodName)
                TextField("Kategorie", text: $foodCategory)
                TextField("Info", text: $foodInfo)
                TextField( "Dichte (g/cm^3)", text: $fooddensity)
            }
            Section(header: Text("Tags")){
                TagsSectionView( allTags: $allTags, selectedTags: $selectedTags)
            }
#if os(macOS)
            Section(header: Text("Nährwertangaben auf 100g")) {
                TextField("Kalorien", text: $calories)
                  
                TextField("Protein (g)", text: $protein)
                  
                TextField("Kohlenhydrate (g)", text: $carbohydrates)
            
                TextField("Fett (g)", text: $fat)
                  
            }
#else
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
            
#endif
            
            
            
            
            
            Section {
                Button("Speichern") {
                    saveFood()
                }
            }
        }
        .navigationTitle("Lebensmittel erstellen")
    }
    
    func saveFood() {
        guard !foodName.isEmpty else { return }

        let info = foodInfo.isEmpty ? nil : foodInfo
        let category = foodCategory.isEmpty ? nil : foodCategory
        let density = fooddensity.isEmpty ? nil : Double(fooddensity)
        let caloriesValue = calories.isEmpty ? nil : Int(calories)
        let proteinValue = protein.isEmpty ? nil : Double(protein)
        let carbohydratesValue = carbohydrates.isEmpty ? nil : Double(carbohydrates)
        let fatValue = fat.isEmpty ? nil : Double(fat)
        let tags = selectedTags.isEmpty ? nil : allTags.filter { selectedTags.contains($0.id) }
               
           

        let nutritionFacts = NutritionFactsStruct(
            calories: caloriesValue, protein: proteinValue,
            carbohydrates: carbohydratesValue, fat: fatValue
        )
     
        if let existingFood = existingFood {
            // Aktualisiere die bestehende Zutat
          
            let updatedFood = FoodStruct(
                id: existingFood.id,
                name: foodName,
                category: category,
                density: density,
                info: info,
                nutritionFacts: nutritionFacts,
                tags: tags
            )
            CoreDataManager().updateFood(foodStruct: updatedFood)
        } else {
            // Neue Zutat speichern
            let newFood = FoodStruct(
                id: UUID(),
                name: foodName,
                category: category,
                density: density,
                info: info,
                nutritionFacts: nutritionFacts,
                tags: tags
            )
            CoreDataManager().saveFood(foodStruct: newFood)
        }

        modelView.updateFood()
        onSave()
    }

}
    
//    
//    struct FoodCreationView_Previews: PreviewProvider {
//        static var previews: some View {
//            let modelView = ViewModel()
//            FoodCreationView(modelView: modelView)
//        }
//    }
//}
