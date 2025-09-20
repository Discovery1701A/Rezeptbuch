//
//  FoodCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 16.03.24.
//

import SwiftUI
/// Ansicht zur Erstellung oder Bearbeitung eines Lebensmittels.
struct FoodCreationView: View {
    @ObservedObject var modelView: ViewModel  // ViewModel zur Verwaltung aller Lebensmittel und Tags
    var onSave: (FoodStruct) -> Void  // Callback, der aufgerufen wird, wenn das Lebensmittel gespeichert wurde

    // 🧾 Eingabefelder für allgemeine Daten
    @State private var foodName = ""
    @State private var foodCategory = ""
    @State private var foodInfo = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbohydrates = ""
    @State private var fat = ""
    @State private var fooddensity: String = ""

    // 📎 Alle Tags aus dem Modell + aktuell ausgewählte Tags
    @State private var allTags: [TagStruct]
    @State private var selectedTags: Set<UUID>

    var existingFood: FoodStruct? = nil  // Optional: Wenn ein vorhandenes Lebensmittel editiert werden soll

    /// Initialisierung der View mit oder ohne bestehendem Lebensmittel
    init(modelView: ViewModel, existingFood: FoodStruct? = nil, onSave: @escaping (FoodStruct) -> Void) {
        self.modelView = modelView
        self.existingFood = existingFood
        self.onSave = onSave
        self.allTags = modelView.tags
        self.selectedTags = []

        // Falls ein bestehendes Lebensmittel übergeben wurde, Felder damit füllen
        if let existingFood = existingFood {
            _foodName = State(initialValue: existingFood.name)
            _foodCategory = State(initialValue: existingFood.category ?? "")
            _foodInfo = State(initialValue: existingFood.info ?? "")
            _fooddensity = State(initialValue: "\(existingFood.density ?? 0)")
            _calories = State(initialValue: "\(existingFood.nutritionFacts?.calories ?? 0)")
            _protein = State(initialValue: "\(existingFood.nutritionFacts?.protein ?? 0.0)")
            _carbohydrates = State(initialValue: "\(existingFood.nutritionFacts?.carbohydrates ?? 0.0)")
            _fat = State(initialValue: "\(existingFood.nutritionFacts?.fat ?? 0.0)")
            
            let tagStructs = existingFood.tags ?? []
            _selectedTags = State(initialValue: Set(tagStructs.map(\.id)))
        }
    }

    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Lebensmittel erstellen")
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Gute Darstellung auf iPad
    }

    /// Der Hauptinhalt der Eingabemaske
    var content: some View {
        Form {
            // MARK: Allgemeine Informationen
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

            // MARK: Tags
            Section(header: Text("Tags")) {
                TagsSectionView(
                    allTags: $allTags,
                    selectedTags: $selectedTags
                )
            }

            // MARK: Nährwertangaben
            Section(header: Text("Nährwertangaben pro 100g")) {
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
               
            }
            

            // MARK: Speichern
            Section {
                Button("Speichern") {
                    saveFood()
                }
            }
        }
        .navigationTitle("Lebensmittel erstellen")
    }

    /// Speichert oder aktualisiert das Lebensmittel in Core Data und gibt es per Callback zurück
    func saveFood() {
        guard !foodName.isEmpty else { return }

        // Leere Felder in optionale Werte umwandeln
        let info = foodInfo.isEmpty ? nil : foodInfo
        let category = foodCategory.isEmpty ? nil : foodCategory
        let density = fooddensity.isEmpty ? nil : Double(fooddensity)
        let caloriesValue = calories.isEmpty ? nil : Int(calories)
        let proteinValue = protein.isEmpty ? nil : Double(protein)
        let carbohydratesValue = carbohydrates.isEmpty ? nil : Double(carbohydrates)
        let fatValue = fat.isEmpty ? nil : Double(fat)
        let tags = selectedTags.isEmpty ? nil : allTags.filter { selectedTags.contains($0.id) }

        let nutritionFacts = NutritionFactsStruct(
            calories: caloriesValue,
            protein: proteinValue,
            carbohydrates: carbohydratesValue,
            fat: fatValue
        )

        let savedFood: FoodStruct

        // 🔄 Bestehendes Food aktualisieren oder neues anlegen
        if let existingFood = existingFood {
            savedFood = FoodStruct(
                id: existingFood.id,
                name: foodName,
                category: category,
                density: density,
                info: info,
                nutritionFacts: nutritionFacts,
                tags: tags
            )
            CoreDataManager.shared.updateFood(foodStruct: savedFood)
        } else {
            savedFood = FoodStruct(
                id: UUID(),
                name: foodName,
                category: category,
                density: density,
                info: info,
                nutritionFacts: nutritionFacts,
                tags: tags
            )
            CoreDataManager.shared.saveFood(foodStruct: savedFood)
        }

        modelView.updateFood() // ModelView aktualisieren
        onSave(savedFood)      // Callback aufrufen (z. B. zum Schließen der Ansicht)
    }
}
