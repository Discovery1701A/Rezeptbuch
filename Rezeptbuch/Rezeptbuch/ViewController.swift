//
//  ViewController.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 10.03.24.
//

import Foundation

struct TagStruct: Hashable, Equatable {
    var id: UUID
    var name: String

    init(name: String, id: UUID = UUID()) {
        self.name = name
        self.id = id
    }

    // Initializer from Core Data managed object
    init(from managedObject: Tag) {
        self.name = managedObject.name ?? ""
        self.id = managedObject.id ?? UUID()
    }
}

// Nutritional information encapsulated in a structure
struct NutritionFactsStruct: Equatable, Hashable {
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

// Structure to represent a food item, including nutritional details
struct FoodStruct: Hashable, Equatable {
    var id: UUID
    var name: String
    var category: String?
    var info: String?
    var nutritionFacts: NutritionFactsStruct?
    var tags: [TagStruct]?

    static func == (lhs: FoodStruct, rhs: FoodStruct) -> Bool {
        return lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.info == rhs.info &&
               lhs.nutritionFacts == rhs.nutritionFacts &&
               lhs.tags == rhs.tags
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(info)
        hasher.combine(nutritionFacts)
        hasher.combine(tags)
    }
}

// Recipe structure containing details about food preparation
struct Recipe {
    var id: UUID
    var title: String
    var ingredients: [FoodItemStruct]
    var instructions: [String]
    var image: String? // Path to an image file or URL
    var portion: PortionsInfo?
    var cake: CakeInfo? // Enum for cake information
    var videoLink: String?
    var info: String? // Additional information about the recipe
    var tags: [TagStruct]? // Tags associated with the recipe
}

// Represents a collection of recipes typically found in a cookbook
struct RecipebookStruct {
    var id: UUID
    var name: String
    var recipes: [Recipe]
    var tags: [TagStruct]?

    init(id: UUID = UUID(), name: String, recipes: [Recipe] = [], tags: [TagStruct] = []) {
        self.id = id
        self.name = name
        self.recipes = recipes
        self.tags = tags
    }
}

// Food item used in a recipe, including quantity and unit
struct FoodItemStruct: Hashable, Equatable {
    var food: FoodStruct
    var unit: Unit
    var quantity: Double

    static func == (lhs: FoodItemStruct, rhs: FoodItemStruct) -> Bool {
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

// Enumerations for various details within the data model
enum Unit: String, CaseIterable {
    case gram = "g"
    case kilogram = "kg"
    case milliliter = "ml"
    case liter = "l"
    case piece = "Stk"
    case teaspoon = "Teelöffel"

    static func fromString(_ stringValue: String) -> Unit? {
        return Unit(rawValue: stringValue)
    }

    static func toString(_ unit: Unit) -> String {
        return unit.rawValue
    }
}

enum PortionsInfo: Equatable {
    case Portion(Double)
    case notPortion

    func stringValue() -> String {
        switch self {
        case .Portion(let value):
            return "Portion(\(value))"
        case .notPortion:
            return "notPortion"
        }
    }

    static func fromString(_ stringValue: String) -> PortionsInfo? {
            if stringValue.hasPrefix("Portion(") {
                let valueString = stringValue.replacingOccurrences(of: "Portion(", with: "").replacingOccurrences(of: ")", with: "")
                if let value = Double(valueString) {
                    return .Portion(value)
                }
            } else if stringValue == "notPortion" {
                return .notPortion
            }
            return nil
        }
}

enum CakeInfo: Equatable {
    case cake(form: Formen, size: CakeSize)
    case notCake

    func stringValue() -> String {
        switch self {
        case .cake(let form, let size):
            switch size {
            case .round(let diameter):
                return "cake(form: \(form), size: round(diameter: \(diameter)))"
            case .rectangular(let length, let width):
                return "cake(form: \(form), size: rectangular(length: \(length), width: \(width)))"
            }
        case .notCake:
            return "notCake"
        }
    }
}
extension CakeInfo {
    static func fromString(_ stringValue: String) -> CakeInfo? {
        if stringValue == "notCake" {
            return .notCake
        } else if stringValue.hasPrefix("cake(form: "), stringValue.hasSuffix(")") {
            let forme = stringValue.replacingOccurrences(of: "cake(form: ", with: "")
                .replacingOccurrences(of: ")", with: "")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let regex = try! NSRegularExpression(pattern: "(\\w+:\\s*\\w+\\(.*?\\))")
            let matches = regex.matches(in: stringValue, range: NSRange(location: 0, length: stringValue.utf16.count))
            let size = matches.map { match in
                (stringValue as NSString).substring(with: match.range)
            }
            let components = [forme[0], size[0]]
            print("conni ich dich auch")
            print(components)
            if components.count == 2 {
                print("John Nein")
                let formString = String(components[0].trimmingCharacters(in: .whitespaces))
                let sizeString = String(components[1].trimmingCharacters(in: .whitespaces))
                print(formString)
                let form = Formen(rawValue: formString) ?? .rund
                print(sizeString)
                if sizeString.hasPrefix("size: rectangular(length:"), sizeString.hasSuffix(")") {
                    let sizeComponents = sizeString.replacingOccurrences(of: "size: rectangular(length: ", with: "").replacingOccurrences(of: ")", with: "").split(separator: ", width: ")
                    print(sizeComponents)
                    if sizeComponents.count == 2 {
                        let lengthString = String(sizeComponents[0].trimmingCharacters(in: .whitespaces))
                        let widthString = String(sizeComponents[1].trimmingCharacters(in: .whitespaces))
                        print("Jakey baby")
                        print(sizeComponents)
                        if let length = Double(lengthString), let width = Double(widthString) {
                            return .cake(form: form, size: .rectangular(length: length, width: width))
                        }
                    }
                } else if sizeString.hasPrefix("size: round(diameter: "), sizeString.hasSuffix(")") {
                    let diameterString = sizeString.replacingOccurrences(of: "size: round(diameter: ", with: "").replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces)
                    if let diameter = Double(diameterString) {
                        return .cake(form: form, size: .round(diameter: diameter))
                    }
                }
            }
        }
        return nil
    }
}

enum Formen: String, CaseIterable {
    case rund = "Rund"
    case eckig = "Rechteckig"
}

enum CakeSize: Equatable {
    case round(diameter: Double)
    case rectangular(length: Double, width: Double)
}

func createTags(_ names: [String]) -> [TagStruct] {
    return names.map { TagStruct(name: $0) }
}

let emptyFood = FoodStruct(id: UUID(), name: "")

let tomate = FoodStruct(id: UUID(), name: "Tomate", category: "Obst")
let schoki = FoodStruct(id: UUID(), name: "Schokolade", category: "Süßwaren")
let zartbitterSchokolade = FoodStruct(
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


