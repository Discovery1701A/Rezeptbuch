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
    @Published var foods: [Food] =  [tomate, schoki,zartbitterSchokolade,vanilleExtrakt,zucker,eier,mehl,schokostücke]
    
    
    func appendToRecipes (recipe: Recipe){
        recipes.append(recipe)
        print(recipes)
    }
    
  
}
