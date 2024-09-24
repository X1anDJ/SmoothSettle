//
//  Person+Convenience.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import Foundation
import CoreData

extension Person {
    // Convenience method to return sorted bills as an array
    public var billsArray: [Bill] {
        let set = bills as? Set<Bill> ?? []
        return set.sorted { $0.title ?? "" < $1.title ?? "" }
    }
}
