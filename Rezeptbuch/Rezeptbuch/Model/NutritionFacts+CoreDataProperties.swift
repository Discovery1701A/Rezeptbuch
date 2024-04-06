//
//  NutritionFacts+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 06.04.24.
//
//

import Foundation
import CoreData


extension NutritionFacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NutritionFacts> {
        return NSFetchRequest<NutritionFacts>(entityName: "NutritionFacts")
    }

    @NSManaged public var calories: Int64
    @NSManaged public var protein: Double
    @NSManaged public var carbohydrates: Double
    @NSManaged public var fat: Double
    @NSManaged public var food: NutritionFacts?

}

extension NutritionFacts : Identifiable {

}
