//
//  FoodItem+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 06.04.24.
//
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }

    @NSManaged public var unit: String?
    @NSManaged public var quantity: Double
    @NSManaged public var food: Food?

}

extension FoodItem : Identifiable {

}
