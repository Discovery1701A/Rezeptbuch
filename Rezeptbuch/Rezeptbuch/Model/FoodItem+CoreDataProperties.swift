//
//  FoodItem+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 21.04.24.
//
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }

    @NSManaged public var quantity: Double
    @NSManaged public var unit: String?
    @NSManaged public var food: Food?
    @NSManaged public var recipe: Recipes?

}

extension FoodItem : Identifiable {

}
