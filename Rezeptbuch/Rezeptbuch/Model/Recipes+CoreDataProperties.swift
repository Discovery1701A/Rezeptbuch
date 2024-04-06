//
//  Recipes+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 06.04.24.
//
//

import Foundation
import CoreData


extension Recipes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipes> {
        return NSFetchRequest<Recipes>(entityName: "Recipes")
    }

    @NSManaged public var titel: String?
    @NSManaged public var image: String?
    @NSManaged public var ingredient: [FoodItem]?
    @NSManaged public var instructions: [String]?
    @NSManaged public var id: Int64
    @NSManaged public var portion: String?
    @NSManaged public var cake: String?

}

extension Recipes : Identifiable {

}
