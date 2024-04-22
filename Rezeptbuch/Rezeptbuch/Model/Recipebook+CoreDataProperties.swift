//
//  Recipebook+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 21.04.24.
//
//

import Foundation
import CoreData


extension Recipebook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipebook> {
        return NSFetchRequest<Recipebook>(entityName: "Recipebook")
    }

    @NSManaged public var name: String?
    @NSManaged public var recipes: NSSet?
    @NSManaged public var tag: NSSet?

}

// MARK: Generated accessors for recipes
extension Recipebook {

    @objc(addRecipesObject:)
    @NSManaged public func addToRecipes(_ value: Recipes)

    @objc(removeRecipesObject:)
    @NSManaged public func removeFromRecipes(_ value: Recipes)

    @objc(addRecipes:)
    @NSManaged public func addToRecipes(_ values: NSSet)

    @objc(removeRecipes:)
    @NSManaged public func removeFromRecipes(_ values: NSSet)

}

// MARK: Generated accessors for tag
extension Recipebook {

    @objc(addTagObject:)
    @NSManaged public func addToTag(_ value: Tag)

    @objc(removeTagObject:)
    @NSManaged public func removeFromTag(_ value: Tag)

    @objc(addTag:)
    @NSManaged public func addToTag(_ values: NSSet)

    @objc(removeTag:)
    @NSManaged public func removeFromTag(_ values: NSSet)

}

extension Recipebook : Identifiable {

}
