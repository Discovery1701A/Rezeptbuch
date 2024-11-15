//
//  StartData.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 15.11.24.
//

import Foundation


let emptyFood = FoodStruct(id: UUID(), name: "")


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


let karotte = FoodStruct(
    id: UUID(),
    name: "Karotte",
    category: "Gemüse",
    info: "Eine knackige, orange Wurzelgemüse, reich an Vitamin A",
    nutritionFacts: NutritionFactsStruct(
        calories: 41,
        protein: 0.9,
        carbohydrates: 9.6,
        fat: 0.2
    ),
    tags: [TagStruct(name: "Gemüse")]
)

// Example 2: Brokkoli
let brokkoliNutritionFacts = NutritionFactsStruct(
    calories: 34,
    protein: 2.8,
    carbohydrates: 6.6,
    fat: 0.4
)
let brokkoli = FoodStruct(
    id: UUID(),
    name: "Brokkoli",
    category: "Gemüse",
    info: "Ein grünes Kreuzblütlergemüse, reich an Ballaststoffen und Vitaminen",
    nutritionFacts: brokkoliNutritionFacts,
    tags: [TagStruct(name: "Gemüse")]
)

// Example 3: Paprika (rot)
let paprikaNutritionFacts = NutritionFactsStruct(
    calories: 31,
    protein: 1.0,
    carbohydrates: 6.0,
    fat: 0.3
)
let paprika = FoodStruct(
    id: UUID(),
    name: "Rote Paprika",
    category: "Gemüse",
    info: "Eine süße und knackige rote Paprika, reich an Vitamin C",
    nutritionFacts: paprikaNutritionFacts,
    tags: [TagStruct(name: "Gemüse")]
)

// Example 4: Spinat
let spinatNutritionFacts = NutritionFactsStruct(
    calories: 23,
    protein: 2.9,
    carbohydrates: 3.6,
    fat: 0.4
)
let spinat = FoodStruct(
    id: UUID(),
    name: "Spinat",
    category: "Gemüse",
    info: "Ein grünes Blattgemüse, bekannt für seinen hohen Gehalt an Eisen und Vitaminen",
    nutritionFacts: spinatNutritionFacts,
    tags: [TagStruct(name: "Gemüse")]
)

// Example 5: Tomate
let tomateNutritionFacts = NutritionFactsStruct(
    calories: 18,
    protein: 0.9,
    carbohydrates: 3.9,
    fat: 0.2
)
let tomate = FoodStruct(
    id: UUID(),
    name: "Tomate",
    category: "Gemüse",
    info: "Eine rote, saftige Frucht mit hohem Wassergehalt, oft als Gemüse betrachtet",
    nutritionFacts: tomateNutritionFacts,
    tags: [TagStruct(name: "Gemüse")]
)





// Example recipe usage
let pastaRecipe = Recipe(
    id: UUID(),
    title: "Spaghetti Bolognese",
    ingredients: [
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Hackfleisch", category: "Fleisch & Wurst"), unit: .gram, quantity: 500),
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Zwiebel", category: "Gemüse"), unit: .piece, quantity: 1),
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Knoblauchzehen", category: "Gemüse"), unit: .piece, quantity: 2),
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Tomatensoße", category: "Saucen"), unit: .milliliter, quantity: 500),
        FoodItemStruct(food: FoodStruct(id: UUID(), name: "Spaghetti", category: "Nudeln & Teigwaren"), unit: .gram, quantity: 250)
    ],
    instructions: [
        "Hackfleisch anbraten",
        "Zwiebel und Knoblauch hinzufügen",
        "Tomatensoße dazugeben",
        "Spaghetti kochen"
    ],
    image: "spaghetti-mit-schneller-tomatensosse",
    portion: .Portion(4),
    cake: .notCake,
    tags: createTags(["Italienisch", "Nudelgericht", "Hauptgericht"])
)
let brownieRecipe = Recipe(
    id: UUID(),
    title: "Brownie",
    ingredients: [
        FoodItemStruct(food: zartbitterSchokolade, unit: .gram, quantity: 250),
        FoodItemStruct(food: butter, unit: .gram, quantity: 250),
        FoodItemStruct(food: vanilleExtrakt, unit: .teaspoon, quantity: 1),
        FoodItemStruct(food: zucker, unit: .gram, quantity: 350),
        FoodItemStruct(food: eier, unit: .piece, quantity: 6),
        FoodItemStruct(food: mehl, unit: .gram, quantity: 150),
        FoodItemStruct(food: schokostücke, unit: .gram, quantity: 200)
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
    image: "Brownie",
    cake: .cake(form: .eckig, size: .rectangular(length: 35, width: 40)),
    tags: createTags(["Dessert", "Schokoladenkuchen", "Süßigkeit"])
)


