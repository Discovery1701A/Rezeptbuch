//
//  Category+CoreDataProperties.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 15.04.24.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?

}

extension Category : Identifiable {

}
