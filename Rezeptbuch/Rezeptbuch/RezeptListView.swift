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

    var filteredRecipes: [Recipe] {
        if searchText.isEmpty && selectedIngredients.isEmpty {
            return modelView.recipes
        } else if !selectedIngredients.isEmpty && !searchText.isEmpty  {
            return modelView.recipes.filter { recipe in
                searchText.isEmpty || recipe.title.localizedCaseInsensitiveContains(searchText) &&
                    selectedIngredients.allSatisfy { selectedIngredient in
                        recipe.ingredients.contains { $0.food.name.localizedCaseInsensitiveContains(selectedIngredient.name) }
                    }
            }
        } else if !selectedIngredients.isEmpty && searchText.isEmpty {
            return modelView.recipes.filter { recipe in
                    selectedIngredients.allSatisfy { selectedIngredient in
                        recipe.ingredients.contains { $0.food.name.localizedCaseInsensitiveContains(selectedIngredient.name) }
                    }
            }
        }
        
        else {
            return modelView.recipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }


    var body: some View {
       
            #if os(iOS)
        NavigationView {
                   VStack {
                       TextField("Rezept suchen", text: $searchText)
                           .padding()
                           .textFieldStyle(RoundedBorderTextFieldStyle())
                           .onChange(of: searchText) { _ in
                               // Clear selected ingredients when searching by title
                               selectedIngredients = []
                           }

                       // Search by ingredients
                       if !modelView.foods.isEmpty {
                           Text("Zutaten auswählen:")
                           ScrollView(.horizontal, showsIndicators: false) {
                               HStack {
                                   ForEach(modelView.foods, id: \.self) { ingredient in
                                       Button(action: {
                                           toggleIngredient(ingredient)
                                       }) {
                                           Text(ingredient.name)
                                               .padding(.vertical, 8)
                                               .padding(.horizontal, 16)
                                               .foregroundColor(selectedIngredients.contains(ingredient) ? .white : .blue)
                                               .background(selectedIngredients.contains(ingredient) ? Color.blue : Color.white)
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

                       List(filteredRecipes, id: \.id) { recipe in
                           NavigationLink(destination: RecipeView(recipe: recipe, modelView: modelView)) {
                               HStack {
                                   Text(recipe.title)
                                   // Additional recipe details if needed
                               }
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
                    // Text view for navigation title on macOS
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
        
       
       
    func toggleIngredient(_ ingredient: FoodStruct) {
        if let index = selectedIngredients.firstIndex(of: ingredient) {
            selectedIngredients.remove(at: index)
        } else {
            selectedIngredients.append(ingredient)
        }
    }
    
}

// ... rest of the code remains unchanged

//// Beispiel für die Verwendung
//struct contentListView: View {
//    var recipes: [Recipe]
//
//    var body: some View {
//        RecipeListView(recipes: recipes)
//    }
//}
//
//struct ContentListView_Previews: PreviewProvider {
//    static var previews: some View {
//        contentListView(recipes: [brownie, pastaRecipe])
//    }
//}
