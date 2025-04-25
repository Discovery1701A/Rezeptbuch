//
//  IngredientSearchView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.04.25.
//

import SwiftUI
// Ansicht zum Durchsuchen und Auswählen von Zutaten.
// Unterstützt Filterung nach Kategorien, Tags, Volltextsuche und das Erstellen/Bearbeiten von Zutaten.
struct IngredientSearchView: View {
    
    // Die aktuell ausgewählte Zutat – wird über Binding zurückgegeben
    @Binding var selectedFood: FoodStruct
    
    // Suchtext für die Live-Suche
    @State private var searchText = ""
    
    // Gewählte Filter-Kategorie (optional)
    @State private var selectedCategory: String? = nil
    
    // Gewählter Tag als Filter (optional)
    @State private var selectedTag: String? = nil
    
    // Zustände für die Anzeige der Unteransichten
    @State private var showingFoodCreation = false
    @State private var editingFood: FoodStruct? = nil
    @State private var showingEditSheet = false
    
    // Letzte neu erstellte oder bearbeitete Zutat (zur Hervorhebung)
    @State private var lastCreatedOrEditedFood: FoodStruct? = nil

    // Alle Zutaten – kann bei Filterung oder Aktualisierung angepasst werden
    @State var allFoods: [FoodStruct]

    // Zugriff auf ViewModel (Datenquelle)
    var modelView: ViewModel

    // Liste aller Kategorien, alphabetisch sortiert und ohne Duplikate
    var categories: [String] {
        Array(Set(allFoods.compactMap { $0.category })).sorted()
    }

    // Liste aller Tags als Strings, alphabetisch sortiert
    var tagsString: [String] {
        Array(Set(allFoods.compactMap { $0.tags }.flatMap { $0.map { $0.name } })).sorted()
    }

    // Ermöglicht das Schließen der View über z. B. „Abbrechen“-Button
    @Environment(\.dismiss) var dismiss

    // Aktualisiert die Zutatenliste aus dem ViewModel
    func updateFoods() {
        allFoods = modelView.foods
    }

    // Liefert eine gefilterte Liste der Zutaten basierend auf Suchtext, Kategorie- und Tag-Filter
    var filteredFoods: [FoodStruct] {
        allFoods.filter { food in
            (searchText.isEmpty || food.name.lowercased().contains(searchText.lowercased())) &&
            (selectedCategory == nil || food.category == selectedCategory) &&
            (selectedTag == nil || food.tags?.contains(where: { $0.name == selectedTag }) == true)
        }
    }

    // Gibt die gefilterten Zutaten zurück, sortiert nach Kategorie & Name.
    // Falls vorhanden, wird die zuletzt bearbeitete oder ausgewählte Zutat nach vorn sortiert.
    var sortedFoodsWithSelectedFirst: [FoodStruct] {
        var sorted = filteredFoods.sorted {
            let categoryA = $0.category ?? ""
            let categoryB = $1.category ?? ""
            if categoryA != categoryB {
                return categoryA.localizedCaseInsensitiveCompare(categoryB) == .orderedAscending
            } else {
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }

        // Letzte neu erstellte/bearbeitete Zutat ganz nach oben sortieren
        if let last = lastCreatedOrEditedFood,
           let index = sorted.firstIndex(where: { $0.id == last.id }) {
            let item = sorted.remove(at: index)
            sorted.insert(item, at: 0)
            return sorted
        }

        // Fallback: ausgewählte Zutat nach oben sortieren
        if let index = sorted.firstIndex(where: { $0.id == selectedFood.id }) {
            let selected = sorted.remove(at: index)
            sorted.insert(selected, at: 0)
        }

        return sorted
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // 🔍 Suchfeld für Namen
                    TextField("Suchen", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    // 📂 Kategorie-Filter
                    Section(header: Text("Kategorien")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                // Button: Alle Kategorien (Filter entfernen)
                                Button(action: { selectedCategory = nil }) {
                                    Text("Alle")
                                        .padding()
                                        .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedCategory == nil ? .white : .primary)
                                        .cornerRadius(8)
                                }

                                // Dynamisch erzeugte Kategorie-Buttons
                                ForEach(categories, id: \.self) { category in
                                    Button(action: { selectedCategory = category }) {
                                        Text(category)
                                            .padding()
                                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedCategory == category ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }.padding(.horizontal)
                        }
                    }

                    // 🏷️ Tag-Filter
                    Section(header: Text("Tag")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                // Button: Alle Tags
                                Button(action: { selectedTag = nil }) {
                                    Text("Alle")
                                        .padding()
                                        .background(selectedTag == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedTag == nil ? .white : .primary)
                                        .cornerRadius(8)
                                }

                                // Dynamisch erzeugte Tag-Buttons
                                ForEach(tagsString, id: \.self) { tag in
                                    Button(action: { selectedTag = tag }) {
                                        Text(tag)
                                            .padding()
                                            .background(selectedTag == tag ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedTag == tag ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }.padding(.horizontal)
                        }
                    }

                    // 📃 Ergebnisliste
                    List(sortedFoodsWithSelectedFirst) { food in
                        Button(action: {
                            selectedFood = food
                            dismiss() // Auswahl übernehmen und schließen
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .font(.headline)
                                    if let category = food.category {
                                        Text(category)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            .contentShape(Rectangle()) // ganzer Bereich klickbar
                        }
                        .simultaneousGesture(LongPressGesture().onEnded { _ in
                            editingFood = food
                            showingEditSheet = true
                        })
                    }
                    .frame(minHeight: 300) // Mindesthöhe für optisch bessere Darstellung
                }
            }

            // NavigationBar mit Titel & Buttons
            .navigationTitle("Zutaten suchen")
            .navigationBarItems(
                // Abbrechen-Button
                leading: Button("Abbrechen", action: {
                    dismiss()
                }),

                // Neue Zutat hinzufügen
                trailing: Button(action: {
                    showingFoodCreation = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Neue Zutat")
                    }
                }
            )

            // Sheet zum Erstellen einer neuen Zutat
            .sheet(isPresented: $showingFoodCreation) {
                FoodCreationView(
                    modelView: modelView,
                    onSave: { newFood in
                        showingFoodCreation = false
                        modelView.updateFood()
                        updateFoods()
                        lastCreatedOrEditedFood = newFood
                    }
                )
            }

            // Sheet zum Bearbeiten einer vorhandenen Zutat (bei Long Press)
            .sheet(isPresented: $showingEditSheet) {
                if let foodToEdit = editingFood {
                    FoodCreationView(
                        modelView: modelView,
                        existingFood: foodToEdit,
                        onSave: { updatedFood in
                            showingEditSheet = false
                            modelView.updateFood()
                            updateFoods()
                            lastCreatedOrEditedFood = updatedFood
                        }
                    )
                }
            }
        }
    }
}
