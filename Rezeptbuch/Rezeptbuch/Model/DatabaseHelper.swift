//
//  DatabaseHelper.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.11.24.
//Daten wurden über ein Python programm eingefügt. Daten stammen von YAZIO und wurden von Chat GPT in das Programm übertragen

import Foundation
import SQLite3

// MARK: - Database Helper Class

class DatabaseHelper {
    var db: OpaquePointer?

    init(databasePath: String) {
        if sqlite3_open(databasePath, &db) != SQLITE_OK {
            print("Failed to open database at \(databasePath)")
        }
    }

    deinit {
        sqlite3_close(db)
    }

    func fetchAllRows<T>(query: String, map: @escaping (OpaquePointer?) -> T) -> [T] {
        var result: [T] = []
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                result.append(map(stmt))
            }
        } else {
            print("Failed to prepare query: \(query)")
        }

        sqlite3_finalize(stmt)
        return result
    }
}

// MARK: - Database Service Using Provided Structs

class DatabaseService {
    private let dbHelper: DatabaseHelper

    init(databasePath: String) {
        self.dbHelper = DatabaseHelper(databasePath: databasePath)
    }

    func loadTags() -> [TagStruct] {
        let query = "SELECT id, name FROM Tag;"
        return dbHelper.fetchAllRows(query: query) { stmt in
            let id = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 0))) ?? UUID()
            let name = String(cString: sqlite3_column_text(stmt, 1))
            return TagStruct(name: name, id: id)
        }
    }

    func loadNutritionFacts(for foodId: UUID) -> NutritionFactsStruct? {
        let query = "SELECT calories, protein, carbohydrates, fat FROM NutritionFacts WHERE food_id = '\(foodId.uuidString.lowercased())';"
        return dbHelper.fetchAllRows(query: query) { stmt in
            let calories = sqlite3_column_int(stmt, 0)
            let protein = sqlite3_column_double(stmt, 1)
            let carbohydrates = sqlite3_column_double(stmt, 2)
            let fat = sqlite3_column_double(stmt, 3)
//            print("werteeeee",calories,protein,carbohydrates,fat)
            return NutritionFactsStruct(
                calories: Int(calories),
                protein: protein,
                carbohydrates: carbohydrates,
                fat: fat
            )
        }.first
    }

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

    func loadFoods() -> [FoodStruct] {
        print("lade")
        let query = "SELECT id, name, category, info FROM Food;"
        return dbHelper.fetchAllRows(query: query) { stmt in
            let id = UUID(uuidString: String(cString: sqlite3_column_text(stmt, 0))) ?? UUID()
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let category = String(cString: sqlite3_column_text(stmt, 2))
            let info = String(cString: sqlite3_column_text(stmt, 3))

            let nutritionFacts = self.loadNutritionFacts(for: id)
            let tags = self.loadFoodTags(for: id)

            return FoodStruct(
                id: id,
                name: name,
                category: category,
                info: info,
                nutritionFacts: nutritionFacts,
                tags: tags
            )
        }
    }
}

// MARK: - Example Usage

let databasePath = "/path/to/Rezeptbuch.sqlite" // Update this path with your database location

let databaseService = DatabaseService(databasePath: databasePath)

// Load data
let foods = databaseService.loadFoods()
let tags = databaseService.loadTags()

// Print the results
//print("Foods: \(foods)")
//print("Tags: \(tags)")
