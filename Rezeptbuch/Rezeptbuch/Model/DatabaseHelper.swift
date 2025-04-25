//
//  DatabaseHelper.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.11.24.
//
//  Daten wurden über ein Python-Programm eingefügt.
//  Die Daten stammen von YAZIO und wurden von ChatGPT für das Programm konvertiert.

import Foundation
import SQLite3

// MARK: - Database Helper Class

/// Diese Klasse hilft beim Zugriff auf eine SQLite-Datenbank.
class DatabaseHelper {
    var db: OpaquePointer? // Zeiger auf die geöffnete SQLite-Datenbank

    /// Initialisiert die Verbindung zur SQLite-Datenbank.
    /// - Parameter databasePath: Der Pfad zur SQLite-Datenbankdatei.
    init(databasePath: String) {
        if sqlite3_open(databasePath, &db) != SQLITE_OK {
            print("Fehler beim Öffnen der Datenbank: \(databasePath)")
        }
    }

    /// Schließt die Datenbankverbindung beim Löschen des Objekts.
    deinit {
        sqlite3_close(db)
    }

    /// Führt eine SQL-Abfrage aus und gibt die Ergebnisse als Array zurück.
    /// - Parameter query: Die SQL-Abfrage, die ausgeführt werden soll.
    /// - Parameter map: Eine Funktion, die eine Zeile des Ergebnisses verarbeitet und in den gewünschten Typ umwandelt.
    /// - Returns: Ein Array der abgefragten Objekte.
    func fetchAllRows<T>(query: String, map: @escaping (OpaquePointer?) -> T) -> [T] {
        var result: [T] = []
        var stmt: OpaquePointer?

        // Bereitet die SQL-Anfrage vor
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            // Geht durch die Ergebniszeilen und wendet die `map`-Funktion an
            while sqlite3_step(stmt) == SQLITE_ROW {
                result.append(map(stmt))
            }
        } else {
            print("Fehler beim Vorbereiten der Abfrage: \(query)")
        }

        sqlite3_finalize(stmt) // Gibt den Speicher des Statements frei
        return result
    }
}

// MARK: - Database Service Using Provided Structs

/// Diese Klasse bietet Methoden zum Laden spezifischer Daten aus der SQLite-Datenbank.
class DatabaseService {
    private let dbHelper: DatabaseHelper // Instanz des DatabaseHelper zur Kommunikation mit SQLite

    /// Initialisiert den DatabaseService mit einem gegebenen Datenbankpfad.
    init(databasePath: String) {
        self.dbHelper = DatabaseHelper(databasePath: databasePath)
    }

    /// Lädt alle Tags aus der Datenbank.
    /// - Returns: Ein Array von `TagStruct`-Objekten.
    func loadTags() -> [TagStruct] {
        let query = "SELECT id, name FROM Tag;"
        return dbHelper.fetchAllRows(query: query) { stmt in
            let id = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 0))) ?? UUID()
            let name = String(cString: sqlite3_column_text(stmt, 1))
            return TagStruct(name: name, id: id)
        }
    }

    /// Lädt die Nährwerte für eine bestimmte Zutat aus der Datenbank.
    /// - Parameter foodId: Die UUID der Zutat.
    /// - Returns: Ein `NutritionFactsStruct`-Objekt mit den Nährwerten oder `nil`, falls nicht gefunden.
    func loadNutritionFacts(for foodId: UUID) -> NutritionFactsStruct? {
        let query = "SELECT calories, protein, carbohydrates, fat FROM NutritionFacts WHERE food_id = '\(foodId.uuidString.lowercased())';"
        return dbHelper.fetchAllRows(query: query) { stmt in
            let calories = sqlite3_column_int(stmt, 0) // Kalorien als Integer
            let protein = sqlite3_column_double(stmt, 1) // Protein als Double
            let carbohydrates = sqlite3_column_double(stmt, 2) // Kohlenhydrate als Double
            let fat = sqlite3_column_double(stmt, 3) // Fett als Double
//            print("Nährwerte geladen:", calories, protein, carbohydrates, fat)
            return NutritionFactsStruct(
                calories: Int(calories),
                protein: protein,
                carbohydrates: carbohydrates,
                fat: fat
            )
        }.first // Gibt nur das erste (und einzige) Ergebnis zurück
    }

    /// Lädt die Tags für eine bestimmte Zutat aus der Datenbank.
    /// - Parameter foodId: Die UUID der Zutat.
    /// - Returns: Ein Array von `TagStruct`-Objekten.
    func loadFoodTags(for foodId: UUID) -> [TagStruct] {
        let query = """
        SELECT Tag.id, Tag.name
        FROM FoodTag
        INNER JOIN Tag ON FoodTag.tagId = Tag.id
        WHERE FoodTag.foodId = '\(foodId.uuidString.lowercased())';
        """
        return dbHelper.fetchAllRows(query: query) { stmt in
            let id = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 0))) ?? UUID()
            let name = String(cString: sqlite3_column_text(stmt, 1))
            return TagStruct(name: name, id: id)
        }
    }

    /// Lädt alle Lebensmittel aus der SQLite-Datenbank und gibt sie als `FoodStruct`-Array zurück.
    /// - Returns: Ein Array von `FoodStruct`-Objekten.
    func loadFoods() -> [FoodStruct] {
        print("Lade Lebensmittel...") // Debug-Ausgabe zur Kontrolle

        // SQL-Abfrage, um alle Lebensmittel mit Basisdaten zu laden
        let query = "SELECT id, name, category, info, density FROM Food;"

        // Übergib die Abfrage an den dbHelper, der alle Zeilen durchläuft
        return dbHelper.fetchAllRows(query: query) { stmt in
            // 📦 Extrahiere alle Spalten aus dem SQLite-Ergebnis

            // 🆔 ID (als UUID)
            let id = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 0))) ?? UUID()

            // 📝 Name des Lebensmittels
            let name = String(cString: sqlite3_column_text(stmt, 1))

            // 📂 Kategorie (z. B. "Getränk", "Obst", ...)
            let category = String(cString: sqlite3_column_text(stmt, 2))

            // ℹ️ Zusatzinformationen
            let info = String(cString: sqlite3_column_text(stmt, 3))

            // ⚖️ Dichte (z. B. g/ml)
            let density = Double(sqlite3_column_double(stmt, 4))

            // 🔗 Lade die zugehörigen Nährwerte aus einer anderen Tabelle
            let nutritionFacts = self.loadNutritionFacts(for: id)

            // 🔖 Lade die zugehörigen Tags (z. B. "vegan", "leicht")
            let tags = self.loadFoodTags(for: id)

            // 🧱 Baue die Struktur mit allen geladenen Daten
            return FoodStruct(
                id: id,
                name: name,
                category: category,
                density: density,
                info: info,
                nutritionFacts: nutritionFacts,
                tags: tags
            )
        }
    }
    
    
}
