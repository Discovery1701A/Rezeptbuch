//
//  FoodCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 16.03.24.
//

import SwiftUI

/// Ansicht zur Erstellung oder Bearbeitung eines Lebensmittels.
struct FoodCreationView: View {
    @ObservedObject var modelView: ViewModel  // Das ViewModel zur Datenverwaltung
    var onSave: () -> Void  // Callback, der nach dem Speichern aufgerufen wird
    
    // Zustandsvariablen für die Eingabefelder
    @State private var foodName = ""
    @State private var foodCategory = ""
    @State private var foodInfo = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbohydrates = ""
    @State private var fat = ""
    @State private var fooddensity: String = ""
    
    // Alle verfügbaren Tags und die ausgewählten Tags
    @State private var allTags: [TagStruct]
    @State private var selectedTags: Set<UUID>
    
    var existingFood: FoodStruct? = nil  // Optionales bestehendes Lebensmittel zur Bearbeitung

    /// Initialisiert die Ansicht mit optionalen bestehenden Lebensmitteln zur Bearbeitung.
    init(modelView: ViewModel, existingFood: FoodStruct? = nil, onSave: @escaping () -> Void) {
        self.modelView = modelView
        self.existingFood = existingFood
        self.onSave = onSave
        self.allTags = modelView.tags
        self.selectedTags = []

        // Falls ein bestehendes Lebensmittel übergeben wurde, lade dessen Daten
        if let existingFood = existingFood {
            _foodName = State(initialValue: existingFood.name)
            _foodCategory = State(initialValue: existingFood.category ?? "")
            _foodInfo = State(initialValue: existingFood.info ?? "")
            _fooddensity = State(initialValue: "\(existingFood.density ?? 0)")
            _calories = State(initialValue: "\(existingFood.nutritionFacts?.calories ?? 0)")
            _protein = State(initialValue: "\(existingFood.nutritionFacts?.protein ?? 0.0)")
            _carbohydrates = State(initialValue: "\(existingFood.nutritionFacts?.carbohydrates ?? 0.0)")
            _fat = State(initialValue: "\(existingFood.nutritionFacts?.fat ?? 0.0)")
            
            let tagStructs = existingFood.tags?.compactMap { $0 } ?? []
            _selectedTags = State(initialValue: Set(tagStructs.map(\.id)))
        }
    }

    // macOS-Version der Ansicht
    #if os(macOS)
    var body: some View {
        content
    }
    #else
    // iOS-Version der Ansicht
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Lebensmittel erstellen")
        }
        .navigationViewStyle(StackNavigationViewStyle())  // Stellt sicher, dass es auf iPads gut funktioniert
    }
    #endif

    /// Der Hauptinhalt der Ansicht, unabhängig vom Betriebssystem.
    var content: some View {
        Form {
            // Allgemeine Informationen des Lebensmittels
            Section(header: Text("Allgemeine Informationen")) {
                HStack {
                    Text("Lebensmittelname:")
                    TextField("Name eingeben", text: $foodName)
                }
                HStack {
                    Text("Kategorie:")
                    TextField("Kategorie eingeben", text: $foodCategory)
                }
                HStack {
                    Text("Info:")
                    TextField("Zusätzliche Infos", text: $foodInfo)
                }
                HStack {
                    Text("Dichte (g/cm³):")
                    TextField("Dichte (g/cm³)", text: $fooddensity)
                        .keyboardType(.decimalPad)
                }
            }

            // Auswahl der Tags
            Section(header: Text("Tags")) {
                TagsSectionView(allTags: $allTags, selectedTags: $selectedTags)
            }

            // Nährwertangaben pro 100g
            Section(header: Text("Nährwertangaben pro 100g")) {
                #if os(macOS)
                HStack {
                    Text("Kalorien:")
                    TextField("Kalorien", text: $calories)
                }
                HStack {
                    Text("Protein (g):")
                    TextField("Protein (g)", text: $protein)
                }
                HStack {
                    Text("Kohlenhydrate (g):")
                    TextField("Kohlenhydrate (g)", text: $carbohydrates)
                }
                HStack {
                    Text("Fett (g):")
                    TextField("Fett (g)", text: $fat)
                }
                #else
                HStack {
                    Text("Kalorien:")
                    TextField("Kalorien", text: $calories)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Protein (g):")
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Kohlenhydrate (g):")
                    TextField("Kohlenhydrate (g)", text: $carbohydrates)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Fett (g):")
                    TextField("Fett (g)", text: $fat)
                        .keyboardType(.decimalPad)
                }
                #endif
            }

            // Speichern-Button
            Section {
                Button("Speichern") {
                    saveFood()
                }
            }
        }
        .navigationTitle("Lebensmittel erstellen")
    }

    /// Speichert oder aktualisiert das Lebensmittel in Core Data.
    func saveFood() {
        guard !foodName.isEmpty else { return }  // Stellt sicher, dass der Name nicht leer ist

        // Falls ein optionales Feld leer ist, setze es auf nil
        let info = foodInfo.isEmpty ? nil : foodInfo
        let category = foodCategory.isEmpty ? nil : foodCategory
        let density = fooddensity.isEmpty ? nil : Double(fooddensity)
        let caloriesValue = calories.isEmpty ? nil : Int(calories)
        let proteinValue = protein.isEmpty ? nil : Double(protein)
        let carbohydratesValue = carbohydrates.isEmpty ? nil : Double(carbohydrates)
        let fatValue = fat.isEmpty ? nil : Double(fat)
        let tags = selectedTags.isEmpty ? nil : allTags.filter { selectedTags.contains($0.id) }

        // Nährwertangaben als Struktur speichern
        let nutritionFacts = NutritionFactsStruct(
            calories: caloriesValue,
            protein: proteinValue,
            carbohydrates: carbohydratesValue,
            fat: fatValue
        )
     
        if let existingFood = existingFood {
            // Aktualisierung eines bestehenden Lebensmittels
            let updatedFood = FoodStruct(
                id: existingFood.id,
                name: foodName,
                category: category,
                density: density,
                info: info,
                nutritionFacts: nutritionFacts,
                tags: tags
            )
            CoreDataManager.shared.updateFood(foodStruct: updatedFood)
        } else {
            // Neues Lebensmittel speichern
            let newFood = FoodStruct(
                id: UUID(),
                name: foodName,
                category: category,
                density: density,
                info: info,
                nutritionFacts: nutritionFacts,
                tags: tags
            )
            CoreDataManager.shared.saveFood(foodStruct: newFood)
        }

        modelView.updateFood()  // Aktualisiert die Liste der Lebensmittel im ViewModel
        onSave()  // Ruft die onSave-Closure auf, um die übergeordnete Ansicht zu informieren
    }
}
