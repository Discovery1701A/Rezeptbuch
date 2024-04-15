//
//  ViewModel.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    @Published var recipes: [Recipe] = [brownie,pastaRecipe]
    @Published var foods: [FoodStruct] =  [tomate, schoki,zartbitterSchokolade,vanilleExtrakt,zucker,eier,mehl,schokostücke]
    @Published var load : String
    init() {
        CoreDataManager().insertInitialDataIfNeeded()
        load = CoreDataManager().fetchRecipes()[0].titel!
        print(load)
    }
    
    func appendToRecipes (recipe: Recipe){
        recipes.append(recipe)
//        print(recipes)
    }
    
  
}
