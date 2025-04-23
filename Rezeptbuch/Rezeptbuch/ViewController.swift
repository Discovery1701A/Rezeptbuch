//
//  ViewController.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 10.03.24.
//

import Foundation

/// Struktur zur Darstellung eines Tags, das mit Rezepten oder Lebensmitteln verknüpft ist.
struct TagStruct: Hashable, Equatable, Identifiable {
    var id: UUID  // Eindeutige Identifikation des Tags
    var name: String  // Name des Tags

    /// Initialisiert ein Tag mit einem Namen und einer optionalen UUID.
    init(name: String, id: UUID = UUID()) {
        self.name = name
        self.id = id
    }

    /// Erstellt ein Tag aus einem Core Data-Managed-Object.
    /// - Parameter managedObject: Das `Tag`-Objekt aus Core Data.
    init(from managedObject: Tag) {
        self.name = managedObject.name ?? ""  // Falls `name` nil ist, wird ein leerer String gesetzt.
        self.id = managedObject.id ?? UUID()  // Falls `id` nil ist, wird eine neue UUID generiert.
    }
}

/// Struktur zur Speicherung von Nährwertangaben.
struct NutritionFactsStruct: Equatable, Hashable {
    var calories: Int?  // Kaloriengehalt (optional)
    var protein: Double?  // Proteingehalt in Gramm (optional)
    var carbohydrates: Double?  // Kohlenhydratgehalt in Gramm (optional)
    var fat: Double?  // Fettgehalt in Gramm (optional)

    /// Berechnet einen Hash-Wert für die Struktur, um sie in Mengen (Sets) oder als Schlüssel in Dictionaries zu verwenden.
    func hash(into hasher: inout Hasher) {
        hasher.combine(calories)
        hasher.combine(protein)
        hasher.combine(carbohydrates)
        hasher.combine(fat)
    }
}

/// Struktur zur Darstellung eines Lebensmittels.
struct FoodStruct: Hashable, Equatable, Identifiable {
    var id: UUID  // Eindeutige Identifikation des Lebensmittels
    var name: String  // Name des Lebensmittels
    var category: String?  // Kategorie des Lebensmittels (z. B. Obst, Gemüse, Fleisch)
    var density: Double?  // Dichte für Umrechnungen zwischen Masse und Volumen (optional)
    var info: String?  // Zusätzliche Informationen über das Lebensmittel (optional)
    var nutritionFacts: NutritionFactsStruct?  // Nährwertangaben (optional)
    var tags: [TagStruct]?  // Zugehörige Tags (optional)

    /// Vergleichsoperator für `FoodStruct`
    static func == (lhs: FoodStruct, rhs: FoodStruct) -> Bool {
        return lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.density == rhs.density &&
               lhs.info == rhs.info &&
               lhs.nutritionFacts == rhs.nutritionFacts &&
               lhs.tags == rhs.tags
    }

    /// Berechnet einen Hash-Wert für `FoodStruct`, um es in Mengen (Sets) oder als Schlüssel in Dictionaries zu verwenden.
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(density)
        hasher.combine(info)
        hasher.combine(nutritionFacts)
        hasher.combine(tags)
    }
}
public struct InstructionItem: Codable, Identifiable, Hashable {
    public var id = UUID()
    public var number: Int?
    public var text: String
    public var uuids: [UUID]

    public init(id: UUID = UUID(), number: Int? = nil, text: String, uuids: [UUID]) {
        self.id = id
        self.number = number
        self.text = text
        self.uuids = uuids
    }
}

/// Struktur für ein Rezept mit Zutaten, Anweisungen und Metadaten.
struct Recipe: Identifiable, Equatable {
    var id: UUID  // Eindeutige Identifikation des Rezepts
    var title: String  // Titel des Rezepts
    var ingredients: [FoodItemStruct]  // Liste der Zutaten
    var instructions: [InstructionItem]  // Kochanweisungen als Liste von Schritten
    var image: String?  // Name oder Pfad zum Bild des Rezepts (optional)
    var portion: PortionsInfo?  // Portionsangaben (optional)
    var cake: CakeInfo?  // Spezielle Kucheninformationen (optional)
    var videoLink: String?  // Link zu einem Video-Tutorial (optional)
    var info: String?  // Zusätzliche Informationen über das Rezept (optional)
    var tags: [TagStruct]?  // Zugehörige Tags für das Rezept (optional)
    var recipeBookIDs: [UUID]?  // IDs der Rezeptbücher, in denen dieses Rezept enthalten ist (optional)

    /// Erstellt ein leeres Rezept als Platzhalter.
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

    /// Vergleichsoperator für `Recipe`-Strukturen.
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

/// Struktur zur Darstellung eines Rezeptbuchs, das mehrere Rezepte und Tags enthält.
struct RecipebookStruct: Hashable, Identifiable {
    var id: UUID  // Eindeutige Identifikation des Rezeptbuchs
    var name: String  // Name des Rezeptbuchs
    var recipes: [Recipe]  // Liste der enthaltenen Rezepte
    var tags: [TagStruct]?  // Zugehörige Tags (optional)

    /// Initialisiert ein Rezeptbuch mit einem Namen, einer Liste von Rezepten und Tags.
    init(id: UUID = UUID(), name: String, recipes: [Recipe] = [], tags: [TagStruct] = []) {
        self.id = id
        self.name = name
        self.recipes = recipes
        self.tags = tags
    }

    /// Implementierung des `Hashable`-Protokolls für die Verwendung in Mengen (`Set`) oder als Dictionary-Schlüssel.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }

    /// Vergleichsoperator für `RecipebookStruct`.
    static func == (lhs: RecipebookStruct, rhs: RecipebookStruct) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.recipes == rhs.recipes && lhs.tags == rhs.tags
    }
}

/// Struktur für eine Zutat in einem Rezept, einschließlich Menge, Einheit, Rezeptkomponente und Positionsnummer.
struct FoodItemStruct: Hashable, Equatable, Identifiable {
    var food: FoodStruct                      // Lebensmittel
    var unit: Unit                            // Einheit der Menge (z. B. Gramm, Liter)
    var quantity: Double                      // Menge
    var id: UUID                              // Eindeutige ID
    var recipeComponent: String?               // z. B. "CREME", "BODEN", "FRUCHTSPIEGEL"
    var number: Int64?                        // Position innerhalb einer Rezeptkomponente

    /// Vergleichsoperator
    static func == (lhs: FoodItemStruct, rhs: FoodItemStruct) -> Bool {
        return lhs.food == rhs.food &&
               lhs.unit == rhs.unit &&
               lhs.quantity == rhs.quantity &&
               lhs.id == rhs.id &&
               lhs.recipeComponent == rhs.recipeComponent &&
               lhs.number == rhs.number
    }

    /// Hash-Funktion
    func hash(into hasher: inout Hasher) {
        hasher.combine(food)
        hasher.combine(unit)
        hasher.combine(quantity)
        hasher.combine(id)
        hasher.combine(recipeComponent)
        hasher.combine(number)
    }
}

/// Aufzählung der möglichen Maßeinheiten für Lebensmittel.
enum Unit: String, CaseIterable, Hashable {
    case gram = "g"
    case kilogram = "kg"
    case milliliter = "ml"
    case liter = "l"
    case piece = "Stk"
    case teaspoon = "Teelöffel"
    case tablespoon = "Esslöffel"
    case cup = "Cup"

    /// Wandelt eine Zeichenkette in eine `Unit` um.
    static func fromString(_ stringValue: String) -> Unit? {
        return Unit(rawValue: stringValue)
    }

    /// Wandelt eine `Unit` in eine Zeichenkette um.
    static func toString(_ unit: Unit) -> String {
        return unit.rawValue
    }

    /// Konvertiert eine Menge von einer Einheit in eine andere.
    /// - Parameter value: Der umzurechnende Wert.
    /// - Parameter from: Die Ausgangseinheit.
    /// - Parameter to: Die Zieleinheit.
    /// - Parameter density: Die Dichte des Lebensmittels (optional, standardmäßig 1.0).
    /// - Returns: Der konvertierte Wert oder `nil`, falls eine Umrechnung nicht möglich ist.
    static func convert(value: Double, from: Unit, to: Unit, density: Double = 1.0) -> Double? {
        // Definiert Mengen- und Volumeneinheiten für direkte Umrechnung
        let massUnits: Set<Unit> = [.gram, .kilogram]
        let volumeUnits: Set<Unit> = [.milliliter, .liter, .cup, .teaspoon, .tablespoon]

        // Umrechnung innerhalb von Masseneinheiten (g, kg)
        if massUnits.contains(from) && massUnits.contains(to) {
            switch (from, to) {
            case (.gram, .kilogram): return value / 1000.0
            case (.kilogram, .gram): return value * 1000.0
            default: return value
            }
        }

        // Umrechnung innerhalb von Volumeneinheiten (ml, l, cup, teaspoon, tablespoon)
        if volumeUnits.contains(from) && volumeUnits.contains(to) {
            let mlValue: Double = {
                switch from {
                case .milliliter: return value
                case .liter: return value * 1000.0
                case .cup: return value * 240.0
                case .teaspoon: return value * 5.0
                case .tablespoon: return value * 15.0
                default: return 0.0
                }
            }()

            return {
                switch to {
                case .milliliter: return mlValue
                case .liter: return mlValue / 1000.0
                case .cup: return mlValue / 240.0
                case .teaspoon: return mlValue / 5.0
                case .tablespoon: return mlValue / 15.0
                default: return nil
                }
            }()
        }

        // Sicherheitsprüfung: Dichte darf nicht 0 oder negativ sein.
        guard density > 0 else { return nil }

        // Schritt 1: Umrechnung in Basiseinheit (Gramm)
        let baseValue: Double? = {
            switch from {
            case .gram: return value
            case .kilogram: return value * 1000.0
            case .milliliter: return value * density
            case .liter: return value * 1000.0 * density
            case .teaspoon: return value * density * 5.0
            case .tablespoon: return value * density * 15.0
            case .cup: return value * density * 240.0
            case .piece: return nil
            }
        }()

        guard let base = baseValue else { return nil }

        // Schritt 2: Umrechnung von Gramm in Ziel-Einheit
        return {
            switch to {
            case .gram: return base
            case .kilogram: return base / 1000.0
            case .milliliter: return base / density
            case .liter: return base / 1000.0 / density
            case .teaspoon: return base / 5.0 / density
            case .tablespoon: return base / 15.0 / density
            case .cup: return base / 240.0 / density
            case .piece: return nil
            }
        }()
    }
}
/// Enum zur Darstellung der Portionsinformationen eines Rezepts.
enum PortionsInfo: Equatable {
    case Portion(Double)  // Enthält eine numerische Portionsgröße
    case notPortion  // Gibt an, dass keine Portionen definiert sind

    /// Konvertiert `PortionsInfo` in eine Zeichenkette.
    func stringValue() -> String {
        switch self {
        case .Portion(let value):
            return "Portion(\(value))"
        case .notPortion:
            return "notPortion"
        }
    }

    /// Erstellt ein `PortionsInfo`-Objekt aus einer Zeichenkette.
    static func fromString(_ stringValue: String) -> PortionsInfo? {
        if stringValue.hasPrefix("Portion(") {
            let valueString = stringValue
                .replacingOccurrences(of: "Portion(", with: "")
                .replacingOccurrences(of: ")", with: "")
            if let value = Double(valueString) {
                return .Portion(value)
            }
        } else if stringValue == "notPortion" {
            return .notPortion
        }
        return nil
    }
}

/// Enum zur Darstellung von Kucheninformationen.
enum CakeInfo: Equatable {
    case cake(form: Formen, size: CakeSize)  // Enthält Form und Größe des Kuchens
    case notCake  // Gibt an, dass es sich nicht um einen Kuchen handelt

    /// Konvertiert `CakeInfo` in eine Zeichenkette.
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
    /// Gibt die Form des Kuchens zurück.
    var form: Formen? {
        switch self {
        case .cake(let form, _):
            return form
        case .notCake:
            return nil
        }
    }

    /// Gibt die Größe des Kuchens zurück.
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
    /// Erstellt ein `CakeInfo`-Objekt aus einer Zeichenkette.
    static func fromString(_ stringValue: String) -> CakeInfo? {
        if stringValue == "notCake" {
            return .notCake
        } else if stringValue.hasPrefix("cake(form: "), stringValue.hasSuffix(")") {
            let forme = stringValue
                .replacingOccurrences(of: "cake(form: ", with: "")
                .replacingOccurrences(of: ")", with: "")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            let regex = try! NSRegularExpression(pattern: "(\\w+:\\s*\\w+\\(.*?\\))")
            let matches = regex.matches(in: stringValue, range: NSRange(location: 0, length: stringValue.utf16.count))
            let size = matches.map { match in
                (stringValue as NSString).substring(with: match.range)
            }
            let components = [forme[0], size[0]]
//            print(components)

            if components.count == 2 {
                let formString = String(components[0].trimmingCharacters(in: .whitespaces))
                let sizeString = String(components[1].trimmingCharacters(in: .whitespaces))
//                print(formString)

                let form = Formen(rawValue: formString) ?? .rund
//                print(sizeString)

                // Falls es sich um eine rechteckige Form handelt
                if sizeString.hasPrefix("size: rectangular(length:"), sizeString.hasSuffix(")") {
                    let sizeComponents = sizeString
                        .replacingOccurrences(of: "size: rectangular(length: ", with: "")
                        .replacingOccurrences(of: ")", with: "")
                        .split(separator: ", width: ")
//                    print(sizeComponents)

                    if sizeComponents.count == 2 {
                        let lengthString = String(sizeComponents[0].trimmingCharacters(in: .whitespaces))
                        let widthString = String(sizeComponents[1].trimmingCharacters(in: .whitespaces))

                        if let length = Double(lengthString), let width = Double(widthString) {
                            return .cake(form: form, size: .rectangular(length: length, width: width))
                        }
                    }
                }
                // Falls es sich um eine runde Form handelt
                else if sizeString.hasPrefix("size: round(diameter: "), sizeString.hasSuffix(")") {
                    let diameterString = sizeString
                        .replacingOccurrences(of: "size: round(diameter: ", with: "")
                        .replacingOccurrences(of: ")", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    if let diameter = Double(diameterString) {
                        return .cake(form: form, size: .round(diameter: diameter))
                    }
                }
            }
        }
        return nil
    }
}

/// Enum zur Darstellung der möglichen Kuchenformen.
enum Formen: String, CaseIterable {
    case rund = "Rund"
    case eckig = "Eckig"
}

/// Enum zur Darstellung der Größe eines Kuchens.
enum CakeSize: Equatable {
    case round(diameter: Double)  // Rund mit Durchmesser
    case rectangular(length: Double, width: Double)  // Rechteckig mit Länge und Breite
}

/// Erstellt eine Liste von `TagStruct`-Objekten basierend auf einer Liste von Namen.
func createTags(_ names: [String]) -> [TagStruct] {
    return names.map { TagStruct(name: $0) }
}
