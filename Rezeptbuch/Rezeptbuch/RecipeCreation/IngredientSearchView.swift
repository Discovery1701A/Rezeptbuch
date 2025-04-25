//
//  IngredientSearchView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.04.25.
//

import SwiftUI

struct IngredientSearchView: View {
    @Binding var selectedFood: FoodStruct // Das ausgewählte Food-Objekt
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedTag: String? = nil
    @State private var showingFoodCreation = false // Zustand für FoodCreationView
    @State private var editingFood: FoodStruct? // Die Zutat, die bearbeitet wird
    @State private var showingEditSheet = false // Zeigt die Bearbeitungsansicht
    @State private var lastCreatedOrEditedFood: FoodStruct? = nil

    @State var allFoods: [FoodStruct]

    var modelView: ViewModel
    var categories: [String] {
        Array(Set(allFoods.compactMap { $0.category })).sorted()
    }
    
    var tagsString: [String] {
        Array(Set(allFoods.compactMap { $0.tags }.flatMap { $0.map { $0.name } })).sorted()
    }

    @Environment(\.dismiss) var dismiss
    
    func updateFoods() {
        allFoods = modelView.foods // Jetzt ist die Zuweisung erlaubt
    }
    
    var filteredFoods: [FoodStruct] {
        allFoods.filter { food in
            (searchText.isEmpty || food.name.lowercased().contains(searchText.lowercased())) &&
                (selectedCategory == nil || food.category == selectedCategory) &&
                (selectedTag == nil || food.tags?.contains(where: { $0.name == selectedTag }) == true)
        }
    }
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
        
        // Prüfe zuerst lastCreatedOrEditedFood
        if let last = lastCreatedOrEditedFood,
           let index = sorted.firstIndex(where: { $0.id == last.id }) {
            let item = sorted.remove(at: index)
            sorted.insert(item, at: 0)
            return sorted
        }
        
        // Sonst fallback auf selectedFood
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
                    // Suchfeld
                    TextField("Suchen", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
             
                    // Kategorie-Filter mit ScrollView
                    Section(header: Text("Kategorien")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                Button(action: {
                                    selectedCategory = nil
                                }) {
                                    Text("Alle")
                                        .padding()
                                        .background(selectedCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedCategory == nil ? Color.white : Color.primary)
                                        .cornerRadius(8)
                                }
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .padding()
                                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedCategory == category ? Color.white : Color.primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Tag-Filter mit ScrollView
                    Section(header: Text("Tag")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                Button(action: {
                                    selectedTag = nil
                                }) {
                                    Text("Alle")
                                        .padding()
                                        .background(selectedTag == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedTag == nil ? Color.white : Color.primary)
                                        .cornerRadius(8)
                                }
                                ForEach(tagsString, id: \.self) { tag in
                                    Button(action: {
                                        selectedTag = tag
                                    }) {
                                        Text(tag)
                                            .padding()
                                            .background(selectedTag == tag ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedTag == tag ? Color.white : Color.primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    List(sortedFoodsWithSelectedFirst) { food in
                        Button(action: {
                            selectedFood = food
                            dismiss()
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
                                Spacer() // Füllt die gesamte Fläche aus
                            }
                            .padding() // Damit die Klickfläche größer ist
                            .contentShape(Rectangle()) // Macht den gesamten Bereich klickbar
                        }
                        .simultaneousGesture(LongPressGesture().onEnded { _ in
                            editingFood = food
                            showingEditSheet = true
                        })
                    }
                    .frame(minHeight: 300) // Optional: Mindesthöhe für die Liste
                }
            }
            .navigationTitle("Zutaten suchen")
            .navigationBarItems(
                leading: Button("Abbrechen", action: {
                    dismiss()
                }),
                trailing: Button(action: {
                    showingFoodCreation = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Neue Zutat")
                    }
                }
            )
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

