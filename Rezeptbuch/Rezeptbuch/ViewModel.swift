//
//  ViewModel.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    @Published var recipes: [Recipe] = [brownieRecipe, pastaRecipe]
    @Published var foods: [FoodStruct] = [zartbitterSchokolade, vanilleExtrakt, zucker, eier, mehl, schokostücke]
    @Published var recipeBooks: [RecipebookStruct]
    @Published var tags: [TagStruct]
  
    // @Published var load : String
    init() {
        CoreDataManager().insertInitialDataIfNeeded()
        var load = CoreDataManager().fetchRecipes()

        recipeBooks = CoreDataManager().fetchRecipebooks()
        tags = CoreDataManager().fetchTags()
        recipes = load
        var food = CoreDataManager().fetchFoods()
        foods = food
    
        print("issss", food)
    }
    
    func appendToRecipes(recipe: Recipe) {
        recipes.append(recipe)
//        print(recipes)
    }
    
    func updateRecipe() {
        recipes = CoreDataManager().fetchRecipes()
        print("rezepteModelView:", recipes)
    }
    
    func updateFood() {
        foods = CoreDataManager().fetchFoods()
    }
    
    func updateTags() {
        tags = CoreDataManager().fetchTags()
    }
    
    func updateBooks() {
        recipeBooks = CoreDataManager().fetchRecipebooks()
    }
}
