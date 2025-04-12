import Foundation
import SwiftUICore
import CoreData
import UIKit
import SQLite3

/// `CoreDataManager` ist eine Singleton-Klasse, die für die Verwaltung der Core Data-Persistenzschicht zuständig ist.
class CoreDataManager {
    static let shared = CoreDataManager() // Singleton-Instanz
    
    /// Der `NSPersistentContainer` verwaltet die Core Data-Persistenz.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model") // Name des Core Data Modells
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Fehler beim Laden der persistenten Stores: \(error)")
            }
        }
        return container
    }()
    
    /// Gibt den verwalteten Kontext für Core Data zurück.
    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: Fetching Methods
    
    /// Ruft alle Lebensmittel (`FoodStruct`) aus der Datenbank ab.
    func fetchFoods() -> [FoodStruct] {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        do {
            return try managedContext.fetch(fetchRequest).map { FoodStruct(from: $0) }
        } catch {
            print("⚠️ Fehler beim Abrufen der Lebensmittel: \(error)")
            return []
        }
    }
    
    /// Ruft alle Tags (`TagStruct`) aus der Datenbank ab.
    func fetchTags() -> [TagStruct] {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        do {
            return try managedContext.fetch(fetchRequest).map { TagStruct(from: $0) }
        } catch {
            print("⚠️ Fehler beim Abrufen der Tags: \(error)")
            return []
        }
    }
    
    /// Ruft alle Rezepte (`Recipe`) aus der Datenbank ab.
    func fetchRecipes() -> [Recipe] {
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        do {
            return try managedContext.fetch(fetchRequest).map { Recipe(from: $0) }
        } catch {
            print("⚠️ Fehler beim Abrufen der Rezepte: \(error)")
            return []
        }
    }
    
    /// Ruft alle Rezeptbücher (`RecipebookStruct`) aus der Datenbank ab.
    func fetchRecipebooks() -> [RecipebookStruct] {
        let fetchRequest: NSFetchRequest<Recipebook> = Recipebook.fetchRequest()
        do {
            return try managedContext.fetch(fetchRequest).map { RecipebookStruct(from: $0) }
        } catch {
            print("⚠️ Fehler beim Abrufen der Rezeptbücher: \(error)")
            return []
        }
    }
    
    
    func recipeExists(id: UUID) -> Bool {
        let request = Recipes.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            let result = try persistentContainer.viewContext.fetch(request)
            return !result.isEmpty
        } catch {
            print("Fehler bei der Prüfung auf Duplikat: \(error)")
            return false
        }
    }
    
    // MARK: Saving Methods
    
    /// Speichert ein Rezept in einem bestimmten Rezeptbuch.
    func saveRecipe(_ recipe: Recipe, selectedRecipeBook: RecipebookStruct) {
        let recipeEntity = findOrCreateRecipeEntity(from: recipe) // Entität abrufen oder erstellen
        populateRecipeEntity(recipeEntity, from: recipe) // Felder setzen
        addRecipe(recipe, toRecipeBook: selectedRecipeBook) // Rezept zum Buch hinzufügen
        saveContext()
    }
    
    /// Speichert ein Rezept ohne Rezeptbuch.
    func saveRecipe(_ recipe: Recipe) {
        let recipeEntity = findOrCreateRecipeEntity(from: recipe)
        populateRecipeEntity(recipeEntity, from: recipe)
        print("✅ Rezept gespeichert: \(recipeEntity)")
        saveContext()
    }
    
    /// Speichert ein Rezept mit optionalem Überschreiben.
    /// Wenn `overwrite == false` und ein Rezept mit gleicher ID existiert, wird stattdessen ein neues Rezept mit neuer UUID erstellt.
    func saveRecipe(_ recipe: Recipe, overwrite: Bool) {
        var finalRecipe = recipe

        if !overwrite && recipeExists(id: recipe.id) {
            // Neue UUID vergeben, um Duplikate zu vermeiden
            finalRecipe.id = UUID()
            // 📸 Bild verschieben/umbenennen (falls vorhanden)
            if let oldPath = finalRecipe.image {
                let oldURL = URL(fileURLWithPath: oldPath)
                let newFileName = "\(finalRecipe.id).jpeg"
                print(newFileName)
                let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(newFileName)
                
                do {
                    if FileManager.default.fileExists(atPath: oldURL.path) {
                        try FileManager.default.moveItem(at: oldURL, to: newURL)
                        finalRecipe.image = newFileName
                        print("✅ Bild umbenannt für neue ID: \(newFileName)")
                    }
                } catch {
                    print("❌ Fehler beim Verschieben/Umbennenen des Bildes: \(error)")
                }
            }
            
            let recipeEntity = findOrCreateRecipeEntity(from: finalRecipe)
            populateRecipeEntity(recipeEntity, from: finalRecipe)
            print("✅ Rezept gespeichert: \(recipeEntity)")
        } else if overwrite && recipeExists(id: recipe.id) {
           
                        finalRecipe.image = "\(finalRecipe.id).jpeg"
                
            updateRecipe(finalRecipe)
        }
        
     //bücher

        
    }
    
    /// Fügt ein Rezept einem Rezeptbuch hinzu.
    func addRecipe(_ recipe: Recipe, toRecipeBook book: RecipebookStruct) {
        let bookFetchRequest: NSFetchRequest<Recipebook> = Recipebook.fetchRequest()
        bookFetchRequest.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)
        
        do {
            if let recipeBook = try managedContext.fetch(bookFetchRequest).first {
                let recipeEntity = findOrCreateRecipeEntity(from: recipe)
                recipeBook.addToRecipes(recipeEntity) // Rezeptbuch aktualisieren
                saveContext()
                print("✅ Rezept dem Rezeptbuch hinzugefügt.")
            } else {
                print("⚠️ Rezeptbuch nicht gefunden, wird erstellt.")
                let newRecipeBook = createNewRecipeBook(recipeBookStruct: book)
                newRecipeBook.addToRecipes(findOrCreateRecipeEntity(from: recipe))
                saveContext()
            }
        } catch {
            print("❌ Fehler beim Hinzufügen des Rezepts zum Rezeptbuch: \(error)")
        }
    }
    
    /// Erstellt ein neues Rezeptbuch und speichert es in Core Data.
    func createNewRecipeBook(recipeBookStruct: RecipebookStruct) -> Recipebook {
        let newBook = Recipebook(context: managedContext)
        newBook.id = recipeBookStruct.id
        newBook.name = recipeBookStruct.name
        
        do {
            try managedContext.save()
            print("✅ Neues Rezeptbuch erstellt: \(recipeBookStruct.name)")
        } catch {
            print("❌ Fehler beim Erstellen des Rezeptbuchs: \(error)")
        }
        return newBook
    }
    /// Löscht ein Rezept aus Core Data anhand seiner ID.
    func deleteRecipe(by id: UUID) {
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            if let recipeToDelete = try managedContext.fetch(fetchRequest).first {
                managedContext.delete(recipeToDelete)
                try managedContext.save()
                print("🗑️ Rezept gelöscht: \(id)")
            } else {
                print("⚠️ Kein Rezept mit der ID gefunden: \(id)")
            }
        } catch {
            print("❌ Fehler beim Löschen des Rezepts: \(error)")
        }
    }
    
    /// Sucht ein bestehendes Rezept oder erstellt eine neue Entität, falls keines existiert.
    private func findOrCreateRecipeEntity(from recipe: Recipe) -> Recipes {
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        
        // Verwende eine `NSPredicate`, um nach der ID des Rezepts zu suchen.
        fetchRequest.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)
        
        // Falls ein Rezept mit der ID existiert, verwende es; sonst erstelle ein neues.
        if let existing = try? managedContext.fetch(fetchRequest).first {
            return existing
        } else {
            let new = Recipes(context: managedContext)
            new.id = recipe.id // Direktes Setzen der UUID
            return new
        }
    }
    
    /// Füllt eine `Recipes`-Entität mit Daten aus einem `Recipe`-Struktur.
    func populateRecipeEntity(_ entity: Recipes, from recipe: Recipe) {
        entity.titel = recipe.title
        entity.instructions = recipe.instructions
        entity.image = recipe.image
        entity.portion = recipe.portion?.stringValue()
        entity.cake = recipe.cake?.stringValue()
        entity.videoLink = recipe.videoLink
        entity.id = recipe.id
        
        // Zutaten hinzufügen
        recipe.ingredients.forEach { foodItemStruct in
            let foodItemEntity = findOrCreateFoodItem(foodItemStruct)
            entity.addToIngredients(foodItemEntity) // Stellt sicher, dass die Zutat korrekt hinzugefügt wird
        }
        
        // Tags hinzufügen, falls vorhanden
        if let tags = recipe.tags {
            for tag in tags {
                let tagEntity = findOrCreateTag(tag)
                entity.addToTags(tagEntity)
            }
        }
    }
    
    /// Speichert den Core Data-Kontext und fängt Fehler ab.
    func saveContext() {
        do {
            try managedContext.save()
            print("✅ Core Data erfolgreich gespeichert.")
        } catch {
            print("❌ Fehler beim Speichern des Core Data-Kontexts: \(error)")
        }
    }
    
    func fetchExistingFoodIDs() -> Set<UUID> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Food.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["id"]
        
        do {
            let results = try managedContext.fetch(fetchRequest) as! [[String: UUID]]
            return Set(results.compactMap { $0["id"] })
        } catch {
            print("❌ Fehler beim Abrufen der Food-UUIDs: \(error)")
            return []
        }
    }

    func fetchExistingTagIDs() -> Set<UUID> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["id"]
        
        do {
            let results = try managedContext.fetch(fetchRequest) as! [[String: UUID]]
            return Set(results.compactMap { $0["id"] })
        } catch {
            print("❌ Fehler beim Abrufen der Tag-UUIDs: \(error)")
            return []
        }
    }

    func fetchExistingRecipeIDs() -> Set<UUID> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Recipes.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["id"]
        
        do {
            let results = try managedContext.fetch(fetchRequest) as! [[String: UUID]]
            return Set(results.compactMap { $0["id"] })
        } catch {
            print("❌ Fehler beim Abrufen der Rezept-UUIDs: \(error)")
            return []
        }
    }
    
    /// Prüft, ob die Core Data-Datenbank leer ist, und fügt initiale Datensätze hinzu.
    func insertInitialDataIfNeeded() {
        // 1. Kopiere ggf. die Datenbank
        setupPreloadedDatabase()

        let fileManager = FileManager.default
        let containerURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbURL = containerURL.appendingPathComponent("Rezeptbuch.sqlite")

        var didMerge = false

        if let bundlePath = Bundle.main.path(forResource: "Rezeptbuch", ofType: "sqlite"),
           fileManager.fileExists(atPath: dbURL.path) {
            didMerge = mergeSQLiteDatabases(existingDBPath: dbURL.path, newDBPath: bundlePath)
        }

        // 2. Prüfen, ob Core Data leer ist (nur Rezepte!)
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        let recipeCount = (try? managedContext.count(for: fetchRequest)) ?? 0
        let isCoreDataEmpty = (recipeCount == 0)

        // 3. Nur fortfahren, wenn Merge stattfand oder Core Data leer ist
        guard didMerge || isCoreDataEmpty else {
            print("ℹ️ Kein Merge und Core Data enthält bereits Daten. Keine Aktion nötig.")
            return
        }

        // 4. SQLite-Daten laden
        let databaseService = DatabaseService(databasePath: dbURL.path)
        let foodsFromDatabase = databaseService.loadFoods()
        let tagsFromDatabase = databaseService.loadTags()

        // 5. Core Data: vorhandene UUIDs abrufen
        let existingFoodIDs = fetchExistingFoodIDs()
        let existingTagIDs = fetchExistingTagIDs()

        // 6. Tags & Lebensmittel importieren (nur neue)
        for tag in tagsFromDatabase where !existingTagIDs.contains(tag.id) {
            _ = findOrCreateTag(tagStruct: tag)
        }

        for food in foodsFromDatabase where !existingFoodIDs.contains(food.id) {
            _ = findOrCreateFood(foodStruct: food)
        }

        // 7. Nur wenn Core Data leer ist → Initialrezepte anlegen
        if isCoreDataEmpty {
            print("📦 Core Data ist leer. Initialrezepte werden hinzugefügt.")
            let recipesToInsert = [pastaRecipe, brownieRecipe]

            for recipe in recipesToInsert {
                let recipeEntity = Recipes(context: managedContext)
                recipeEntity.titel = recipe.title
                recipeEntity.id = recipe.id
                if let uiImage = UIImage(named: recipe.image ?? "") {
                    recipeEntity.image = saveImageLocally(image: uiImage, id: recipe.id)
                }
                recipeEntity.instructions = recipe.instructions

                for foodItemStruct in recipe.ingredients {
                    let foodItemEntity = findOrCreateFoodItem(foodItemStruct)
                    recipeEntity.addToIngredients(foodItemEntity)
                }

                recipeEntity.portion = recipe.portion?.stringValue()
                recipeEntity.cake = recipe.cake?.stringValue()

                if let tags = recipe.tags {
                    for tagName in tags {
                        let tag = findOrCreateTag(tagName)
                        recipeEntity.addToTags(tag)
                    }
                }
            }
        } else {
            print("ℹ️ Core Data enthält bereits Rezepte. Initialrezepte werden nicht angelegt.")
        }

        // 8. Core Data speichern
        do {
            try managedContext.save()
            print("✅ Neue Daten erfolgreich in Core Data gespeichert.")
        } catch {
            print("❌ Fehler beim Speichern der Daten: \(error)")
        }
    }
    
    
    /// Prüft, ob eine vorgefertigte SQLite-Datenbank bereits existiert, und kopiert sie falls nötig.
    func setupPreloadedDatabase() {
        let fileManager = FileManager.default
        let containerURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbURL = containerURL.appendingPathComponent("Rezeptbuch.sqlite")
        
        // Prüfen, ob die Datenbank bereits im Zielverzeichnis existiert
        if fileManager.fileExists(atPath: dbURL.path) {
            print("✅ SQLite-Datenbank bereits vorhanden.")
            return
        }
        
        // Prüfen, ob die vorgefertigte Datenbank im App-Bundle vorhanden ist
        guard let preloadedDBPath = Bundle.main.path(forResource: "Rezeptbuch", ofType: "sqlite") else {
            print("❌ SQLite-Datei NICHT im Bundle gefunden!")
            return
        }
        print("ℹ️ SQLite-Datei gefunden: \(preloadedDBPath)")
        
        // Falls das Zielverzeichnis noch nicht existiert, erstelle es
        if !fileManager.fileExists(atPath: containerURL.path) {
            do {
                try fileManager.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
                print("✅ Zielverzeichnis erstellt: \(containerURL.path)")
            } catch {
                print("❌ Fehler beim Erstellen des Zielverzeichnisses: \(error)")
                return
            }
        }
        
        let preloadedDBURL = URL(fileURLWithPath: preloadedDBPath)
        
        do {
            // Kopiere die SQLite-Datei ins Zielverzeichnis
            let data = try Data(contentsOf: preloadedDBURL)
            try data.write(to: dbURL)
            print("✅ SQLite-Datei erfolgreich kopiert.")
        } catch {
            print("❌ Fehler beim Kopieren der SQLite-Datei: \(error)")
        }
    }
    
    func mergeSQLiteDatabases(existingDBPath: String, newDBPath: String) -> Bool {
        var db: OpaquePointer?
        var newDataInserted = false

        guard sqlite3_open(existingDBPath, &db) == SQLITE_OK else {
            print("❌ Fehler beim Öffnen der bestehenden Datenbank.")
            return false
        }

        defer { sqlite3_close(db) }

        let attachQuery = "ATTACH DATABASE '\(newDBPath)' AS bundleDB;"
        guard sqlite3_exec(db, attachQuery, nil, nil, nil) == SQLITE_OK else {
            print("❌ Fehler beim Anhängen der Bundle-Datenbank.")
            return false
        }

        print("✅ Bundle-Datenbank erfolgreich angehängt.")

        let copyQueries = [
            // Tags
            "INSERT INTO Tag (id, name) SELECT id, name FROM bundleDB.Tag WHERE id NOT IN (SELECT id FROM Tag);",

            // Lebensmittel
            "INSERT INTO Food (id, name, category, info, density) SELECT id, name, category, info, density FROM bundleDB.Food WHERE id NOT IN (SELECT id FROM Food);",

            // Nährwerte
            "INSERT INTO NutritionFacts (food_id, calories, protein, carbohydrates, fat) SELECT food_id, calories, protein, carbohydrates, fat FROM bundleDB.NutritionFacts WHERE food_id NOT IN (SELECT food_id FROM NutritionFacts);",

            // FoodTag-Zuordnung
            "INSERT INTO FoodTag (foodId, tagId) SELECT foodId, tagId FROM bundleDB.FoodTag WHERE (foodId, tagId) NOT IN (SELECT foodId, tagId FROM FoodTag);"
        ]

        for query in copyQueries {
            let changesBefore = sqlite3_total_changes(db)
            let result = sqlite3_exec(db, query, nil, nil, nil)
            let changesAfter = sqlite3_total_changes(db)

            if result == SQLITE_OK && changesAfter > changesBefore {
                newDataInserted = true
            }
        }

        // Trennen
        _ = sqlite3_exec(db, "DETACH DATABASE bundleDB;", nil, nil, nil)

        print("📦 Merge abgeschlossen. Neue Daten eingefügt: \(newDataInserted)")
        return newDataInserted
    }
    
    /// Sucht nach einem vorhandenen Tag oder erstellt einen neuen, falls keiner existiert.
    private func findOrCreateTag(tagStruct: TagStruct) -> Tag {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", tagStruct.name)
        
        // Falls der Tag existiert, wird er zurückgegeben; sonst wird ein neuer erstellt.
        if let existingTag = try? managedContext.fetch(fetchRequest).first {
            return existingTag
        } else {
            let newTag = Tag(context: managedContext)
            newTag.name = tagStruct.name
            newTag.id = tagStruct.id
            return newTag
        }
    }
    
    /// Alternative Methode: Sucht oder erstellt einen Tag anhand des Namens.
    private func findOrCreateTag(name: String) -> Tag {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        if let existingTag = try? managedContext.fetch(fetchRequest).first {
            return existingTag
        } else {
            let newTag = Tag(context: managedContext)
            newTag.name = name
            newTag.id = UUID() // Neue UUID, falls noch nicht vorhanden
            return newTag
        }
    }
    
    /// Sucht oder erstellt einen `FoodItem`, also eine Zutat innerhalb eines Rezepts.
    private func findOrCreateFoodItem(_ item: FoodItemStruct) -> FoodItem {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        
        // Erstelle verschiedene Bedingungen für die Suche nach der Zutat
        let predicateName = NSPredicate(format: "food.name == %@", item.food.name)
        let predicateUnit = NSPredicate(format: "unit == %@", Unit.toString(item.unit))
        let predicateQuantity = NSPredicate(format: "quantity == %lf", item.quantity)
        let predictionID = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        // Kombiniere alle Bedingungen in einem einzigen Prädikat
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateName, predicateUnit, predicateQuantity, predictionID])
        fetchRequest.predicate = compoundPredicate
        
        // Falls das Lebensmittel bereits existiert, wird es zurückgegeben; sonst wird ein neues erstellt.
        if let existingItem = try? managedContext.fetch(fetchRequest).first {
            return existingItem
        } else {
            let newFoodItem = FoodItem(context: managedContext)
            newFoodItem.food = findOrCreateFood(foodStruct: item.food)
            newFoodItem.unit = Unit.toString(item.unit)
            newFoodItem.quantity = item.quantity
            newFoodItem.id = item.id
            return newFoodItem
        }
    }
    
    /// Sucht oder erstellt ein `Food`-Objekt in Core Data.
    private func findOrCreateFood(foodStruct: FoodStruct) -> Food {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", foodStruct.name)
        
        // Falls das Lebensmittel bereits existiert, wird es zurückgegeben.
        if let existingFood = try? managedContext.fetch(fetchRequest).first {
            return existingFood
        } else {
            let newFood = Food(context: managedContext)
            newFood.name = foodStruct.name
            newFood.category = foodStruct.category
            newFood.density = foodStruct.density as? NSNumber
            newFood.info = foodStruct.info
            newFood.id = foodStruct.id
            
            // Falls Tags vorhanden sind, füge sie hinzu.
            if let tags = foodStruct.tags {
                for tag in tags {
                    let tagEntity = findOrCreateTag(tag)
                    newFood.addToTags(tagEntity)
                }
            }
            
            // Falls Nährwertinformationen vorhanden sind, füge sie hinzu.
            if let facts = foodStruct.nutritionFacts {
                let nutrition = NutritionFacts(context: managedContext)
                nutrition.calories = Int64(facts.calories ?? 0)
                nutrition.protein = facts.protein ?? 0.0
                nutrition.carbohydrates = facts.carbohydrates ?? 0.0
                nutrition.fat = facts.fat ?? 0.0
                newFood.nutritionFacts = nutrition
            }
            
            return newFood
        }
    }
    
    /// Speichert ein neues Lebensmittel (`FoodStruct`) in Core Data.
    func saveFood(foodStruct: FoodStruct) {
        let food = Food(context: managedContext)
        food.name = foodStruct.name
        food.category = foodStruct.category
        food.density = foodStruct.density as? NSNumber
        food.info = foodStruct.info
        food.id = foodStruct.id
        
        // Tags hinzufügen
        if let tags = foodStruct.tags {
            for tag in tags {
                let tage = findOrCreateTag(tag) // Existierenden Tag finden oder neuen erstellen
                food.addToTags(tage)
            }
        }
        
        // Nährwerte hinzufügen
        if let facts = foodStruct.nutritionFacts {
            let nutrition = NutritionFacts(context: managedContext)
            nutrition.calories = Int64(facts.calories ?? 0)
            nutrition.protein = facts.protein ?? 0.0
            nutrition.carbohydrates = facts.carbohydrates ?? 0.0
            nutrition.fat = facts.fat ?? 0.0
            food.nutritionFacts = nutrition
        }
        
        // Core Data speichern
        do {
            try managedContext.save()
            print("✅ Lebensmittel erfolgreich gespeichert: \(foodStruct.name)")
        } catch let error as NSError {
            print("❌ Fehler beim Speichern: \(error), \(error.userInfo)")
        }
    }
    
    /// Aktualisiert ein bestehendes Lebensmittel (`FoodStruct`) in Core Data.
    func updateFood(foodStruct: FoodStruct) {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", foodStruct.id.uuidString)
        
        do {
            // Debug: Zeige alle vorhandenen Lebensmittel in Core Data
            let allFoods = try managedContext.fetch(Food.fetchRequest())
            for food in allFoods {
                if let id = food.id {
                    print("🔍 Gefundenes Lebensmittel mit UUID: \(id)")
                } else {
                    print("⚠️ Fehlerhafte UUID im Core Data-Eintrag: \(food)")
                }
            }
            
            if let existingFood = try managedContext.fetch(fetchRequest).first {
                // Aktualisiere die vorhandene Food-Entität
                existingFood.name = foodStruct.name
                existingFood.category = foodStruct.category
                existingFood.info = foodStruct.info
                existingFood.density = foodStruct.density as? NSNumber
                
                // Tags aktualisieren
                if let tags = foodStruct.tags {
                    if let existingTags = existingFood.tags as? Set<Tag> {
                        for tag in existingTags {
                            existingFood.removeFromTags(tag)
                        }
                    }
                    for tag in tags {
                        let tage = findOrCreateTag(tag)
                        existingFood.addToTags(tage)
                    }
                }
                
                // Nährwerte aktualisieren
                if let facts = foodStruct.nutritionFacts {
                    if let existingNutritionFacts = existingFood.nutritionFacts {
                        existingNutritionFacts.calories = Int64(facts.calories ?? 0)
                        existingNutritionFacts.protein = facts.protein ?? 0.0
                        existingNutritionFacts.carbohydrates = facts.carbohydrates ?? 0.0
                        existingNutritionFacts.fat = facts.fat ?? 0.0
                    } else {
                        let nutrition = NutritionFacts(context: managedContext)
                        nutrition.calories = Int64(facts.calories ?? 0)
                        nutrition.protein = facts.protein ?? 0.0
                        nutrition.carbohydrates = facts.carbohydrates ?? 0.0
                        nutrition.fat = facts.fat ?? 0.0
                        existingFood.nutritionFacts = nutrition
                    }
                }
                
                // Änderungen speichern
                try managedContext.save()
                print("✅ Lebensmittel erfolgreich aktualisiert: \(foodStruct.name)")
            } else {
                print("⚠️ Keine Food-Entität mit dieser ID gefunden. Erstelle eine neue.")
                saveFood(foodStruct: foodStruct) // Falls kein Eintrag existiert, wird ein neuer erstellt
            }
        } catch let error as NSError {
            print("❌ Fehler beim Aktualisieren: \(error), \(error.userInfo)")
        }
    }

    
    /// Aktualisiert ein bestehendes Rezept (`Recipe`) in Core Data.
    func updateRecipe(_ recipe: Recipe) {
        let recipeEntity = findOrCreateRecipeEntity(from: recipe)
        
        // Basisdaten aktualisieren
        recipeEntity.titel = recipe.title
        recipeEntity.instructions = recipe.instructions
        recipeEntity.image = recipe.image
        recipeEntity.portion = recipe.portion?.stringValue()
        recipeEntity.cake = recipe.cake?.stringValue()
        recipeEntity.videoLink = recipe.videoLink
        recipeEntity.info = recipe.info
        
        // Zutaten aktualisieren
        updateIngredients(for: recipeEntity, with: recipe.ingredients)
        
        // Falls das Rezept zu einem Rezeptbuch gehört, aktualisieren
        updateRecipeBookAssociation(for: recipeEntity, withNewBookIDs: recipe.recipeBookIDs)
        
        // Tags aktualisieren
        if let tags = recipe.tags {
            updateTags(for: recipeEntity, with: tags)
        }
        
        // Änderungen speichern
        saveContext()
    }
    
    /// Synchronisiert ein `TagStruct` mit Core Data.
    func syncTag(with tagStruct: TagStruct) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tagStruct.id as CVarArg)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            let tag = results.first ?? Tag(context: managedContext) // Falls nicht vorhanden, erstelle neuen Tag
            tag.id = tagStruct.id
            tag.name = tagStruct.name
            
            saveContext()
        } catch {
            print("❌ Fehler beim Abrufen oder Speichern des Tags: \(error)")
        }
    }
    /// Aktualisiert die Tags eines Rezepts (`Recipes`).
    func updateTags(for recipeEntity: Recipes, with newTags: [TagStruct]) {
        let existingTags = (recipeEntity.tags as? Set<Tag>) ?? Set()
        
        // Erstellen eines Sets mit den aktuellen Tag-IDs
        let currentTagIDs = existingTags.map { $0.id }
        
        // Entfernen von Tags, die nicht mehr in den neuen Tags enthalten sind
        for tag in existingTags where !newTags.contains(where: { $0.id == tag.id }) {
            recipeEntity.removeFromTags(tag)
        }
        
        // Hinzufügen neuer Tags, die noch nicht existieren
        for tagStruct in newTags where !currentTagIDs.contains(tagStruct.id) {
            let newTag = findOrCreateTag(tagStruct)
            recipeEntity.addToTags(newTag)
        }
    }
    
    /// Sucht oder erstellt ein `Tag`-Objekt in Core Data.
    func findOrCreateTag(_ tagStruct: TagStruct) -> Tag {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tagStruct.id as CVarArg)
        
        if let existingTag = (try? managedContext.fetch(fetchRequest))?.first {
            return existingTag
        } else {
            let newTag = Tag(context: managedContext)
            newTag.id = tagStruct.id
            newTag.name = tagStruct.name
            return newTag
        }
    }
    
    func updateRecipeBookAssociation(for recipeEntity: Recipes, withNewBookIDs bookIDs: [UUID]?) {
        guard let newBookIDs = bookIDs else { return }

        // Holen der aktuellen Rezeptbücher
        if let currentBooks = recipeEntity.recipesBooks as? Set<Recipebook> {
            let currentBookIDs = currentBooks.compactMap { $0.id }

            // Entfernen von Rezepten aus Rezeptbüchern, die nicht mehr zugewiesen sind
            for book in currentBooks where !newBookIDs.contains(book.id ?? UUID()) {
                book.removeFromRecipes(recipeEntity)
            }
        }

        // Hinzufügen des Rezepts zu neuen Rezeptbüchern
        for newBookID in newBookIDs {
            let bookFetchRequest: NSFetchRequest<Recipebook> = Recipebook.fetchRequest()
            bookFetchRequest.predicate = NSPredicate(format: "id == %@", newBookID as CVarArg)

            if let newBook = try? managedContext.fetch(bookFetchRequest).first {
                // Falls Rezept noch nicht im Rezeptbuch ist, hinzufügen
                if (newBook.recipes as? Set<Recipes>)?.contains(recipeEntity) == false {
                    newBook.addToRecipes(recipeEntity)
                }
            } else {
                // Neues Rezeptbuch erstellen, falls es noch nicht existiert
                let newBook = Recipebook(context: managedContext)
                newBook.id = newBookID
                newBook.addToRecipes(recipeEntity)
                print("📖 Neues Rezeptbuch erstellt für ID: \(newBookID)")
            }
        }

        saveContext()
    }
    
    /// Aktualisiert die Zutaten eines Rezepts (`Recipes`).
    private func updateIngredients(for entity: Recipes, with newIngredients: [FoodItemStruct]) {
        // Entferne bestehende Zutaten
        entity.removeFromIngredients(entity.ingredients as! NSSet)
        
        // Neue Zutaten hinzufügen
        for foodItemStruct in newIngredients {
            let foodItemEntity = findOrCreateFoodItem(foodItemStruct)
            entity.addToIngredients(foodItemEntity)
        }
    }
}

// FoodItemStruct - Initialisierung aus Core Data Managed Object
extension FoodItemStruct {
    init(from managedObject: FoodItem) {
        guard let food = managedObject.food else {
            fatalError("FoodItem muss eine verknüpfte Food-Entität haben!")
        }
        
        self.food = FoodStruct(from: food)
        self.unit = Unit.fromString(managedObject.unit ?? "") ?? .gram
        self.quantity = managedObject.quantity
        self.id = managedObject.id ?? UUID()
    }
}

// FoodStruct - Initialisierung aus Core Data Managed Object
extension FoodStruct {
    init(from managedObject: Food) {
        self.id = managedObject.id ?? UUID()
        self.name = managedObject.name ?? "Unbekannt"
        self.category = managedObject.category
        self.density = managedObject.density as? Double
        self.info = managedObject.info
        self.nutritionFacts = NutritionFactsStruct(from: managedObject.nutritionFacts)

        // Lade Tags, falls vorhanden
        self.tags = (managedObject.tags as? Set<Tag>)?.map(TagStruct.init) ?? []
    }
}

// Recipe - Initialisierung aus Core Data Managed Object
extension Recipe {
    init(from managedObject: Recipes) {
        self.id = managedObject.id ?? UUID()
        self.title = managedObject.titel ?? "Unbekanntes Rezept"
        self.instructions = managedObject.instructions ?? []
        self.image = managedObject.image
        self.portion = PortionsInfo.fromString(managedObject.portion ?? "")
        self.cake = CakeInfo.fromString(managedObject.cake ?? "")
        self.videoLink = managedObject.videoLink
        self.info = managedObject.info
        
        // Tags
        self.tags = (managedObject.tags as? Set<Tag>)?.map(TagStruct.init) ?? []

        // Rezeptbuch-Zuordnung
        self.recipeBookIDs = (managedObject.recipesBooks as? Set<Recipebook>)?.compactMap { $0.id } ?? []

        // Zutaten
        self.ingredients = (managedObject.ingredients as? Set<FoodItem>)?.map(FoodItemStruct.init) ?? []
    }
}

// NutritionFactsStruct - Initialisierung aus Core Data Managed Object
extension NutritionFactsStruct {
    init(from managedObject: NutritionFacts?) {
        self.calories = managedObject?.calories != nil ? Int(managedObject!.calories) : nil
        self.protein = managedObject?.protein
        self.carbohydrates = managedObject?.carbohydrates
        self.fat = managedObject?.fat
    }
}

// RecipebookStruct - Initialisierung aus Core Data Managed Object
extension RecipebookStruct {
    init(from managedObject: Recipebook) {
        self.id = managedObject.id ?? UUID()
        self.name = managedObject.name ?? "Unbenanntes Rezeptbuch"

        // Rezepte und Tags sicher aus Core Data laden
        self.recipes = (managedObject.recipes as? Set<Recipes>)?.map(Recipe.init) ?? []
        self.tags = (managedObject.tag as? Set<Tag>)?.map(TagStruct.init) ?? []
    }
}
