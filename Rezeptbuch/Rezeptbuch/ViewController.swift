//
//  ViewController.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 10.03.24.
//

import Foundation

struct Recipe {
    var id: Int
    var title: String
    var ingredients: [String]
    var instructions: [String]
    var image: String? // Pfad zur Bilddatei oder URL
    
     // Implementing Equatable protocol
     static func == (lhs: Recipe, rhs: Recipe) -> Bool {
         return lhs.id == rhs.id
     }
}

enum Unit: String, CaseIterable {
    case gram = "g"
    case kilogram = "kg"
    case milliliter = "ml"
    case liter = "l"
    case piece = "Stk"
}


struct Food {
    var name: String
    var category: String?
    var info : String?
//    var quantity: Double
//    var unit: Unit

    var nutritionFacts: NutritionFacts?
}

struct NutritionFacts {
    var calories: Int?
    var protein: Double?
    var carbohydrates: Double?
    var fat: Double?
}

struct FoodItem {
    var food : Food
    var unit: Unit
    var quantity: Double
}

let tomate = Food(name: "Tomate", category: "Obst")


// Beispiel für die Verwendung
let pastaRecipe = Recipe(
    id:1,
    title: "Spaghetti Bolognese",
    ingredients: ["500g Hackfleisch", "1 Zwiebel", "2 Knoblauchzehen", "Tomatensoße", "Spaghetti"],
    instructions: ["Hackfleisch anbraten", "Zwiebel und Knoblauch hinzufügen", "Tomatensoße dazugeben", "Spaghetti kochen"],
    image: "spaghetti-mit-schneller-tomatensosse"
)
let brownie = Recipe(
    id:2,
    title: "Brownie",
    ingredients: ["250g Schokolade", "250g Butter", "1TL Vanille-Extrakt", "350g Zucker", "6 Eier", "150g Mehl", "200g Schokostücke"],
    instructions: ["Offen auf 180C° vorheizen","Schokolade und Butter über einem Wasserbad schmelzen", "Eier mit Vanille-Extrakt und Zucker aufschlagen", "abgekühlte Schokoladen-Butter-Masse langsam zu der Eiermasse geben", "erst Mehl und dann die Schokostücke hinzugeben", "Teig in eine Form oder aufs Backblech geben", "30 minuten in den Backoffen"],
image: "Brownie")

//print("Rezepttitel: \(pastaRecipe.title)")
//print("Zutaten: \(pastaRecipe.ingredients)")
//print("Anleitung: \(pastaRecipe.instructions)")
//if let image = pastaRecipe.image {
//    print("Bild: \(image)")
//}
