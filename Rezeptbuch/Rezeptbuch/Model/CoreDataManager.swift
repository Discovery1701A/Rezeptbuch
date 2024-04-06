//
//  CoreDataManager.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 06.04.24.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
//    private init() {}

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
    }// Funktion zum Laden von Food
    func fetchFoods() -> [Food] {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()

        do {
            let foods = try managedContext.fetch(fetchRequest)
            return foods
        } catch {
            print("Error fetching foods: \(error)")
            return []
        }
    }

    // Laden von Food aus Core Data und Einsortieren in foodstruct
        func fetchFoods() -> [foodstruct] {
            let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()

            do {
                let foods = try managedContext.fetch(fetchRequest)
                return foods.map { food in
                    return foodstruct(name: food.name ?? "", category: food.category, info: food.info, nutritionFacts: food.nutritionFacts != nil ? NutritionFactsStruct(calories: Int(food.nutritionFacts!.calories), protein: food.nutritionFacts!.protein, carbohydrates: food.nutritionFacts!.carbohydrates, fat: food.nutritionFacts!.fat) : nil)
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
                    return NutritionFactsStruct(calories: Int(facts.calories), protein: facts.protein, carbohydrates: facts.carbohydrates, fat: facts.fat)
                }
            } catch {
                print("Error fetching nutrition facts: \(error)")
                return []
            }
        }

        // Laden von FoodItem aus Core Data und Einsortieren in FoodItem-Struktur
    func fetchFoodItems() -> [FoodItemStruct] {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()

        do {
            let foodItems = try managedContext.fetch(fetchRequest)
            return foodItems.map { item in
                // Convert NSManagedObject NutritionFacts to NutritionFactsStruct
                let nutritionFactsStruct = NutritionFactsStruct(calories: Int(item.food?.nutritionFacts?.calories ?? 0),
                                                                protein: item.food?.nutritionFacts?.protein ?? 0,
                                                                carbohydrates: item.food?.nutritionFacts?.carbohydrates ?? 0,
                                                                fat: item.food?.nutritionFacts?.fat ?? 0)

                return FoodItemStruct(food: foodstruct(name: item.food?.name ?? "",
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
        func saveFood(_ food: foodstruct) {
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
                foodManagedObject.nutritionFacts = nutritionFactsManagedObject
            }

            do {
                try managedContext.save()
            } catch {
                print("Error saving food: \(error)")
            }
        }

        // Speichern von FoodItem in Core Data
        func saveFoodItem(_ item: FoodItemStruct) {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedContext) else {
                return
            }

            let foodItemManagedObject = FoodItem(entity: entityDescription, insertInto: managedContext)
            foodItemManagedObject.food = saveAndGetFoodManagedObject(item.food)
            foodItemManagedObject.unit = Unit.toString(item.unit)
            foodItemManagedObject.quantity = item.quantity

            do {
                try managedContext.save()
            } catch {
                print("Error saving food item: \(error)")
            }
        }

        // Funktion zum Speichern von Food und Rückgabe des entsprechenden Food-NSManagedObjects
        private func saveAndGetFoodManagedObject(_ food: foodstruct) -> Food {
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

    // Funktion zum Laden von Recipes
    func fetchRecipes() -> [Recipes] {
        let fetchRequest: NSFetchRequest<Recipes> = Recipes.fetchRequest()

        do {
            let recipes = try managedContext.fetch(fetchRequest)
            return recipes
        } catch {
            print("Error fetching recipes: \(error)")
            return []
        }
    }

    // Funktion zum Speichern von Recipes
    func saveRecipe(_ title: String, _ image: String?, _ ingredients: [FoodItemStruct]?, _ instructions: [String]?, _ id: Int64, _ portion: String?, _ cake: String?) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Recipes", in: managedContext) else {
            return
        }

        let recipe = Recipes(entity: entityDescription, insertInto: managedContext)
        recipe.titel = title
        recipe.image = image
       
        for ingredient in ingredients!{
            let foodItemManagedObject = FoodItem(entity: entityDescription, insertInto: managedContext)
            foodItemManagedObject.food = saveAndGetFoodManagedObject(ingredient.food)
            foodItemManagedObject.unit = Unit.toString(ingredient.unit)
            foodItemManagedObject.quantity = ingredient.quantity
            recipe.ingredient?.append(foodItemManagedObject)
        }
        
        recipe.instructions = instructions
        recipe.id = id
        recipe.portion = portion
        recipe.cake = cake

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
        recipe.ingredient = ingredients
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
            recipeEntity.ingredient = recipe.ingredients.map { foodItem in
                let foodItemEntity = FoodItem(context: managedContext)
                foodItemEntity.food = Food(context: managedContext)
                foodItemEntity.food?.name = foodItem.food.name
                foodItemEntity.food?.category = foodItem.food.category
                foodItemEntity.food?.info = foodItem.food.info
                // Hier musst du den Rest der Eigenschaften setzen, je nachdem, was du in deiner Datenbank benötigst
                foodItemEntity.unit = Unit.toString(foodItem.unit) // Umwandlung der Enum-Instanz in einen String
                foodItemEntity.quantity = foodItem.quantity
                return foodItemEntity
            }
            // Hier musst du die restlichen Eigenschaften des Rezepts setzen, je nachdem, was du in deiner Datenbank benötigst
            recipeEntity.portion = recipe.portion?.stringValue() // Umwandlung der PortionsInfo-Enum in einen String
            recipeEntity.cake = recipe.cake?.stringValue() // Umwandlung der CakeInfo-Enum in einen String
        }

        do {
            try managedContext.save()
            print("Initiale Daten erfolgreich in der Datenbank gespeichert.")
        } catch {
            print("Fehler beim Speichern der initialen Daten: \(error)")
        }
    }

}
