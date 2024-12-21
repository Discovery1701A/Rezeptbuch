import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    // MARK: Fetching Methods

       func fetchFoods() -> [FoodStruct] {
           let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
           do {
               return try managedContext.fetch(fetchRequest).map { FoodStruct(from: $0) }
           } catch {
               print("Error fetching foods: \(error)")
               return []
           }
       }
       func fetchTags() -> [TagStruct] {
           let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
           
           do {
               let fetchedTags = try managedContext.fetch(fetchRequest)
               return fetchedTags.map { TagStruct(from: $0) }
           } catch {
               print("Error fetching tags: \(error)")
               return []
           }
       }
       
       func fetchRecipes() -> [Recipe] {
           let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
           do {
               return try managedContext.fetch(fetchRequest).map { Recipe(from: $0) }
           } catch {
               print("Error fetching recipes: \(error)")
               return []
           }
       }

        func fetchRecipebooks() -> [RecipebookStruct] {
            let fetchRequest: NSFetchRequest<Recipebook> = Recipebook.fetchRequest()
            do {
                return try managedContext.fetch(fetchRequest).map { RecipebookStruct(from: $0) }
            } catch {
                print("Error fetching recipebooks: \(error)")
                return []
            }
        }

    // MARK: Saving Methods

    func saveRecipe(_ recipe: Recipe, selectedRecipeBook: RecipebookStruct) {
        let recipeEntity = findOrCreateRecipeEntity(from: recipe)
        populateRecipeEntity(recipeEntity, from: recipe)

        
            addRecipe(recipe, toRecipeBook: selectedRecipeBook)
       
        
        saveContext()
    }
    func saveRecipe(_ recipe: Recipe) {
           let recipeEntity = findOrCreateRecipeEntity(from: recipe)
           populateRecipeEntity(recipeEntity, from: recipe)
           print("saveRecepie Core: ",recipeEntity)
           saveContext()
       }
    
    // Funktion zum Hinzufügen eines Rezepts zu einem Rezeptbuch
    func addRecipe(_ recipe: Recipe, toRecipeBook book: RecipebookStruct) {
        let bookFetchRequest: NSFetchRequest<Recipebook> = Recipebook.fetchRequest()
        bookFetchRequest.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)

        do {
            if let recipeBook = try managedContext.fetch(bookFetchRequest).first {
                let recipeEntity = findOrCreateRecipeEntity(from: recipe)
                recipeBook.addToRecipes(recipeEntity)
                saveContext()
                print("Rezept wurde dem Rezeptbuch hinzugefügt.")
            } else {
                print("Rezeptbuch nicht gefunden, wird erstellt.")
                let newRecipeBook = createNewRecipeBook(recipeBookStruct: book) // Anpassen oder dynamisieren des Namens nach Bedarf
                newRecipeBook.addToRecipes(findOrCreateRecipeEntity(from: recipe))
                saveContext()
            }
        } catch {
            print("Fehler beim Hinzufügen des Rezepts zum Rezeptbuch: \(error)")
        }
    }
    
    func createNewRecipeBook(recipeBookStruct : RecipebookStruct) -> Recipebook {
        let newBook = Recipebook(context: managedContext)
        newBook.id = recipeBookStruct.id
        newBook.name = recipeBookStruct.name

        do {
            try managedContext.save()
            print("Neues Rezeptbuch erstellt: \(recipeBookStruct.name)")
        } catch {
            print("Fehler beim Erstellen des Rezeptbuchs: \(error)")
        }
        return newBook
    }
 
    
    private func findOrCreateRecipeEntity(from recipe: Recipe) -> Recipes {
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        // Update the predicate to match UUIDs
        fetchRequest.predicate = NSPredicate(format: "id == %@", recipe.id as CVarArg)

        // Try to fetch existing recipe or create a new one
        if let existing = try? managedContext.fetch(fetchRequest).first {
            return existing
        } else {
            let new = Recipes(context: managedContext)
            new.id = recipe.id // Directly set the UUID without conversion
            return new
        }
    }

    
     func populateRecipeEntity(_ entity: Recipes, from recipe: Recipe) {
        entity.titel = recipe.title
        entity.instructions = recipe.instructions
        entity.image = recipe.image
        entity.portion = recipe.portion?.stringValue()
        entity.cake = recipe.cake?.stringValue()
        entity.videoLink = recipe.videoLink
        entity.id = recipe.id
        recipe.ingredients.forEach { foodItemStruct in
                let foodItemEntity = findOrCreateFoodItem(foodItemStruct)
                entity.addToIngredients(foodItemEntity) // Stellen Sie sicher, dass dies aufgerufen wird
            }
        if let tags = recipe.tags {
            for tag in tags {
                let tage = findOrCreateTag(tag)
                entity.addToTags(tage)
            }
        }
        
        // Handle tags and recipebooks relationship here if applicable
    }
    
    func saveContext() {
        do {
            try managedContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func insertInitialDataIfNeeded() {
        // SQLite-Datenbank prüfen und kopieren (falls nicht vorhanden)
        setupPreloadedDatabase()
       
        // Überprüfen, ob die Datenbank leer ist
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        let count = try? managedContext.count(for: fetchRequest)

        guard let recipeCount = count, recipeCount == 0 else {
            print("Die Datenbank enthält bereits Datensätze. Keine Aktion erforderlich.")
            return
        }
        let fileManager = FileManager.default
        let containerURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbURL = containerURL.appendingPathComponent("Rezeptbuch.sqlite")
//        print(dbURL.absoluteString)
        let databaseService = DatabaseService(databasePath: dbURL.absoluteString)
        
        let ffooodis = databaseService.loadFoods()
        let tags = databaseService.loadTags()
//        print("22222222",ffooodis)
        // Datenbank ist leer, füge die initialen Daten ein
        let recipesToInsert = [pastaRecipe, brownieRecipe] // Die zu speichernden Rezepte

        for tag in tags {
            let tagEntity = findOrCreateTag(tagStruct: tag)
        }
        for food in ffooodis {
            print("fffffffff",food)
            let foodEntry = findOrCreateFood(foodStruct: food)
        }
        
    
        for recipe in recipesToInsert {
            let recipeEntity = Recipes(context: managedContext)
            recipeEntity.titel = recipe.title
            recipeEntity.id = recipe.id // Direct use of UUID
            recipeEntity.image = recipe.image
            recipeEntity.instructions = recipe.instructions

            // Überprüfen, ob Zutaten vorhanden sind
            if !recipe.ingredients.isEmpty {
                for foodItemStruct in recipe.ingredients {
                    let foodItemEntity = findOrCreateFoodItem(foodItemStruct)
                    recipeEntity.addToIngredients(foodItemEntity)
                }
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

        do {
            try managedContext.save()
            print("Initiale Daten erfolgreich in der Datenbank gespeichert.")
        } catch {
            print("Fehler beim Speichern der initialen Daten: \(error)")
        }
    }

    // Funktion: SQLite-Datenbank laden
    func setupPreloadedDatabase() {
        let fileManager = FileManager.default
        let containerURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbURL = containerURL.appendingPathComponent("Rezeptbuch.sqlite")
        
        // Prüfen, ob die Datenbank bereits im Zielverzeichnis existiert
        if fileManager.fileExists(atPath: dbURL.path) {
            print("SQLite-Datenbank bereits vorhanden.")
            return
        }

        // Debugging: Liste den Pfad der vorgefertigten Datei auf
        if let preloadedDBPath = Bundle.main.path(forResource: "Rezeptbuch", ofType: "sqlite") {
            print("SQLite-Datei gefunden: \(preloadedDBPath)")
        } else {
            print("SQLite-Datei NICHT im Bundle gefunden!")
            return
        }

        guard let preloadedDBPath = Bundle.main.path(forResource: "Rezeptbuch", ofType: "sqlite") else {
            print("SQLite-Datei NICHT im Bundle gefunden!")
            return
        }
        if !fileManager.fileExists(atPath: containerURL.path) {
            do {
                try fileManager.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
                print("Zielverzeichnis erstellt: \(containerURL.path)")
            } catch {
                print("Fehler beim Erstellen des Zielverzeichnisses: \(error)")
                return
            }
        }


        let preloadedDBURL = URL(fileURLWithPath: preloadedDBPath)

        do {
            // Kopiere die Datei
            let data = try Data(contentsOf: preloadedDBURL)
            try data.write(to: dbURL)
            print("SQLite-Datei erfolgreich kopiert.")
        } catch {
            print("Fehler beim Kopieren der SQLite-Datei: \(error)")
        }

    }
    
    
    

    private func findOrCreateTag(tagStruct: TagStruct) -> Tag {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", tagStruct.name)
        if let existingTag = try? managedContext.fetch(fetchRequest).first {
            return existingTag
        } else {
            let newTag = Tag(context: managedContext)
            newTag.name = tagStruct.name
            newTag.id = tagStruct.id
            return newTag
        }
    }


    private func findOrCreateTag(name: String) -> Tag {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        if let existingTag = try? managedContext.fetch(fetchRequest).first {
            return existingTag
        } else {
            let newTag = Tag(context: managedContext)
            newTag.name = name
            newTag.id = UUID()
            return newTag
        }
    }

    private func findOrCreateFoodItem(_ item: FoodItemStruct) -> FoodItem {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        // Hier fügen wir auch die Menge als Bedingung hinzu
        let predicateName = NSPredicate(format: "food.name == %@", item.food.name)
        let predicateUnit = NSPredicate(format: "unit == %@", Unit.toString(item.unit))
        let predicateQuantity = NSPredicate(format: "quantity == %lf", item.quantity)
        let predictionid = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        // Kombiniere alle drei Predikate zu einem einzigen zusammengesetzten Prädikat
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateName, predicateUnit, predicateQuantity,predictionid])
        fetchRequest.predicate = compoundPredicate

        if let existingItem = try? managedContext.fetch(fetchRequest).first {
            // Wenn ein Element gefunden wird, das alle Kriterien erfüllt, geben Sie dieses zurück
            return existingItem
        } else {
            // Kein passendes Element gefunden, also erstellen Sie ein neues
            let newFoodItem = FoodItem(context: managedContext)
            let food = findOrCreateFood(foodStruct: item.food)
            newFoodItem.food = food
            newFoodItem.unit = Unit.toString(item.unit)
            newFoodItem.quantity = item.quantity
            newFoodItem.id = item.id
            return newFoodItem
        }
    }


    private func findOrCreateFood(foodStruct: FoodStruct) -> Food {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", foodStruct.name)
        if let existingFood = try? managedContext.fetch(fetchRequest).first {
            return existingFood
        } else {
            let newFood = Food(context: managedContext)
            newFood.name = foodStruct.name
            newFood.category = foodStruct.category
            newFood.density = foodStruct.density as? NSNumber
            newFood.info = foodStruct.info
            newFood.id = foodStruct.id
            if let tags = foodStruct.tags {
                for tag in tags {
                    let tage = findOrCreateTag(tag)
                    newFood.addToTags(tage)
                }
            }
            if let facts = foodStruct.nutritionFacts {
                    let nutrition = NutritionFacts(context: managedContext)
                
                    nutrition.calories = Int64(facts.calories ?? 0)
//                print("kallooss",facts.calories)
                    nutrition.protein = facts.protein ?? 0.0
                    nutrition.carbohydrates = facts.carbohydrates ?? 0.0
                    nutrition.fat = facts.fat ?? 0.0
                    newFood.nutritionFacts = nutrition
                }
            return newFood
        }
    }
    
    func saveFood(foodStruct: FoodStruct) {
            let food = Food(context: managedContext)
        food.name = foodStruct.name
        food.category = foodStruct.category
        food.density = foodStruct.density as? NSNumber
        food.info = foodStruct.info
        food.id = foodStruct.id
            
        if let tags = foodStruct.tags {
            for tag in tags {
                let tage = findOrCreateTag(tag)
                food.addToTags(tage)
            }
        }
        if let facts = foodStruct.nutritionFacts {
                let nutrition = NutritionFacts(context: managedContext)
                nutrition.calories = Int64(facts.calories ?? 0)
                nutrition.protein = facts.protein ?? 0.0
                nutrition.carbohydrates = facts.carbohydrates ?? 0.0
                nutrition.fat = facts.fat ?? 0.0
                food.nutritionFacts = nutrition
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    
    func updateFood(foodStruct: FoodStruct) {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", foodStruct.id.uuidString)


        do {
            let allFoods = try managedContext.fetch(Food.fetchRequest())
            for food in allFoods {
                if let id = food.id {
                    print("Valid UUID: \(id)")
                } else {
                    print("Invalid UUID: \(food)")
                }
            }

            if let existingFood = try managedContext.fetch(fetchRequest).first {
                // Aktualisiere die vorhandene Food-Entität
                existingFood.name = foodStruct.name
                existingFood.category = foodStruct.category
                existingFood.info = foodStruct.info
                existingFood.density = foodStruct.density as? NSNumber
                
                // Aktualisiere Tags
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

                // Aktualisiere NutritionFacts
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

                // Speichere die Änderungen
                try managedContext.save()
                print("Food erfolgreich aktualisiert")
            } else {
                print("Keine Food-Entität mit dieser ID gefunden. Erstelle eine neue.")
                saveFood(foodStruct: foodStruct) // Falls kein Eintrag gefunden wird, erstelle einen neuen
            }
        } catch let error as NSError {
            print("Fehler beim Aktualisieren: \(error), \(error.userInfo)")
        }
    }

//    func updateRecipe(_ recipe: Recipe) {
//            let recipeEntity = findOrCreateRecipeEntity(from: recipe)
//            
//            // Aktualisieren der Basisdaten
//            recipeEntity.titel = recipe.title
//            recipeEntity.instructions = recipe.instructions
//            recipeEntity.image = recipe.image
//            recipeEntity.portion = recipe.portion?.stringValue()
//            recipeEntity.cake = recipe.cake?.stringValue()
//            recipeEntity.videoLink = recipe.videoLink
//            recipeEntity.info = recipe.info
//            
//            // Aktualisieren der Zutatenliste
//            updateIngredients(for: recipeEntity, with: recipe.ingredients)
//            updateTags(for: recipeEntity, with: recipe.tags!)
//            // Tags und andere Verknüpfungen können hier ebenfalls aktualisiert werden
//
//            // Speichern der Änderungen im Kontext
//            saveContext()
//        }
    
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

        // Update der Rezeptbuch-Beziehung
        updateRecipeBookAssociation(for: recipeEntity, withNewBookIDs: recipe.recipeBookIDs)

        // Tags und andere Verknüpfungen können hier ebenfalls aktualisiert werden
        updateTags(for: recipeEntity, with: recipe.tags!)

        // Änderungen im Kontext speichern
        saveContext()
    }
    
    func syncTag(with tagStruct: TagStruct) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tagStruct.id as CVarArg)

        do {
            let results = try managedContext.fetch(fetchRequest)
            let tag = results.first ?? Tag(context: managedContext)
            tag.id = tagStruct.id
            tag.name = tagStruct.name

            saveContext()
        } catch {
            print("Failed to fetch or save tag: \(error)")
        }
    }
    func updateTags(for recipeEntity: Recipes, with newTags: [TagStruct]) {
        let existingTags = (recipeEntity.tags as? Set<Tag>) ?? Set()
        
        // Erstellen Sie ein Set der aktuellen Tag-IDs
        let currentTagIDs = existingTags.map { $0.id }
        
        // Entfernen Sie alle Tags, die nicht mehr in den neuen Tags enthalten sind
        for tag in existingTags {
            if !newTags.contains(where: { $0.id == tag.id }) {
                recipeEntity.removeFromTags(tag)
            }
        }

        // Fügen Sie neue Tags hinzu, die noch nicht existieren
        for tagStruct in newTags {
            if !currentTagIDs.contains(tagStruct.id) {
                let newTag = findOrCreateTag(tagStruct)
                recipeEntity.addToTags(newTag)
            }
        }
    }

    func findOrCreateTag(_ tagStruct: TagStruct) -> Tag {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tagStruct.id as CVarArg)
        let results = try? managedContext.fetch(fetchRequest)

        if let existingTag = results?.first {
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

        // Bestehende Rezeptbücher zu diesem Rezept holen
        if let currentBooks = recipeEntity.recipesBooks as? Set<Recipebook> {
            let currentBookIDs = currentBooks.map { $0.id! }

            // Entferne das Rezept aus allen Büchern, die nicht mehr in den neuen IDs sind
            for book in currentBooks {
                if !newBookIDs.contains(book.id!) {
                    book.removeFromRecipes(recipeEntity)
                }
            }
        }

        // Füge das Rezept zu den neuen Büchern hinzu
        for newBookID in newBookIDs {
            let bookFetchRequest: NSFetchRequest<Recipebook> = Recipebook.fetchRequest()
            bookFetchRequest.predicate = NSPredicate(format: "id == %@", newBookID as CVarArg)
            if let newBook = try? managedContext.fetch(bookFetchRequest).first {
                if !((newBook.recipes as? Set<Recipes>)?.contains(recipeEntity))! ?? true {
                    newBook.addToRecipes(recipeEntity)
                }
            } else {
                let newBook = Recipebook(context: managedContext)
                newBook.id = newBookID
                newBook.addToRecipes(recipeEntity)
                // Optional: Weitere Initialisierung des neuen Rezeptbuchs
            }
        }

        saveContext()
    }


    private func updateIngredients(for entity: Recipes, with newIngredients: [FoodItemStruct]) {
        // Optional: Löschen oder aktualisieren bestehender Zutaten
        entity.removeFromIngredients(entity.ingredients as! NSSet)
        
        // Hinzufügen der neuen oder aktualisierten Zutaten
        for foodItemStruct in newIngredients {
            let foodItemEntity = findOrCreateFoodItem(foodItemStruct)
            entity.addToIngredients(foodItemEntity)
        }
    }

   


   
}

extension FoodItemStruct {
    init(from managedObject: FoodItem) {
        food = FoodStruct(from: managedObject.food!)
        unit = Unit.fromString(managedObject.unit ?? "") ?? .gram
        quantity = managedObject.quantity
        id = managedObject.id ?? UUID()
    }
}

// Extensions for handling conversion from managed objects to structs might also be needed:
extension FoodStruct {
    init(from managedObject: Food) {
        self.name = managedObject.name ?? ""
        self.category = managedObject.category
        self.density = managedObject.density as? Double
        self.info = managedObject.info
        self.nutritionFacts = NutritionFactsStruct(from: managedObject.nutritionFacts)
        self.id = managedObject.id ?? UUID()
        // Lade Tags
        if let tagsSet = managedObject.tags as? Set<Tag> {
            self.tags = tagsSet.map(TagStruct.init) // Mappe die Tags
        } else {
            self.tags = []
        }
    }
}


extension Recipe {
    init(from managedObject: Recipes) {
        id = managedObject.id ?? UUID()  // Achten Sie darauf, dass IDs korrekt behandelt werden
        title = managedObject.titel ?? "Unbekanntes Rezept"
        instructions = managedObject.instructions ?? []
        image = managedObject.image
        portion = PortionsInfo.fromString(managedObject.portion ?? "")
        cake = CakeInfo.fromString(managedObject.cake ?? "")
        videoLink = managedObject.videoLink
        info = managedObject.info
        if let tagsSet = managedObject.tags as? Set<Tag> {
                   tags = tagsSet.map(TagStruct.init)  // Assuming TagStruct has an initializer that takes a Tag managed object
               } else {
                   tags = []  // If there are no tags, initialize to an empty array
               }
        if let recipeBooksSet = managedObject.recipesBooks as? Set<Recipebook> {
        recipeBookIDs = recipeBooksSet.compactMap { $0.id }
        } else {
        recipeBookIDs = [] // If there are no recipe books, initialize to an empty array
        }
        if let ingredientsSet = managedObject.ingredients as? Set<FoodItem> {
            ingredients = ingredientsSet.map(FoodItemStruct.init)
        } else {
            ingredients = []
        }
    }
}

extension NutritionFactsStruct {
    init(from managedObject: NutritionFacts?) {
           self.calories = Int(managedObject?.calories ?? 0)
           self.protein = managedObject?.protein ?? 0
           self.carbohydrates = managedObject?.carbohydrates ?? 0
           self.fat = managedObject?.fat ?? 0
       }
}

extension RecipebookStruct {
    init(from managedObject: Recipebook) {
        self.id = managedObject.id ?? UUID() // Stellen Sie sicher, dass die Entity Recipebook ein Attribut `id` vom Typ UUID hat
        self.name = managedObject.name ?? ""
        self.recipes = (managedObject.recipes?.allObjects as? [Recipes] ?? []).map(Recipe.init)
        self.tags = (managedObject.tag?.allObjects as? [Tag] ?? []).map(TagStruct.init)
    }
}
