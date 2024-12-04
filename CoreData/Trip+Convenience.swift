//
//  Trip+Convenience.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import Foundation
import CoreData

extension Trip {
    // Convenience method to return sorted bills as an array
    public var billsArray: [Bill] {
        let set = bills as? Set<Bill> ?? []
//        return set.sorted { $0.title ?? "" < $1.title ?? "" }
        return set.sorted {
            ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast)
        }
    }

    // Convenience method to return sorted people as an array
    public var peopleArray: [Person] {
        let set = people as? Set<Person> ?? []
        return set.sorted { $0.name ?? "" < $1.name ?? "" }
    }
}
