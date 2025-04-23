//
//  FoodItem+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 14.04.25.
//
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var number: Int64
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String?
    @NSManaged public var recipecomponent: String?
    @NSManaged public var food: Food?
    @NSManaged public var recipe: NSSet?

}

// MARK: Generated accessors for recipe
extension FoodItem {

    @objc(addRecipeObject:)
    @NSManaged public func addToRecipe(_ value: Recipes)

    @objc(removeRecipeObject:)
    @NSManaged public func removeFromRecipe(_ value: Recipes)

    @objc(addRecipe:)
    @NSManaged public func addToRecipe(_ values: NSSet)

    @objc(removeRecipe:)
    @NSManaged public func removeFromRecipe(_ values: NSSet)

}

extension FoodItem : Identifiable {

}
