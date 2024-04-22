//
//  Food+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 22.04.24.
//
//

import Foundation
import CoreData


extension Food {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Food> {
        return NSFetchRequest<Food>(entityName: "Food")
    }

    @NSManaged public var category: String?
    @NSManaged public var info: String?
    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var foodItem: NSSet?
    @NSManaged public var nutritionFacts: NutritionFacts?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for foodItem
extension Food {

    @objc(addFoodItemObject:)
    @NSManaged public func addToFoodItem(_ value: FoodItem)

    @objc(removeFoodItemObject:)
    @NSManaged public func removeFromFoodItem(_ value: FoodItem)

    @objc(addFoodItem:)
    @NSManaged public func addToFoodItem(_ values: NSSet)

    @objc(removeFoodItem:)
    @NSManaged public func removeFromFoodItem(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension Food {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension Food : Identifiable {

}
