//
//  Food+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 15.04.24.
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
    @NSManaged public var nutritionFacts: NutritionFacts?
    @NSManaged public var foodItem: NSSet?

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

extension Food : Identifiable {

}
