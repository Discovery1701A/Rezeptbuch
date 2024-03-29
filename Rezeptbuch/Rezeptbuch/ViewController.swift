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
    var portion: PortionsInfo?
    var cake: CakeInfo? // CakeInfo-Enum für Informationen über Kuchen

    // Implementierung des Equatable-Protokolls
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}

// Enum für Informationen über Portioen
enum PortionsInfo {
    case Portion(Double)
    case notPortion
}

// Enum für Informationen über Kuchen
enum CakeInfo {
    case cake(form: Formen, size: CakeSize) // Kuchen mit Form und Größe
    case notCake // Nicht als Kuchen klassifiziert
}

// Enum für die Form des Kuchens
enum Formen: String, CaseIterable {
    case rund = "rund"
    case eckig = "eckig"
}

// Enum für die Größe des Kuchens
enum CakeSize {
    case round(diameter: Double) // Durchmesser für runde Formen
    case rectangular(length: Double, width: Double) // Länge und Breite für eckige Formen
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


let emptyFood = Food(name: "")

let tomate = Food(name: "Tomate", category: "Obst")
let schoki = Food(name: "Schokolade", category: "Süßwaren")
let zartbitterSchokolade = Food(name: "Butter", category: "Milchprodukte", info: nil, nutritionFacts: NutritionFacts(calories: 741, protein: 0.7, carbohydrates: 0.6, fat: 83 ))
let vanilleExtrakt = Food(name: "Vanille-Extrakt", category: "Gewürze", info: nil, nutritionFacts:
                            NutritionFacts(calories: 288,protein: 0.1,carbohydrates: 12.7,fat: 0.1))
let zucker = Food(name: "Zucker", category: "Backzutaten", info: nil, nutritionFacts: NutritionFacts(calories: 405, protein: 0, carbohydrates: 99.8, fat: 0))
let eier = Food(name: "Eier", category: "Eier & Eiprodukte", info: nil, nutritionFacts: NutritionFacts(
    calories: 156,
    protein: 13,
    carbohydrates: 1.1,
    fat: 11.3))
let mehl = Food(name: "Mehl", category: "Backzutaten", info: nil, nutritionFacts: NutritionFacts(
    calories: 348,
    protein: 10,
    carbohydrates: 72.3,
    fat: 0
))

let schokostücke = Food(name: "Schokostücke", category: "Süßwaren", info: nil, nutritionFacts: NutritionFacts(
    calories: 484,
    protein: 7.9,
    carbohydrates: 23,
    fat: 36.2
))


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
    ingredients: [  FoodItem(food: Food(name: "Zartbitter Schokolade", category: "Süßwaren", info: nil, nutritionFacts: NutritionFacts(
        calories: 514,
        protein: 8.1,
        carbohydrates: 46.3,
        fat: 31.1)), unit: .gram, quantity: 250),
                    FoodItem(food: zartbitterSchokolade, unit: .gram, quantity: 250),
                    FoodItem(food:vanilleExtrakt, unit: .teaspoon, quantity: 1),
                    FoodItem(food: zucker, unit: .gram, quantity: 350),
                    FoodItem(food: eier, unit: .piece, quantity: 6),
                    FoodItem(food: mehl, unit: .gram, quantity: 150),
                    FoodItem(food: schokostücke, unit: .gram, quantity: 200)],
    instructions: ["Offen auf 180C° vorheizen","Schokolade und Butter über einem Wasserbad schmelzen", "Eier mit Vanille-Extrakt und Zucker aufschlagen", "abgekühlte Schokoladen-Butter-Masse langsam zu der Eiermasse geben", "erst Mehl und dann die Schokostücke hinzugeben", "Teig in eine Form oder aufs Backblech geben", "30 minuten in den Backoffen"],
image: "Brownie"
    ,cake: .cake(form: .eckig, size: .rectangular(length: 35, width: 40))
)

//print("Rezepttitel: \(pastaRecipe.title)")
//print("Zutaten: \(pastaRecipe.ingredients)")
//print("Anleitung: \(pastaRecipe.instructions)")
//if let image = pastaRecipe.image {
//    print("Bild: \(image)")
//}
