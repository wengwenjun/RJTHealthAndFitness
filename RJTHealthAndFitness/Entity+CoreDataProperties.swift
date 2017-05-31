//
//  Entity+CoreDataProperties.swift
//  
//
//  Created by Wenjun Weng on 5/23/17.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var step: String?
    @NSManaged public var calories: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var distance: String?
    @NSManaged public var bodyTempature: String?

}
