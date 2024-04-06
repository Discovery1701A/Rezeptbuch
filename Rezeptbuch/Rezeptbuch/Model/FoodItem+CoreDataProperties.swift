//
//  FoodItem+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 06.04.24.
//
//

import Foundation
import CoreData


extension FoodItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItems> {
        return NSFetchRequest<FoodItems>(entityName: "FoodItem")
    }

    @NSManaged public var unit: String?
    @NSManaged public var quantity: Double
    @NSManaged public var food: Food?

}

extension FoodItems : Identifiable {

}
