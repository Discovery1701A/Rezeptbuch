//
//  ShareSheet.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 03.05.24.
//

import SwiftUI
import UIKit
import PDFKit

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
    @State private var showingActionSheet = false
    @State private var showingShareSheet = false
    @State private var selectedFileURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            Image(systemName: "square.and.arrow.up") // Teilen-Icon
                .font(.system(size: 24))
                .foregroundColor(.blue)
        }
        .buttonStyle(PlainButtonStyle())
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Dateiformat wählen"),
                message: Text("Möchtest du das Rezept als PDF oder Rezeptdatei exportieren?"),
                buttons: [
                    .default(Text("Als PDF exportieren")) {
                        if let pdfURL = generatePDF(for: recipe) {
                            selectedFileURL = pdfURL
                            showingShareSheet = true
                        } else {
                            errorMessage = "PDF-Erstellung fehlgeschlagen."
                        }
                    },
                    .default(Text("Als Rezeptdatei exportieren")) {
                        serializeRecipeToPlist(recipe: recipe) { fileURL, _ in
                            if let fileURL = fileURL {
                                selectedFileURL = fileURL
                                showingShareSheet = true
                            } else {
                                errorMessage = "Rezeptdatei konnte nicht erstellt werden."
                            }
                        }
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileURL = selectedFileURL {
                ShareSheet(activityItems: [fileURL])
            } else {
                Text(errorMessage ?? "Fehler beim Laden der Datei.")
            }
        }
        .alert(isPresented: Binding<Bool>.constant(selectedFileURL == nil && errorMessage != nil), content: {
            Alert(title: Text("Fehler"), message: Text(errorMessage ?? "Unbekannter Fehler"), dismissButton: .default(Text("OK")))
        })
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
    var contentView: ContentView? // Referenz zur ContentView für importedRecipe

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("📂 Datei-Öffnen-Event über AppDelegate erhalten: \(url)")

        DispatchQueue.main.async {
            self.openRecipeFile(at: url)
        }

        return true
    }

    private func openRecipeFile(at url: URL) {
        print("📂 Datei wird verarbeitet: \(url)")

        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let fileManager = FileManager.default
                let tempDirectory = FileManager.default.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)

                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                try fileManager.copyItem(at: url, to: destinationURL)
                print("✅ Datei erfolgreich nach: \(destinationURL) kopiert")

                let data = try Data(contentsOf: destinationURL)
                print("📂 Dateigröße: \(data.count) Bytes")

                if let recipe = deserializePlistToRecipe(plistData: data) {
                    print("🎉 Rezept erfolgreich geladen: \(recipe.title)")

                    // 📌 Rezept NUR temporär speichern und an ContentView übergeben
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .recipeOpened, object: recipe)
                    }
                } else {
                    print("❌ Fehler: Konnte Rezept nicht deserialisieren.")
                }
            } catch {
                print("❌ Fehler beim Kopieren oder Öffnen der Datei: \(error)")
            }
        } else {
            print("❌ Fehler: Kein Zugriff auf die Datei möglich (Security-Scoped Resource)")
        }
    }
}

import Foundation


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
            
            let portion: PortionsInfo? = {
                if let portionString = dict["portion"] as? String {
                    return PortionsInfo.fromString(portionString)
                }
                return nil
            }()

            let cake: CakeInfo? = {
                if let cakeString = dict["cake"] as? String {
                    return CakeInfo.fromString(cakeString)
                }
                return nil
            }()
            
            var ingredients = [FoodItemStruct]()
            if let ingredientsArray = dict["ingredients"] as? [[String: Any]] {
                for ingredientDict in ingredientsArray {
                    guard let ingredientIdString = ingredientDict["id"] as? String,
                          let ingredientId = UUID(uuidString: ingredientIdString),
                          let foodDict = ingredientDict["food"] as? [String: Any],
                          let foodIdString = foodDict["id"] as? String,
                          let foodId = UUID(uuidString: foodIdString),
                          let name = foodDict["name"] as? String,
                          let unitString = ingredientDict["unit"] as? String,
                          let unit = Unit(rawValue: unitString),
                          let quantity = ingredientDict["quantity"] as? Double else {
                        print("⚠️ Fehler beim Dekodieren eines Ingredients: \(ingredientDict)")
                        continue
                    }

                    let nutritionFacts = NutritionFactsStruct(
                        calories: (foodDict["nutritionFacts"] as? [String: Any])?["calories"] as? Int ?? 0,
                        protein: (foodDict["nutritionFacts"] as? [String: Any])?["protein"] as? Double ?? 0.0,
                        carbohydrates: (foodDict["nutritionFacts"] as? [String: Any])?["carbohydrates"] as? Double ?? 0.0,
                        fat: (foodDict["nutritionFacts"] as? [String: Any])?["fat"] as? Double ?? 0.0
                    )

                    let food = FoodStruct(
                        id: foodId,
                        name: name,
                        category: foodDict["category"] as? String,
                        density: foodDict["density"] as? Double ?? 0.0,
                        info: foodDict["info"] as? String,
                        nutritionFacts: nutritionFacts
                    )

                    let foodItem = FoodItemStruct(food: food, unit: unit, quantity: quantity, id: ingredientId)
                    ingredients.append(foodItem)
                }
            }
            

          
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

func serializeRecipeToPlist(recipe: Recipe, completion: @escaping (URL?, URL?) -> Void) {
    var dict: [String: Any] = [
        "id": recipe.id.uuidString,
        "title": recipe.title,
        "instructions": recipe.instructions,
        "videoLink": recipe.videoLink ?? "",
        "info": recipe.info ?? "",
        "recipeBookIDs": recipe.recipeBookIDs?.map { $0.uuidString } ?? [],
        "ingredients": serializeIngredients(ingredients: recipe.ingredients),
        "tags": recipe.tags?.map { ["id": $0.id.uuidString, "name": $0.name] } ?? []
    ]

    if let imagePath = recipe.image, let image = UIImage(contentsOfFile: imagePath), let imageData = image.jpegData(compressionQuality: 1.0) {
        dict["imageData"] = imageData
    }

    if let portion = recipe.portion {
        dict["portion"] = portion.stringValue()
    }

    if let cake = recipe.cake {
        dict["cake"] = cake.stringValue()
    }

    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
        let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        let fileURL = documentsDirectory.appendingPathComponent("\(recipe.title).recipe")

        try data.write(to: fileURL)
        let customURL = URL(string: "recipe://open?path=\(fileURL.lastPathComponent)")
        completion(fileURL, customURL)
    } catch {
        print("❌ Fehler beim Speichern der Rezeptdatei: \(error)")
        completion(nil, nil)
    }
}

func serializeIngredients(ingredients: [FoodItemStruct]) -> [[String: Any]] {
    return ingredients.map { ingredient in
        let foodDict = serializeFood(food: ingredient.food)
        let ingredientDict: [String: Any] = [
            "food": foodDict,
            "id": ingredient.id.uuidString,
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
    foodDict["density"] = food.density ?? 0

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


func generatePDF(for recipe: Recipe) -> URL? {
    let fileName = "\(recipe.title).pdf"
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let pdfURL = documentsDirectory.appendingPathComponent(fileName)

    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // A4-Seite
    
    do {
        try pdfRenderer.writePDF(to: pdfURL, withActions: { context in
            context.beginPage()
            
            let pageWidth: CGFloat = 612
            let margin: CGFloat = 40
            var yOffset: CGFloat = 50
            
            // Titel des Rezepts (zentriert)
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.alignment = .center
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .paragraphStyle: titleStyle
            ]
            let titleString = NSAttributedString(string: recipe.title, attributes: titleAttributes)
            titleString.draw(in: CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 30))
            
            yOffset += 40
            
            // Rezept-Bild (falls vorhanden)
            if let imagePath = recipe.image, let image = UIImage(contentsOfFile: imagePath) {
                let imageRect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 150)
                image.draw(in: imageRect)
                yOffset += 160
            }

            // Rezept-Infos (Portionen, Tags, Form)
            let infoStyle = NSMutableParagraphStyle()
            infoStyle.alignment = .left
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .paragraphStyle: infoStyle
            ]
            var infoText = ""

            if let portion = recipe.portion, portion != .notPortion {
                infoText += "Portionen: \(portion.stringValue())\n"
            }

            if case let .cake(_, size) = recipe.cake, recipe.cake != .notCake {
                switch size {
                case .rectangular(let length, let width):
                    infoText += "Rechteckige Form: \(length) x \(width) cm\n"
                case .round(let diameter):
                    infoText += "Runde Form: \(diameter) cm\n"
                }
            }

            let tagsText = recipe.tags?.map { $0.name }.joined(separator: ", ") ?? "Keine Tags"
            infoText += "Tags: \(tagsText)"

            let infoString = NSAttributedString(string: infoText, attributes: infoAttributes)
            infoString.draw(in: CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 70))
            
            yOffset += 80
            
            // Zutaten
            let sectionTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .paragraphStyle: infoStyle
            ]
            let sectionTitle = NSAttributedString(string: "Zutaten:", attributes: sectionTitleAttributes)
            sectionTitle.draw(at: CGPoint(x: margin, y: yOffset))
            yOffset += 25
            
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: NSMutableParagraphStyle()
            ]
            
            for ingredient in recipe.ingredients {
                let ingredientString = NSAttributedString(
                    string: "- \(ingredient.food.name) \(ingredient.quantity) \(ingredient.unit.rawValue)",
                    attributes: bodyAttributes
                )
                ingredientString.draw(at: CGPoint(x: margin, y: yOffset))
                yOffset += 20
            }
            
            yOffset += 20

            // Zubereitung
            let instructionsTitle = NSAttributedString(string: "Zubereitung:", attributes: sectionTitleAttributes)
            instructionsTitle.draw(at: CGPoint(x: margin, y: yOffset))
            yOffset += 25
            
            for (index, step) in recipe.instructions.enumerated() {
                let stepString = NSAttributedString(
                    string: "\(index + 1). \(step)",
                    attributes: bodyAttributes
                )
                stepString.draw(in: CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 50))
                yOffset += 40
            }
        })
        
        return pdfURL
    } catch {
        print("Error generating PDF: \(error)")
        return nil
    }
}

extension Notification.Name {
    static let recipeOpened = Notification.Name("recipeOpened")
}
