//
//  RezeptListView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import SwiftUI
/// Zeigt eine Liste aller Rezepte an und ermöglicht die Suche und Filterung nach Zutaten, Tags und Rezeptbüchern.
struct RecipeListView: View {
    @ObservedObject var modelView: ViewModel
    @Binding var selectedTab: Int  // Aktueller Tab (für Navigation)
    @Binding var UUIDOfSelectedRecipe: UUID?  // UUID für externes Öffnen eines Rezepts
    @State private var isNavigationActive = false  // Steuert, ob ein Rezept aktiv angezeigt wird
    @State private var selectedRecipeForNavigation: Recipe? = nil  // Das aktuell ausgewählte Rezept

    // Such- und Filterzustände
    @State private var searchText = ""
    @State private var selectedIngredients: [FoodStruct] = []
    @State private var selectedTags: [TagStruct] = []
    @State private var selectedRecipeBooks: [RecipebookStruct] = []
    @State private var isFilterExpanded = false  // Steuerung der Filter-Sektion

    /// Gibt die Rezepte zurück, die alle aktiven Filter und die Suche erfüllen.
    var filteredRecipes: [Recipe] {
        modelView.recipes.filter { recipe in
            let matchesSearchText = searchText.isEmpty || recipe.title.localizedCaseInsensitiveContains(searchText)
            
            let matchesIngredients = selectedIngredients.isEmpty || selectedIngredients.allSatisfy { ingredient in
                recipe.ingredients.contains { $0.food.name.localizedCaseInsensitiveContains(ingredient.name) }
            }
            
            let matchesTags = selectedTags.isEmpty || selectedTags.allSatisfy { selectedTag in
                recipe.tags?.contains { $0.name.localizedCaseInsensitiveContains(selectedTag.name) } ?? false
            }

            let matchesRecipeBooks = selectedRecipeBooks.isEmpty || selectedRecipeBooks.allSatisfy { selectedBook in
                recipe.recipeBookIDs?.contains(selectedBook.id) ?? false
            }

            return matchesSearchText && matchesIngredients && matchesTags && matchesRecipeBooks
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // 🔎 Suchfeld
                    HStack {
                        TextField("Rezept suchen", text: $searchText)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    
                    // 🔽 Filter-Umschalter und Zurücksetzen-Button
                    HStack {
                        Button(action: {
                            withAnimation { isFilterExpanded.toggle() }
                        }) {
                            HStack {
                                Text("Filter")
                                Image(systemName: isFilterExpanded ? "chevron.up" : "chevron.down")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button("Alle Filter entfernen") {
                            clearAllFilters()
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal)
                    }
                    
                    // 📋 Filteroptionen (falls geöffnet)
                    if isFilterExpanded {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                if !modelView.foods.isEmpty {
                                    FilterSection(
                                        title: "Zutaten auswählen:",
                                        items: modelView.foods,
                                        selectedItems: $selectedIngredients,
                                        clearAction: { selectedIngredients.removeAll() }
                                    )
                                }
                                
                                if !modelView.tags.isEmpty {
                                    FilterSection(
                                        title: "Tags auswählen:",
                                        items: modelView.tags,
                                        selectedItems: $selectedTags,
                                        clearAction: { selectedTags.removeAll() }
                                    )
                                }
                                
                                if !modelView.recipeBooks.isEmpty {
                                    FilterSection(
                                        title: "Rezeptbücher auswählen:",
                                        items: modelView.recipeBooks,
                                        selectedItems: $selectedRecipeBooks,
                                        clearAction: { selectedRecipeBooks.removeAll() }
                                    )
                                }
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxHeight: 300)
                    }
                    
                    // 📜 Liste der gefilterten Rezepte
                    List(filteredRecipes, id: \.id) { recipe in
                        NavigationLink(destination: RecipeView(recipe: recipe, modelView: modelView)) {
                            Text(recipe.title)
                        }
                    }
                    .navigationBarTitle("Alle Rezepte")
                }
                .padding()

                // 🚀 Navigation zu einem bestimmten Rezept via UUID
                NavigationLink(
                    destination: Group {
                        if let recipe = selectedRecipeForNavigation {
                            RecipeView(recipe: recipe, modelView: modelView)
                        }
                    },
                    isActive: $isNavigationActive
                ) {
                    EmptyView()
                }
                .onChange(of: isNavigationActive) { active in
                    if !active {
                        UUIDOfSelectedRecipe = nil
                        selectedRecipeForNavigation = nil
                    }
                }
                .onChange(of: UUIDOfSelectedRecipe) { newValue in
                    guard
                        let id = newValue,
                        let recipe = modelView.recipes.first(where: { $0.id == id })
                    else { return }
                    selectedRecipeForNavigation = recipe
                    isNavigationActive = true
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())  // iPhone/iPad kompatibel
    }

    /// Setzt alle aktiven Filter zurück.
    private func clearAllFilters() {
        selectedIngredients.removeAll()
        selectedTags.removeAll()
        selectedRecipeBooks.removeAll()
    }
}
