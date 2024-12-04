//
//  Transaction+CoreDataProperties.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/12/2.
//
//

import Foundation
import CoreData

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var settled: Bool
    @NSManaged public var fromPerson: Person
    @NSManaged public var toPerson: Person
    @NSManaged public var trip: Trip

}

extension Transaction : Identifiable {

}
