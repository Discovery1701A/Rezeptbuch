//
//  Recipes+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 20.04.24.
//
//

import Foundation
import CoreData


extension Recipes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipes> {
        return NSFetchRequest<Recipes>(entityName: "Recipes")
    }

    @NSManaged public var cake: String?
    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var instructions: [String]?
    @NSManaged public var portion: String?
    @NSManaged public var titel: String?
    @NSManaged public var videoLink: String?
    @NSManaged public var ingredients: NSSet?

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

extension Recipes : Identifiable {

}
