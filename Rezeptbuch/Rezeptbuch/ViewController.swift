//
//  ViewController.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 10.03.24.
//

import Foundation

struct TagStruct: Hashable, Equatable, Identifiable {
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

struct FoodStruct: Hashable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var category: String?
    var density : Double?
    var info: String?
    var nutritionFacts: NutritionFactsStruct?
    var tags: [TagStruct]?

    static func == (lhs: FoodStruct, rhs: FoodStruct) -> Bool {
        return lhs.name == rhs.name &&
               lhs.category == rhs.category &&
            lhs.density == rhs.density &&
               lhs.info == rhs.info &&
               lhs.nutritionFacts == rhs.nutritionFacts &&
               lhs.tags == rhs.tags
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(density)
        hasher.combine(info)
        hasher.combine(nutritionFacts)
        hasher.combine(tags)
    }
}


// Recipe structure containing details about food preparation
struct Recipe: Identifiable, Equatable {
    var id: UUID
    var title: String
    var ingredients: [FoodItemStruct]
    var instructions: [String]
    var image: String?
    var portion: PortionsInfo?
    var cake: CakeInfo?
    var videoLink: String?
    var info: String?
    var tags: [TagStruct]?
    var recipeBookIDs: [UUID]?

    static var empty: Recipe {
        Recipe(
            id: UUID(),
            title: "",
            ingredients: [],
            instructions: [],
            image: nil,
            portion: nil,
            cake: nil,
            videoLink: nil,
            info: "",
            tags: []
        )
    }

    // Implementierung des Equatable-Protokolls
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.ingredients == rhs.ingredients &&
               lhs.instructions == rhs.instructions &&
               lhs.image == rhs.image &&
               lhs.portion == rhs.portion &&
               lhs.cake == rhs.cake &&
               lhs.videoLink == rhs.videoLink &&
               lhs.info == rhs.info &&
               lhs.tags == rhs.tags &&
               lhs.recipeBookIDs == rhs.recipeBookIDs
    }
}

struct RecipebookStruct: Hashable, Identifiable {
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

    // Hashable-Anforderungen
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }

    // Vergleichsoperator für Hashable
    static func == (lhs: RecipebookStruct, rhs: RecipebookStruct) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.recipes == rhs.recipes && lhs.tags == rhs.tags
    }
}


// Food item used in a recipe, including quantity and unit
struct FoodItemStruct: Hashable, Equatable {
    var food: FoodStruct
    var unit: Unit
    var quantity: Double
    let id: UUID
    

    static func == (lhs: FoodItemStruct, rhs: FoodItemStruct) -> Bool {
        return lhs.food == rhs.food &&
               lhs.unit == rhs.unit &&
               lhs.quantity == rhs.quantity
                lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(food)
        hasher.combine(unit)
        hasher.combine(quantity)
        hasher.combine(id)
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
                
                return "cake(form: \(form.rawValue), size: round(diameter: \(diameter)))"
            case .rectangular(let length, let width):
                return "cake(form: \(form.rawValue), size: rectangular(length: \(length), width: \(width)))"
            }
        case .notCake:
            return "notCake"
        }
    }
}
extension CakeInfo {
    var form: Formen? {
        switch self {
        case .cake(let form, _):
            return form
        case .notCake:
            return nil
        }
    }

    var size: CakeSize? {
        switch self {
        case .cake(_, let size):
            return size
        case .notCake:
            return nil
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
    case eckig = "Eckig"
}

enum CakeSize: Equatable {
    case round(diameter: Double)
    case rectangular(length: Double, width: Double)
}

func createTags(_ names: [String]) -> [TagStruct] {
    return names.map { TagStruct(name: $0) }
}
