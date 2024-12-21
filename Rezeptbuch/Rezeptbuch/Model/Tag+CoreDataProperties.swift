//
//  Tag+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 21.12.24.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var foods: NSSet?
    @NSManaged public var recipe: NSSet?
    @NSManaged public var recipebook: NSSet?

}

// MARK: Generated accessors for foods
extension Tag {

    @objc(addFoodsObject:)
    @NSManaged public func addToFoods(_ value: Food)

    @objc(removeFoodsObject:)
    @NSManaged public func removeFromFoods(_ value: Food)

    @objc(addFoods:)
    @NSManaged public func addToFoods(_ values: NSSet)

    @objc(removeFoods:)
    @NSManaged public func removeFromFoods(_ values: NSSet)

}

// MARK: Generated accessors for recipe
extension Tag {

    @objc(addRecipeObject:)
    @NSManaged public func addToRecipe(_ value: Recipes)

    @objc(removeRecipeObject:)
    @NSManaged public func removeFromRecipe(_ value: Recipes)

    @objc(addRecipe:)
    @NSManaged public func addToRecipe(_ values: NSSet)

    @objc(removeRecipe:)
    @NSManaged public func removeFromRecipe(_ values: NSSet)

}

// MARK: Generated accessors for recipebook
extension Tag {

    @objc(addRecipebookObject:)
    @NSManaged public func addToRecipebook(_ value: Recipebook)

    @objc(removeRecipebookObject:)
    @NSManaged public func removeFromRecipebook(_ value: Recipebook)

    @objc(addRecipebook:)
    @NSManaged public func addToRecipebook(_ values: NSSet)

    @objc(removeRecipebook:)
    @NSManaged public func removeFromRecipebook(_ values: NSSet)

}

extension Tag : Identifiable {

}
