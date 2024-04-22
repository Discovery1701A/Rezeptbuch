//
//  ViewModel.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    @Published var recipes: [Recipe] = [brownieRecipe,pastaRecipe]
    @Published var foods: [FoodStruct] =  [tomate, schoki,zartbitterSchokolade,vanilleExtrakt,zucker,eier,mehl,schokostücke]
    //@Published var load : String
    init() {
        CoreDataManager().insertInitialDataIfNeeded()
        var load = CoreDataManager().fetchRecipes()
        print("das ist ",load[0].ingredients)
        print(load[1].cake)
        recipes = load
        var food = CoreDataManager().fetchFoods()
        foods = food
        print("issss",food)
    }
    
    func appendToRecipes (recipe: Recipe){
        recipes.append(recipe)
//        print(recipes)
    }
    
    func updateRecipe(){
        recipes = CoreDataManager().fetchRecipes()
    }
    
    func updateFood(){
        foods = CoreDataManager().fetchFoods()
    }
    
  
}
