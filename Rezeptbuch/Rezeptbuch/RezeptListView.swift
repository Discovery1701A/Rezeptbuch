//
//  RezeptListView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import SwiftUI

struct RecipeListView: View {
    @ObservedObject var modelView: ViewModel
    @State private var searchText = ""
    @State private var selectedIngredients: [FoodStruct] = []
    @State private var selectedTags: [TagStruct] = []
    @State private var selectedRecipeBooks: [RecipebookStruct] = []
    @State private var isFilterExpanded = false // Steuert, ob die Filtersektion angezeigt wird

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
        #if os(iOS)
        NavigationView {
            VStack {
                HStack {
                    TextField("Rezept suchen", text: $searchText)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Clear Button für das Hauptsuchfeld
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                }
                
                HStack {
                    Button(action: {
                        withAnimation {
                            isFilterExpanded.toggle()
                        }
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
                
                List(filteredRecipes, id: \.id) { recipe in
                    NavigationLink(destination: RecipeView(recipe: recipe, modelView: modelView)) {
                        Text(recipe.title)
                    }
                }
                .navigationBarTitle("Alle Rezepte")
            }
            .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #elseif os(macOS)
        NavigationView {
            VStack {
                Text("Alle Rezepte")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.controlBackgroundColor))
                
                List(modelView.recipes, id: \.id) { recipe in
                    NavigationLink(destination: RecipeView(recipe: recipe)) {
                        Text(recipe.title)
                    }
                }
                .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        #endif
    }
    
    private func clearAllFilters() {
        selectedIngredients.removeAll()
        selectedTags.removeAll()
        selectedRecipeBooks.removeAll()
    }
}

struct FilterSection<Item: Hashable & Identifiable & Named>: View {
    var title: String
    var items: [Item]
    @Binding var selectedItems: [Item]
    var clearAction: () -> Void // Aktion zum Entfernen der Filter für die jeweilige Kategorie
    @State private var filterText = "" // Lokale Suchvariable

    var filteredItems: [Item] {
        if filterText.isEmpty {
            return items
        } else {
            return items.filter { $0.name.localizedCaseInsensitiveContains(filterText) }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Button("Filter entfernen", action: clearAction)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                TextField("Suche \(title.lowercased())", text: $filterText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Clear Button für das Suchfeld in der Filtersektion
                if !filterText.isEmpty {
                    Button(action: {
                        filterText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filteredItems, id: \.self) { item in
                        Button(action: {
                            toggleSelection(for: item)
                        }) {
                            Text(item.name)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .foregroundColor(selectedItems.contains(item) ? .white : .blue)
                                .background(selectedItems.contains(item) ? Color.blue : Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                        .padding(.trailing, 8)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func toggleSelection(for item: Item) {
        if let index = selectedItems.firstIndex(of: item) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }
}

protocol Named {
    var name: String { get }
}

extension FoodStruct: Named {}
extension TagStruct: Named {}
extension RecipebookStruct: Named {}
