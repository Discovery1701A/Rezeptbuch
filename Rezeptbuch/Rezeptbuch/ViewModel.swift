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
    @Published var foods: [foodstruct] =  [tomate, schoki,zartbitterSchokolade,vanilleExtrakt,zucker,eier,mehl,schokostücke]
    init() {
        CoreDataManager().insertInitialDataIfNeeded()
       print( CoreDataManager().fetchRecipes())
    }
    
    func appendToRecipes (recipe: Recipe){
        recipes.append(recipe)
//        print(recipes)
    }
    
  
}
