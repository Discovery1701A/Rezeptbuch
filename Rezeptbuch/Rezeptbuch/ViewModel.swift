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
    
    
    func appendToRecipes (recipe: Recipe){
        recepis.append(recipe)
        print(recepis)
    }
}
