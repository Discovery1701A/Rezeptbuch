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
    var ingredients: [FoodItemStruct]
    var instructions: [String]
    var image: String? // Pfad zur Bilddatei oder URL
    var portion: PortionsInfo?
    var cake: CakeInfo? // CakeInfo-Enum für Informationen über Kuchen
    var videoLink: String?

    // Implementierung des Equatable-Protokolls
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}

// Enum für Informationen über Portioen
enum PortionsInfo: Equatable {
    case Portion(Double)
    case notPortion

    static func == (lhs: PortionsInfo, rhs: PortionsInfo) -> Bool {
        switch (lhs, rhs) {
        case let (.Portion(value1), .Portion(value2)):
            return value1 == value2
        case (.notPortion, .notPortion):
            return true
        default:
            return false
        }
    }
}


// Enum für Informationen über Kuchen
enum CakeInfo: Equatable {
    case cake(form: Formen, size: CakeSize) // Kuchen mit Form und Größe
    case notCake // Nicht als Kuchen klassifiziert
    static func == (lhs: CakeInfo, rhs: CakeInfo) -> Bool {
        switch (lhs, rhs) {
        case let (.cake(form1, size1), .cake(form2, size2)):
            return form1 == form2 && size1 == size2
        case (.notCake, .notCake):
            return true
        default:
            return false
        }
    }
}



// Enum für die Form des Kuchens
enum Formen: String, CaseIterable {
    case rund = "rund"
    case eckig = "eckig"
}

// Enum für die Größe des Kuchens
enum CakeSize: Equatable {
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
extension Unit {
    static func fromString(_ stringValue: String) -> Unit? {
        return Unit(rawValue: stringValue)
    }
}
extension Unit {
    static func toString(_ unit: Unit) -> String {
        return unit.rawValue
    }
}
extension PortionsInfo {
    func stringValue() -> String {
        switch self {
        case .Portion(let value):
            return "Portion(\(value))"
        case .notPortion:
            return "notPortion"
        }
    }
}

extension CakeInfo {
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

extension PortionsInfo {
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

extension CakeInfo {
    static func fromString(_ stringValue: String) -> CakeInfo? {
        if stringValue == "notCake" {
            return .notCake
        } else if stringValue.hasPrefix("cake(form: ") && stringValue.hasSuffix(")") {
            let forme = stringValue.replacingOccurrences(of: "cake(form: ", with: "")
                                         .replacingOccurrences(of: ")", with: "")
                                         .split(separator: ",")
                                         .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let regex = try! NSRegularExpression(pattern: "(\\w+:\\s*\\w+\\(.*?\\))")
            let matches = regex.matches(in: stringValue, range: NSRange(location: 0, length: stringValue.utf16.count))
            let size = matches.map { match in
                (stringValue as NSString).substring(with: match.range)
            }
            let components = [forme[0],size[0]]
            print("conni ich dich auch")
            print(components)
            if components.count == 2 {
                print("John Nein")
                let formString = String(components[0].trimmingCharacters(in: .whitespaces))
                let sizeString = String(components[1].trimmingCharacters(in: .whitespaces))
                print(formString)
                let form = Formen(rawValue: formString) ?? .rund
                print(sizeString)
                if sizeString.hasPrefix("size: rectangular(length:") && sizeString.hasSuffix(")") {
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
                } else if sizeString.hasPrefix("size: round(diameter: ") && sizeString.hasSuffix(")") {
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



struct FoodStruct: Hashable, Equatable {
    var name: String
    var category: String?
    var info : String?
    var nutritionFacts: NutritionFactsStruct?

    static func == (lhs: FoodStruct, rhs: FoodStruct) -> Bool {
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


let emptyFood = FoodStruct(name: "")

let tomate = FoodStruct(name: "Tomate", category: "Obst")
let schoki = FoodStruct(name: "Schokolade", category: "Süßwaren")
let zartbitterSchokolade = FoodStruct(name: "Butter", category: "Milchprodukte", info: nil, nutritionFacts: NutritionFactsStruct(calories: 741, protein: 0.7, carbohydrates: 0.6, fat: 83 ))
let vanilleExtrakt = FoodStruct(name: "Vanille-Extrakt", category: "Gewürze", info: nil, nutritionFacts:
                            NutritionFactsStruct(calories: 288,protein: 0.1,carbohydrates: 12.7,fat: 0.1))
let zucker = FoodStruct(name: "Zucker", category: "Backzutaten", info: nil, nutritionFacts: NutritionFactsStruct(calories: 405, protein: 0, carbohydrates: 99.8, fat: 0))
let eier = FoodStruct(name: "Eier", category: "Eier & Eiprodukte", info: nil, nutritionFacts: NutritionFactsStruct(
    calories: 156,
    protein: 13,
    carbohydrates: 1.1,
    fat: 11.3))
let mehl = FoodStruct(name: "Mehl", category: "Backzutaten", info: nil, nutritionFacts: NutritionFactsStruct(
    calories: 348,
    protein: 10,
    carbohydrates: 72.3,
    fat: 0
))

let schokostücke = FoodStruct(name: "Schokostücke", category: "Süßwaren", info: nil, nutritionFacts: NutritionFactsStruct(
    calories: 484,
    protein: 7.9,
    carbohydrates: 23,
    fat: 36.2
))


// Beispiel für die Verwendung
let pastaRecipe = Recipe(
    id:1,
    title: "Spaghetti Bolognese",
    ingredients: [ FoodItemStruct(food: FoodStruct(name: "Hackfleisch", category: "Fleisch & Wurst", info: nil, nutritionFacts: nil), unit: .gram, quantity: 500),
                   FoodItemStruct(food: FoodStruct(name: "Zwiebel", category: "Gemüse", info: nil, nutritionFacts: nil), unit: .piece, quantity: 1),
                   FoodItemStruct(food: FoodStruct(name: "Knoblauchzehen", category: "Gemüse", info: nil, nutritionFacts: nil), unit: .piece, quantity: 2),
                   FoodItemStruct(food: FoodStruct(name: "Tomatensoße", category: "Saucen", info: nil, nutritionFacts: nil), unit: .milliliter, quantity: 500),
                   FoodItemStruct(food: FoodStruct(name: "Spaghetti", category: "Nudeln & Teigwaren", info: nil, nutritionFacts: nil), unit: .gram, quantity: 250)],
    instructions: ["Hackfleisch anbraten", "Zwiebel und Knoblauch hinzufügen", "Tomatensoße dazugeben", "Spaghetti kochen"],
    image: "spaghetti-mit-schneller-tomatensosse",
    portion: .Portion(4), cake: .notCake
)
let brownie = Recipe(
    id:2,
    title: "Brownie",
    ingredients: [  FoodItemStruct(food: FoodStruct(name: "Zartbitter Schokolade", category: "Süßwaren", info: nil, nutritionFacts: NutritionFactsStruct(
        calories: 514,
        protein: 8.1,
        carbohydrates: 46.3,
        fat: 31.1)), unit: .gram, quantity: 250),
                    FoodItemStruct(food: zartbitterSchokolade, unit: .gram, quantity: 250),
                    FoodItemStruct(food:vanilleExtrakt, unit: .teaspoon, quantity: 1),
                    FoodItemStruct(food: zucker, unit: .gram, quantity: 350),
                    FoodItemStruct(food: eier, unit: .piece, quantity: 6),
                    FoodItemStruct(food: mehl, unit: .gram, quantity: 150),
                    FoodItemStruct(food: schokostücke, unit: .gram, quantity: 200)],
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
