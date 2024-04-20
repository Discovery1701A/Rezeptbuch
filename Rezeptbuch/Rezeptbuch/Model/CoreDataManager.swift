import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Laden von Food aus Core Data und Einsortieren in FoodStruct
    func fetchFoods() -> [FoodStruct] {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        
        do {
            let foods = try managedContext.fetch(fetchRequest)
            return foods.map { food in
                return FoodStruct(name: food.name ?? "",
                                  category: food.category,
                                  info: food.info,
                                  nutritionFacts: food.nutritionFacts != nil ? NutritionFactsStruct(calories: Int(food.nutritionFacts!.calories),
                                                                                                    protein: food.nutritionFacts!.protein,
                                                                                                    carbohydrates: food.nutritionFacts!.carbohydrates,
                                                                                                    fat: food.nutritionFacts!.fat) : nil)
            }
        } catch {
            print("Error fetching foods: \(error)")
            return []
        }
    }
    
    // Laden von NutritionFacts aus Core Data und Einsortieren in NutritionFactsStruct
    func fetchNutritionFacts() -> [NutritionFactsStruct] {
        let fetchRequest: NSFetchRequest<NutritionFacts> = NutritionFacts.fetchRequest()
        
        do {
            let nutritionFacts = try managedContext.fetch(fetchRequest)
            return nutritionFacts.map { facts in
                return NutritionFactsStruct(calories: Int(facts.calories),
                                            protein: facts.protein,
                                            carbohydrates: facts.carbohydrates,
                                            fat: facts.fat)
            }
        } catch {
            print("Error fetching nutrition facts: \(error)")
            return []
        }
    }
    
    // Laden von FoodItem aus Core Data und Einsortieren in FoodItemStruct
    func fetchFoodItems() -> [FoodItemStruct] {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        
        do {
            let foodItems = try managedContext.fetch(fetchRequest)
            return foodItems.map { item in
                let nutritionFactsStruct = NutritionFactsStruct(calories: Int(item.food?.nutritionFacts?.calories ?? 0),
                                                                protein: item.food?.nutritionFacts?.protein ?? 0,
                                                                carbohydrates: item.food?.nutritionFacts?.carbohydrates ?? 0,
                                                                fat: item.food?.nutritionFacts?.fat ?? 0)
                
                return FoodItemStruct(food: FoodStruct(name: item.food?.name ?? "",
                                                       category: item.food?.category,
                                                       info: item.food?.info,
                                                       nutritionFacts: nutritionFactsStruct),
                                      unit: Unit.fromString(item.unit ?? "") ?? .gram,
                                      quantity: item.quantity)
            }
        } catch {
            print("Error fetching food items: \(error)")
            return []
        }
    }
    
    // Speichern von Food in Core Data
    func saveFood(_ food: FoodStruct) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedContext) else {
            return
        }

        let foodManagedObject = Food(entity: entityDescription, insertInto: managedContext)
        foodManagedObject.name = food.name
        foodManagedObject.category = food.category
        foodManagedObject.info = food.info

        if let nutritionFacts = food.nutritionFacts {
            let nutritionFactsManagedObject = NutritionFacts(context: managedContext)
            nutritionFactsManagedObject.calories = Int64(nutritionFacts.calories ?? 0)
            nutritionFactsManagedObject.protein = nutritionFacts.protein ?? 0
            nutritionFactsManagedObject.carbohydrates = nutritionFacts.carbohydrates ?? 0
            nutritionFactsManagedObject.fat = nutritionFacts.fat ?? 0

            // Verknüpfung zwischen Food und NutritionFacts herstellen
            foodManagedObject.nutritionFacts = nutritionFactsManagedObject

            // Auch die inverse Beziehung von NutritionFacts zu Food aktualisieren
            nutritionFactsManagedObject.food = foodManagedObject
        }

        do {
            try managedContext.save()
        } catch {
            print("Error saving food: \(error)")
        }
    }

    // Speichern von FoodItem in Core Data
    func saveFoodItem(_ item: FoodItemStruct, food: Food) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedContext) else {
            return
        }

        let foodItemManagedObject = FoodItem(entity: entityDescription, insertInto: managedContext)
        foodItemManagedObject.food = food // Die Beziehung zum übergebenen Food-Objekt setzen
        foodItemManagedObject.unit = Unit.toString(item.unit)
        foodItemManagedObject.quantity = item.quantity

        do {
            try managedContext.save()
        } catch {
            print("Error saving food item: \(error)")
        }
    }
    
    // Funktion zum Speichern von Food und Rückgabe des entsprechenden Food-NSManagedObjects
    private func saveAndGetFoodManagedObject(_ food: FoodStruct) -> Food {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedContext) else {
            fatalError("Entity not found")
        }
        
        let foodManagedObject = Food(entity: entityDescription, insertInto: managedContext)
        foodManagedObject.name = food.name
        foodManagedObject.category = food.category
        foodManagedObject.info = food.info
        
        if let nutritionFacts = food.nutritionFacts {
            let nutritionFactsManagedObject = NutritionFacts(context: managedContext)
            nutritionFactsManagedObject.calories = Int64(nutritionFacts.calories ?? 0)
            nutritionFactsManagedObject.protein = nutritionFacts.protein ?? 0
            nutritionFactsManagedObject.carbohydrates = nutritionFacts.carbohydrates ?? 0
            nutritionFactsManagedObject.fat = nutritionFacts.fat ?? 0
            foodManagedObject.nutritionFacts = nutritionFactsManagedObject
        }
        
        return foodManagedObject
    }
    
    func fetchRecipes() -> [Recipe] {
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()
        
        do {
            let recipes = try managedContext.fetch(fetchRequest)
            return recipes.map { recipe in
                // Mapping der Properties von Recipes auf Recipe
                let recipeIngredients = (recipe.ingredients?.allObjects as? [FoodItem] ?? []).map { foodItem in
                    FoodItemStruct(food: FoodStruct(name: foodItem.food?.name ?? "", category: foodItem.food?.category, info: foodItem.food?.info), unit: Unit.fromString(foodItem.unit ?? "") ?? .gram, quantity: foodItem.quantity)
                }
                
                return Recipe(
                    id: Int(recipe.id),
                    title: recipe.titel ?? "",
                    ingredients: recipeIngredients,
                    instructions: recipe.instructions ?? [],
                    image: recipe.image,
                    portion: PortionsInfo.fromString(recipe.portion ?? ""),
                    cake: CakeInfo.fromString(recipe.cake ?? ""),
                    videoLink: recipe.videoLink
                )
            }
        } catch {
            print("Error fetching recipes: \(error)")
            return []
        }
    }

    
    // Funktion zum Speichern von Recipes
    func saveRecipe(_ recipe : Recipe) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Recipes", in: managedContext) else {
            return
        }
        
        var shoudSave = true
        let consrecipe = fetchRecipes()
        for existRecepie in consrecipe {
            if existRecepie.title == recipe.title && existRecepie.instructions == recipe.instructions && existRecepie.ingredients == recipe.ingredients && existRecepie.cake == recipe.cake && existRecepie.portion == recipe.portion && existRecepie.videoLink == recipe.videoLink {
                shoudSave = false
            }
        }
        
        if shoudSave {
            let recipeEntity = Recipes(context: managedContext)
            recipeEntity.titel = recipe.title
            recipeEntity.id = Int64(recipe.id)
            recipeEntity.image = recipe.image
            recipeEntity.instructions = recipe.instructions
            
            // Überprüfen, ob Zutaten vorhanden sind
            if !recipe.ingredients.isEmpty {
                for foodItem in recipe.ingredients {
                    let foodItemEntity = FoodItem(context: managedContext)
                    foodItemEntity.food = Food(context: managedContext)
                    foodItemEntity.food?.name = foodItem.food.name
                    foodItemEntity.food?.category = foodItem.food.category
                    foodItemEntity.food?.info = foodItem.food.info
                    foodItemEntity.unit = Unit.toString(foodItem.unit)
                    foodItemEntity.quantity = foodItem.quantity
                    
                    // Hinzufügen des FoodItemEntity zum Rezept
                    recipeEntity.addToIngredients(foodItemEntity)
                }
            }
            recipeEntity.portion = recipe.portion?.stringValue()
            recipeEntity.cake = recipe.cake?.stringValue()
            recipeEntity.videoLink = recipe.videoLink
        }

        do {
            try managedContext.save()
        } catch {
            print("Error saving recipe: \(error)")
        }
    }
    
    // Funktion zum Bearbeiten von Recipes
    func editRecipe(_ recipe: Recipes, title: String, image: String?, ingredients: [FoodItem]?, instructions: [String]?, portion: String?, cake: String?) {
        recipe.titel = title
        recipe.image = image
        // Hier wird die ingredients-Beziehung aktualisiert
        if let ingredients = ingredients {
            // NSSet erstellen und zuweisen
            let foodItemSet = NSSet(array: ingredients.map { foodItem in
                let foodItemManagedObject = FoodItem(context: managedContext)
                // Umwandlung von Food zu FoodStruct
                let foodStruct = FoodStruct(name: foodItem.food?.name ?? "",
                                             category: foodItem.food?.category,
                                             info: foodItem.food?.info)
                foodItemManagedObject.food = saveAndGetFoodManagedObject(foodStruct)
                foodItemManagedObject.unit = foodItem.unit
                foodItemManagedObject.quantity = foodItem.quantity
                return foodItemManagedObject
            })
            recipe.ingredients = foodItemSet
        } else {
            // Wenn keine neuen Zutaten angegeben sind, entfernen wir alle vorhandenen Zutaten
            recipe.ingredients = nil
        }
        recipe.instructions = instructions
        recipe.portion = portion
        recipe.cake = cake

        do {
            try managedContext.save()
        } catch {
            print("Error editing recipe: \(error)")
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
        let recipesToInsert = [pastaRecipe, brownie] // Die zu speichernden Rezepte

        for recipe in recipesToInsert {
            let recipeEntity = Recipes(context: managedContext)
            recipeEntity.titel = recipe.title
            recipeEntity.id = Int64(recipe.id)
            recipeEntity.image = recipe.image
            recipeEntity.instructions = recipe.instructions

            // Überprüfen, ob Zutaten vorhanden sind
            if !recipe.ingredients.isEmpty {
                for foodItem in recipe.ingredients {
                    let foodItemEntity = FoodItem(context: managedContext)
                    foodItemEntity.food = Food(context: managedContext)
                    foodItemEntity.food?.name = foodItem.food.name
                    foodItemEntity.food?.category = foodItem.food.category
                    foodItemEntity.food?.info = foodItem.food.info
                    foodItemEntity.unit = Unit.toString(foodItem.unit)
                    foodItemEntity.quantity = foodItem.quantity

                    // Hinzufügen des FoodItemEntity zum Rezept
                    recipeEntity.addToIngredients(foodItemEntity)
                }
            }
            recipeEntity.portion = recipe.portion?.stringValue()
            recipeEntity.cake = recipe.cake?.stringValue()
        }

        do {
            try managedContext.save()
            print("Initiale Daten erfolgreich in der Datenbank gespeichert.")
        } catch {
            print("Fehler beim Speichern der initialen Daten: \(error)")
        }
    }

    // MARK: - Adding and Removing Food Items

    // Hinzufügen eines FoodItem-Objekts zu einem Food-Objekt
    func addToFoodItem(_ foodItem: FoodItem, to food: Food) {
        food.addToFoodItem(foodItem)
        saveContext()
    }

    // Entfernen eines FoodItem-Objekts von einem Food-Objekt
    func removeFromFoodItem(_ foodItem: FoodItem, from food: Food) {
        food.removeFromFoodItem(foodItem)
        saveContext()
    }

    // MARK: - Saving Context

    // Speichern des Managed Context
    private func saveContext() {
        do {
            try managedContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
