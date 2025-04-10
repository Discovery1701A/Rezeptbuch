//
//  ViewModel.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import Foundation
import SwiftUI

/// Das `ViewModel` verwaltet die Daten für die Rezeptbuch-App.
/// Es stellt die zentrale Datenquelle für SwiftUI-Ansichten bereit.
class ViewModel: ObservableObject {
    // Liste aller Rezepte, die in der App verfügbar sind
    @Published var recipes: [Recipe] = [brownieRecipe, pastaRecipe]
    
    // Liste aller Lebensmittel
    @Published var foods: [FoodStruct] = [zartbitterSchokolade, vanilleExtrakt, zucker, eier, mehl, schokostücke]
    
    // Liste aller Rezeptbücher
    @Published var recipeBooks: [RecipebookStruct]
    
    // Liste aller Tags
    @Published var tags: [TagStruct]
  
    /// Initialisiert das ViewModel und lädt die Daten aus CoreData.
    init() {
        CoreDataManager().insertInitialDataIfNeeded()  // Falls nötig, werden Anfangsdaten eingefügt

        // Lädt die gespeicherten Daten aus Core Data
        let load = CoreDataManager().fetchRecipes()
        recipes = load  // Rezepte aus CoreData übernehmen
        recipeBooks = CoreDataManager().fetchRecipebooks()
        tags = CoreDataManager().fetchTags()
        foods = CoreDataManager().fetchFoods()
    }
    
    
    func updateAll() {
       updateRecipe()
        print(recipes.count)
        updateFood()
      updateBooks()
      updateTags()
    }
    
    
    /// Fügt ein neues Rezept zur Liste hinzu.
    func appendToRecipes(recipe: Recipe) {
        recipes.append(recipe)
//        print(recipes)
    }
    
    
    /// Aktualisiert die Liste der Rezepte durch erneutes Abrufen aus CoreData.
    func updateRecipe() {
        recipes = CoreDataManager().fetchRecipes()
//        print("rezepteModelView:", recipes)
    }
    
    /// Aktualisiert die Liste der Lebensmittel.
    func updateFood() {
        foods = CoreDataManager().fetchFoods()
    }
    
    /// Aktualisiert die Liste der Tags.
    func updateTags() {
        tags = CoreDataManager().fetchTags()
    }
    
    /// Aktualisiert die Liste der Rezeptbücher.
    func updateBooks() {
        recipeBooks = CoreDataManager().fetchRecipebooks()
    }
}
