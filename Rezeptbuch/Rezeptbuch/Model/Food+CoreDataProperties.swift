//
//  Food+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 06.04.24.
//
//

import Foundation
import CoreData


extension Food {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Food> {
        return NSFetchRequest<Food>(entityName: "Food")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var info: String?
    @NSManaged public var nutritionFacts: NutritionFacts?

}

extension Food : Identifiable {

}
