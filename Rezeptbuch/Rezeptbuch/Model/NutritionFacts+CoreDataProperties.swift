//
//  NutritionFacts+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 22.04.24.
//
//

import Foundation
import CoreData


extension NutritionFacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NutritionFacts> {
        return NSFetchRequest<NutritionFacts>(entityName: "NutritionFacts")
    }

    @NSManaged public var calories: Int64
    @NSManaged public var carbohydrates: Double
    @NSManaged public var fat: Double
    @NSManaged public var protein: Double
    @NSManaged public var food: Food?

}

extension NutritionFacts : Identifiable {

}
