//
//  Tag+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 15.04.24.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var name: String?
    @NSManaged public var recipe: NSSet?
    @NSManaged public var category: NSSet?

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

// MARK: Generated accessors for category
extension Tag {

    @objc(addCategoryObject:)
    @NSManaged public func addToCategory(_ value: Category)

    @objc(removeCategoryObject:)
    @NSManaged public func removeFromCategory(_ value: Category)

    @objc(addCategory:)
    @NSManaged public func addToCategory(_ values: NSSet)

    @objc(removeCategory:)
    @NSManaged public func removeFromCategory(_ values: NSSet)

}

extension Tag : Identifiable {

}
