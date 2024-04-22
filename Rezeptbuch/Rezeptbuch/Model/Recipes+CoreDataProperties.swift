//
//  Recipes+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 22.04.24.
//
//

import Foundation
import CoreData


extension Recipes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipes> {
        return NSFetchRequest<Recipes>(entityName: "Recipes")
    }

    @NSManaged public var cake: String?
    @NSManaged public var id: UUID?
    @NSManaged public var image: String?
    @NSManaged public var instructions: [String]?
    @NSManaged public var portion: String?
    @NSManaged public var titel: String?
    @NSManaged public var videoLink: String?
    @NSManaged public var info: String?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var recipesBooks: NSSet?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for ingredients
extension Recipes {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: FoodItem)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: FoodItem)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

// MARK: Generated accessors for recipesBooks
extension Recipes {

    @objc(addRecipesBooksObject:)
    @NSManaged public func addToRecipesBooks(_ value: Recipebook)

    @objc(removeRecipesBooksObject:)
    @NSManaged public func removeFromRecipesBooks(_ value: Recipebook)

    @objc(addRecipesBooks:)
    @NSManaged public func addToRecipesBooks(_ values: NSSet)

    @objc(removeRecipesBooks:)
    @NSManaged public func removeFromRecipesBooks(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension Recipes {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension Recipes : Identifiable {

}
