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

    func saveRecipe(_ recipe: Recipe) {
        let recipeEntity = findOrCreateRecipeEntity(from: recipe)
        populateRecipeEntity(recipeEntity, from: recipe)
        saveContext()
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

    
    private func populateRecipeEntity(_ entity: Recipes, from recipe: Recipe) {
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
        // Überprüfen, ob die Datenbank leer ist
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        let count = try? managedContext.count(for: fetchRequest)

        guard let recipeCount = count, recipeCount == 0 else {
            print("Die Datenbank enthält bereits Datensätze. Keine Aktion erforderlich.")
            return
        }

        // Datenbank ist leer, füge die initialen Daten ein
        let recipesToInsert = [pastaRecipe, brownieRecipe] // Die zu speichernden Rezepte

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
                    let tag = findOrCreateTag(name: tagName.name)
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

    private func findOrCreateTag(name: String) -> Tag {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        if let existingTag = try? managedContext.fetch(fetchRequest).first {
            return existingTag
        } else {
            let newTag = Tag(context: managedContext)
            newTag.name = name
            return newTag
        }
    }

    private func findOrCreateFoodItem(_ item: FoodItemStruct) -> FoodItem {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "food.name == %@ AND unit == %@", item.food.name, Unit.toString(item.unit))

        if let existingItem = try? managedContext.fetch(fetchRequest).first {
            existingItem.quantity += item.quantity // Update quantity if the item already exists
            return existingItem
        } else {
            let newFoodItem = FoodItem(context: managedContext)
            let food = findOrCreateFood(foodStruct: item.food)
            newFoodItem.food = food
            newFoodItem.unit = Unit.toString(item.unit)
            newFoodItem.quantity = item.quantity
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
            newFood.info = foodStruct.info
            return newFood
        }
    }
    
    func saveFood(foodStruct: FoodStruct) {
            let food = Food(context: managedContext)
        food.name = foodStruct.name
        food.category = foodStruct.category
        food.info = foodStruct.info
            
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
    
    func updateRecipe(_ recipe: Recipe) {
        let recipeEntity = findOrCreateRecipeEntity(from: recipe)
        
        // Aktualisieren der Basisdaten
        recipeEntity.titel = recipe.title
        recipeEntity.instructions = recipe.instructions
        recipeEntity.image = recipe.image
        recipeEntity.portion = recipe.portion?.stringValue()
        recipeEntity.cake = recipe.cake?.stringValue()
        recipeEntity.videoLink = recipe.videoLink
        recipeEntity.info = recipe.info
        
        // Aktualisieren der Zutatenliste
        updateIngredients(for: recipeEntity, with: recipe.ingredients)
        
        // Tags und andere Verknüpfungen können hier ebenfalls aktualisiert werden

        // Speichern der Änderungen im Kontext
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
    }
}

// Extensions for handling conversion from managed objects to structs might also be needed:
extension FoodStruct {
    init(from managedObject: Food) {
        self.name = managedObject.name ?? ""
        self.category = managedObject.category
        self.info = managedObject.info
        self.nutritionFacts = NutritionFactsStruct(from: managedObject.nutritionFacts)
        self.id = managedObject.id ?? UUID()
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
