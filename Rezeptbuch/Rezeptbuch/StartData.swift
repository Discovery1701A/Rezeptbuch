//
//  StartData.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 15.11.24.
//

import Foundation

/// Leere Lebensmittel-Struktur als Platzhalter.
let emptyFood = FoodStruct(id: UUID(), name: "")

/// Beispielhafte Lebensmitteldatenbank mit vordefinierten Lebensmitteln.
let zartbitterSchokolade = FoodStruct(
    id: UUID(),
    name: "Zartbitter Schokolade",
    category: "Süßwaren",
    info: "Dunkle Schokolade mit einem hohen Kakaoanteil, die weniger Zucker enthält als Milchschokolade und als eine gesündere Option gilt.",
    nutritionFacts: NutritionFactsStruct(
        calories: 530,
        protein: 4.9,
        carbohydrates: 45.9,
        fat: 31.8
    )
)

let butter = FoodStruct(
    id: UUID(),
    name: "Butter",
    category: "Milchprodukte",
    nutritionFacts: NutritionFactsStruct(calories: 741, protein: 0.7, carbohydrates: 0.6, fat: 83)
)

let vanilleExtrakt = FoodStruct(
    id: UUID(),
    name: "Vanille-Extrakt",
    category: "Gewürze",
    nutritionFacts: NutritionFactsStruct(calories: 288, protein: 0.1, carbohydrates: 12.7, fat: 0.1)
)

let zucker = FoodStruct(
    id: UUID(),
    name: "Zucker",
    category: "Backzutaten",
    nutritionFacts: NutritionFactsStruct(calories: 405, protein: 0, carbohydrates: 99.8, fat: 0)
)

let eier = FoodStruct(
    id: UUID(),
    name: "Eier",
    category: "Eier & Eiprodukte",
    nutritionFacts: NutritionFactsStruct(calories: 156, protein: 13, carbohydrates: 1.1, fat: 11.3)
)

let mehl = FoodStruct(
    id: UUID(),
    name: "Mehl",
    category: "Backzutaten",
    nutritionFacts: NutritionFactsStruct(calories: 348, protein: 10, carbohydrates: 72.3, fat: 0)
)

let schokostücke = FoodStruct(
    id: UUID(),
    name: "Schokostücke",
    category: "Süßwaren",
    nutritionFacts: NutritionFactsStruct(calories: 484, protein: 7.9, carbohydrates: 23, fat: 36.2)
)


/// Beispielhaftes Rezept für Spaghetti Bolognese.
let pastaRecipe = Recipe(
    id: UUID(),
    title: "Spaghetti Bolognese",
    ingredients: [
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Hackfleisch", category: "Fleisch & Wurst"), unit: .gram, quantity: 500, id: UUID()),
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Zwiebel", category: "Gemüse"), unit: .piece, quantity: 1, id: UUID()),
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Knoblauchzehen", category: "Gemüse"), unit: .piece, quantity: 2, id: UUID()),
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Tomatensoße", category: "Saucen"), unit: .milliliter, quantity: 500, id: UUID()),
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Spaghetti", category: "Nudeln & Teigwaren"), unit: .gram, quantity: 250, id: UUID())
    ],
    instructions: [
        "Hackfleisch anbraten",
        "Zwiebel und Knoblauch hinzufügen",
        "Tomatensoße dazugeben",
        "Spaghetti kochen"
    ],
    image: "spaghetti-mit-schneller-tomatensosse",  // Bildname für die Darstellung
    portion: .Portion(4),  // Das Rezept ist für 4 Portionen
    cake: .notCake,  // Kein Kuchen
    tags: createTags(["Italienisch", "Nudelgericht", "Hauptgericht"])  // Tags zur Kategorisierung
)

/// Beispielhaftes Rezept für Brownies.
let brownieRecipe = Recipe(
    id: UUID(),
    title: "Brownie",
    ingredients: [
        FoodItemStruct(food: zartbitterSchokolade, unit: .gram, quantity: 250, id: UUID()),
        FoodItemStruct(food: butter, unit: .gram, quantity: 250, id: UUID()),
        FoodItemStruct(food: vanilleExtrakt, unit: .teaspoon, quantity: 1, id: UUID()),
        FoodItemStruct(food: zucker, unit: .gram, quantity: 350, id: UUID()),
        FoodItemStruct(food: eier, unit: .piece, quantity: 6, id: UUID()),
        FoodItemStruct(food: mehl, unit: .gram, quantity: 150, id: UUID()),
        FoodItemStruct(food: schokostücke, unit: .gram, quantity: 200, id: UUID())
    ],
    instructions: [
        "Ofen auf 180°C vorheizen",
        "Schokolade und Butter über einem Wasserbad schmelzen",
        "Eier mit Vanille-Extrakt und Zucker aufschlagen",
        "Abgekühlte Schokoladen-Butter-Masse langsam zu der Eiermasse geben",
        "Erst Mehl und dann die Schokostücke hinzugeben",
        "Teig in eine Form oder aufs Backblech geben",
        "30 Minuten in den Backofen"
    ],
    image: "Brownie",  // Bildname für die Darstellung
    cake: .cake(form: .eckig, size: .rectangular(length: 35, width: 40)),  // Der Brownie hat eine rechteckige Form
    tags: createTags(["Dessert", "Schokoladenkuchen", "Süßigkeit"])  // Tags zur Kategorisierung
)
