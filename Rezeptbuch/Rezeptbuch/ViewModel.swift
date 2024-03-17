//
//  ViewModel.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    @Published var recepis: [Recipe] = [brownie,pastaRecipe]
    @Published var foods: [Food] =  [tomate]
    
    
    func appendToRecipes (recipe: Recipe){
        recepis.append(recipe)
        print(recepis)
    }
    
  
}
