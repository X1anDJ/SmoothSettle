//
//  Bill+CoreDataProperties.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//
//

import Foundation
import CoreData


extension Bill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bill> {
        return NSFetchRequest<Bill>(entityName: "Bill")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var involvers: NSSet?
    @NSManaged public var payer: Person?
    @NSManaged public var trip: Trip?

}

// MARK: Generated accessors for involvers
extension Bill {
    
    // Computed property to return involvers as an array of Person objects
    var involversArray: [Person] {
        return involvers?.allObjects as? [Person] ?? []
    }

    @objc(addInvolversObject:)
    @NSManaged public func addToInvolvers(_ value: Person)

    @objc(removeInvolversObject:)
    @NSManaged public func removeFromInvolvers(_ value: Person)

    @objc(addInvolvers:)
    @NSManaged public func addToInvolvers(_ values: NSSet)

    @objc(removeInvolvers:)
    @NSManaged public func removeFromInvolvers(_ values: NSSet)
    
    

}

extension Bill : Identifiable {

}
