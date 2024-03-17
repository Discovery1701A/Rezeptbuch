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
    var ingredients: [FoodItem]
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
    case teaspoon = "Teelöffel"
}


struct Food: Hashable, Equatable {
    var name: String
    var category: String?
    var info : String?
    var nutritionFacts: NutritionFacts?

    static func == (lhs: Food, rhs: Food) -> Bool {
        return lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.info == rhs.info &&
               lhs.nutritionFacts == rhs.nutritionFacts
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(info)
        hasher.combine(nutritionFacts)
    }
}


struct NutritionFacts: Equatable, Hashable {
    var calories: Int?
    var protein: Double?
    var carbohydrates: Double?
    var fat: Double?

    func hash(into hasher: inout Hasher) {
        hasher.combine(calories)
        hasher.combine(protein)
        hasher.combine(carbohydrates)
        hasher.combine(fat)
    }
}


struct FoodItem: Hashable, Equatable {
    var food: Food
    var unit: Unit
    var quantity: Double

    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.food == rhs.food &&
               lhs.unit == rhs.unit &&
               lhs.quantity == rhs.quantity
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(food)
        hasher.combine(unit)
        hasher.combine(quantity)
    }
}


let tomate = Food(name: "Tomate", category: "Obst")


// Beispiel für die Verwendung
let pastaRecipe = Recipe(
    id:1,
    title: "Spaghetti Bolognese",
    ingredients: [ FoodItem(food: Food(name: "Hackfleisch", category: "Fleisch & Wurst", info: nil, nutritionFacts: nil), unit: .gram, quantity: 500),
                   FoodItem(food: Food(name: "Zwiebel", category: "Gemüse", info: nil, nutritionFacts: nil), unit: .piece, quantity: 1),
                   FoodItem(food: Food(name: "Knoblauchzehen", category: "Gemüse", info: nil, nutritionFacts: nil), unit: .piece, quantity: 2),
                   FoodItem(food: Food(name: "Tomatensoße", category: "Saucen", info: nil, nutritionFacts: nil), unit: .milliliter, quantity: 500),
                   FoodItem(food: Food(name: "Spaghetti", category: "Nudeln & Teigwaren", info: nil, nutritionFacts: nil), unit: .gram, quantity: 250)],
    instructions: ["Hackfleisch anbraten", "Zwiebel und Knoblauch hinzufügen", "Tomatensoße dazugeben", "Spaghetti kochen"],
    image: "spaghetti-mit-schneller-tomatensosse"
)
let brownie = Recipe(
    id:2,
    title: "Brownie",
    ingredients: [  FoodItem(food: Food(name: "Schokolade", category: "Süßwaren", info: nil, nutritionFacts: nil), unit: .gram, quantity: 250),
                    FoodItem(food: Food(name: "Butter", category: "Milchprodukte", info: nil, nutritionFacts: nil), unit: .gram, quantity: 250),
                    FoodItem(food: Food(name: "Vanille-Extrakt", category: "Gewürze", info: nil, nutritionFacts: nil), unit: .teaspoon, quantity: 1),
                    FoodItem(food: Food(name: "Zucker", category: "Backzutaten", info: nil, nutritionFacts: nil), unit: .gram, quantity: 350),
                    FoodItem(food: Food(name: "Eier", category: "Eier & Eiprodukte", info: nil, nutritionFacts: nil), unit: .piece, quantity: 6),
                    FoodItem(food: Food(name: "Mehl", category: "Backzutaten", info: nil, nutritionFacts: nil), unit: .gram, quantity: 150),
                    FoodItem(food: Food(name: "Schokostücke", category: "Süßwaren", info: nil, nutritionFacts: nil), unit: .gram, quantity: 200)],
    instructions: ["Offen auf 180C° vorheizen","Schokolade und Butter über einem Wasserbad schmelzen", "Eier mit Vanille-Extrakt und Zucker aufschlagen", "abgekühlte Schokoladen-Butter-Masse langsam zu der Eiermasse geben", "erst Mehl und dann die Schokostücke hinzugeben", "Teig in eine Form oder aufs Backblech geben", "30 minuten in den Backoffen"],
image: "Brownie")

//print("Rezepttitel: \(pastaRecipe.title)")
//print("Zutaten: \(pastaRecipe.ingredients)")
//print("Anleitung: \(pastaRecipe.instructions)")
//if let image = pastaRecipe.image {
//    print("Bild: \(image)")
//}
