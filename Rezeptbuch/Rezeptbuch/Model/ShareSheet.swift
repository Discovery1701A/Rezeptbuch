//
//  ShareSheet.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 03.05.24.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        print(activityItems)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update here
    }
}

struct ShareSheetView: View {
    var recipe: Recipe
    @State private var showingShareSheet = false
    @State private var fileURL: URL?
    @State private var customURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        Button("Teilen") {
            serializeRecipeToPlist(recipe: recipe) { actualFileURL, customSchemeURL in
                if let actualFileURL = actualFileURL, FileManager.default.fileExists(atPath: actualFileURL.path) {
                    self.fileURL = actualFileURL
                    self.customURL = customSchemeURL
                    print(customURL, fileURL)
                    showingShareSheet = true
                } else {
                    errorMessage = "Failed to prepare the recipe file for sharing."
                    showingShareSheet = false
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let customURL = customURL, let actaulURL = fileURL {
                
                ShareSheet(activityItems: [actaulURL])
            } else {
                Text(errorMessage ?? "Unable to load the file for sharing")
            }
        }
        .alert(isPresented: Binding<Bool>.constant(fileURL == nil && errorMessage != nil), content: {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        })
    }
}

func serializeRecipeToPlist(recipe: Recipe, completion: @escaping (URL?, URL?) -> Void) {
    var dict = [String: Any]()
    dict["id"] = recipe.id.uuidString
    dict["title"] = recipe.title
    dict["instructions"] = recipe.instructions
   
    dict["videoLink"] = recipe.videoLink ?? ""
    dict["info"] = recipe.info ?? ""
    dict["recipeBookIDs"] = recipe.recipeBookIDs?.map { $0.uuidString }
    if let imagePath = recipe.image {
        if let image = UIImage(contentsOfFile: imagePath) {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                dict["imageData"] = imageData
            }
        } else {
            print("Das Bild konnte nicht geladen werden.")
        }
    } else if let imageName = recipe.image {
        // Hier wird versucht, ein Bild aus den Asset-Katalogen zu laden
        if let image = UIImage(named: imageName) {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                dict["imageData"] = imageData
            }
        } else {
            print("Das Bild konnte nicht aus den Assets geladen werden.")
        }
    }
  
    if let portion = recipe.portion {
        dict["portion"] = portion.stringValue()
    }

    if let cake = recipe.cake {
        dict["cake"] = cake.stringValue()
    }

    dict["ingredients"] = serializeIngredients(ingredients: recipe.ingredients)

    if let tags = recipe.tags {
        dict["tags"] = tags.map { ["id": $0.id.uuidString, "name": $0.name] }
    }

    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("recipe.plist")
     
       
    do {
           let data = try JSONSerialization.data(withJSONObject: dict, options: [])
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let fileURL = documentsDirectory.appendingPathComponent("\(recipe.title).recipe")

           try data.write(to: fileURL)
        let customURL = URL(string: "recipe://open?path=\(fileURL.lastPathComponent)")
           completion(fileURL, customURL)
       } catch {
           print("Failed to write recipe file: \(error)")
           completion(nil, nil)
       }
   }


extension URL {
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return [:]
        }
        guard let queryItems = components.queryItems else { return [:] }

        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

/// iOS App Delegate - URL Scheme Handling:


import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // App initialisieren
        return true
    }
  

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme == "recipe", let path = url.queryParameters["path"] else {
            return false
        }
        
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(path)
        print(fileURL)
        print("Angekommen yhaeeeee")
        //        if let data = try? Data(contentsOf: fileURL), let recipe = deserializeRecipeData(data) {
        //            // Handle the recipe data
        //            print("Recipe loaded: \(recipe.title)")
        //            return true
        //        } else {
        //            print("Failed to load recipe")
        //            return false
        //        }
        return true
    }
    

    
    private func processRecipeData(_ data: Data) {
        // Verarbeite hier die geladenen Rezeptdaten
        print("Processing recipe data...")
        // Beispielsweise deserialisiere die Plist zu einem Rezeptobjekt und zeige es an
    }
}



//class ShareRecipeViewController: UIViewController {
//    var recipe: Recipe!
//
//    func shareRecipe() {
//        serializeRecipeToPlist(recipe: recipe) { [weak self] url in
//            guard let self = self, let url = url else { return }
//            print(url.scheme)
//            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//            activityController.excludedActivityTypes = [.addToReadingList, .assignToContact, .openInIBooks, .print, .saveToCameraRoll]
//            self.present(activityController, animated: true)
//        }
//    }
//}



import Foundation
func importRecipe(from plistData: Data) {
    do {
        // Try to deserialize the Recipe object from plist data
        if let recipe = deserializePlistToRecipe(plistData: plistData) {
            saveRecipe(recipe)
            print("Rezept importiert: \(recipe.title)")
        } else {
            print("Error: Could not deserialize the recipe from the plist data.")
        }
    } catch {
        print("Fehler beim Parsen des Rezepts: \(error)")
    }
}




func saveRecipe(_ recipe: Recipe) {
    // Implementieren Sie Logik zum Speichern des Rezepts in Core Data oder einer anderen lokalen Datenbank
    print("Rezept gespeichert: \(recipe.title)")
}






func serializeIngredients(ingredients: [FoodItemStruct]) -> [[String: Any]] {
    return ingredients.map { ingredient in
        let foodDict = serializeFood(food: ingredient.food)
        let ingredientDict: [String: Any] = [
            "food": foodDict,
            "unit": ingredient.unit.rawValue,
            "quantity": ingredient.quantity
        ]
        return ingredientDict
    }
}

func serializeFood(food: FoodStruct) -> [String: Any] {
    var foodDict = [String: Any]()
    foodDict["id"] = food.id.uuidString
    foodDict["name"] = food.name
    foodDict["category"] = food.category ?? ""
    foodDict["info"] = food.info ?? ""

    var nutritionFactsDict = [String: Any]()
    if let nutritionFacts = food.nutritionFacts {
        nutritionFactsDict["calories"] = nutritionFacts.calories ?? 0
        nutritionFactsDict["protein"] = nutritionFacts.protein ?? 0
        nutritionFactsDict["carbohydrates"] = nutritionFacts.carbohydrates ?? 0
        nutritionFactsDict["fat"] = nutritionFacts.fat ?? 0
    }
    foodDict["nutritionFacts"] = nutritionFactsDict

    if let tags = food.tags {
        foodDict["tags"] = tags.map { tag -> [String: Any] in
            ["id": tag.id.uuidString, "name": tag.name]
        }
    }

    return foodDict
}
func deserializePlistToRecipe(plistData: Data) -> Recipe? {
    do {
        // Parse the plist data to a dictionary
        if let dict = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
            let id = UUID(uuidString: dict["id"] as? String ?? "") ?? UUID()
            let title = dict["title"] as? String ?? ""
            let instructions = dict["instructions"] as? [String] ?? []
            let image = dict["image"] as? String
            let videoLink = dict["videoLink"] as? String
            let info = dict["info"] as? String
            let recipeBookIDs = (dict["recipeBookIDs"] as? [String])?.compactMap(UUID.init)

            var ingredients = [FoodItemStruct]()
            if let ingredientsArray = dict["ingredients"] as? [[String: Any]] {
                for ingredientDict in ingredientsArray {
                    if let foodDict = ingredientDict["food"] as? [String: Any],
                       let nutritionDict = foodDict["nutritionFacts"] as? [String: Any],
                       let foodId = UUID(uuidString: foodDict["id"] as? String ?? ""),
                       let unitString = ingredientDict["unit"] as? String,
                       let unit = Unit(rawValue: unitString),
                       let id = UUID(uuidString: ingredientDict["id"] as? String ?? ""),
                       let quantity = ingredientDict["quantity"] as? Double {

                        let nutritionFacts = NutritionFactsStruct(
                            calories: nutritionDict["calories"] as? Int,
                            protein: nutritionDict["protein"] as? Double,
                            carbohydrates: nutritionDict["carbohydrates"] as? Double,
                            fat: nutritionDict["fat"] as? Double
                        )

                        let food = FoodStruct(
                            id: foodId,
                            name: foodDict["name"] as? String ?? "",
                            category: foodDict["category"] as? String,
                            info: foodDict["info"] as? String,
                            nutritionFacts: nutritionFacts,
                            tags: [] // Tags handling might be added here similarly
                        )

                        let foodItem = FoodItemStruct(food: food, unit: unit, quantity: quantity, id: id)
                        ingredients.append(foodItem)
                    }
                }
            }

            let portion = PortionsInfo.fromString((dict["portion"] as? String)!)
            let cake = CakeInfo.fromString((dict["cake"] as? String)!)
            
            var tags = [TagStruct]()
            if let tagsArray = dict["tags"] as? [[String: Any]] {
                for tagDict in tagsArray {
                    if let tagId = UUID(uuidString: tagDict["id"] as? String ?? ""),
                       let tagName = tagDict["name"] as? String {
                        let tag = TagStruct(name: tagName, id: tagId)
                        tags.append(tag)
                    }
                }
            }

            return Recipe(id: id, title: title, ingredients: ingredients, instructions: instructions, image: image, portion: portion, cake: cake, videoLink: videoLink, info: info, tags: tags, recipeBookIDs: recipeBookIDs)
        }
    } catch {
        print("Error parsing plist: \(error)")
    }
    return nil
}

