//
//  TripRepository.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import CoreData

class TripRepository {
    
    // CoreData managed object context
    private let context: NSManagedObjectContext
    
    // Dependency injection to pass the managed object context, with a default to CoreDataManager's context
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // MARK: - Managing Trips

    
    // Fetch all trips from CoreData
    func fetchAllTrips() -> [Trip] {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch trips: \(error)")
            return []
        }
    }
    
    // Fetch a specific trip by ID
    func fetchTrip(by id: NSManagedObjectID) -> Trip? {
        return context.object(with: id) as? Trip
    }
    
    // Create a new trip with title, people, and date
    func createTrip(title: String, people: [Person], date: Date) -> Trip {
        let trip = Trip(context: context)
        trip.title = title
        trip.date = date
        trip.settled = false
        
        // Add people to the trip
        trip.addToPeople(NSSet(array: people))
        
        saveContext()
        return trip
    }
    
    // Delete a trip
    func deleteTrip(_ trip: Trip) {
        context.delete(trip)
        saveContext()
    }
    
    // Save any changes to CoreData
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Fetch Relationships
    
    // Fetch people for a specific trip
    func fetchPeople(for trip: Trip) -> [Person] {
        return trip.peopleArray
    }
    
    // Fetch bills for a specific trip
    func fetchBills(for trip: Trip) -> [Bill] {
        return trip.billsArray
    }
}

// MARK: - Managing People

extension TripRepository {

    // Add a person to a trip
    func addPerson(to trip: Trip, name: String, balance: Double = 0.0) -> Person {
        let person = Person(context: context)
        person.name = name
        person.balance = balance
        trip.addToPeople(person)
        saveContext()
        return person
    }

    // Remove a person from a trip
    func removePerson(_ person: Person, from trip: Trip) {
        trip.removeFromPeople(person)
        context.delete(person)
        saveContext()
    }
    
    // Update a person
    func updatePerson(_ person: Person, name: String, balance: Double) {
        person.name = name
        person.balance = balance
        saveContext()
    }
}

// MARK: - Managing Bills

extension TripRepository {
    
    // Add a bill to a trip
    func addBill(to trip: Trip, title: String, amount: Double, date: Date, payer: Person, involvers: [Person]) -> Bill {
        let bill = Bill(context: context)
        bill.title = title
        bill.amount = amount
        bill.payer = payer
        bill.trip = trip
        bill.date = date
        bill.addToInvolvers(NSSet(array: involvers))
        trip.addToBills(bill)
        saveContext()
        return bill
    }

    // Remove a bill from a trip
    func removeBill(_ bill: Bill, from trip: Trip) {
        trip.removeFromBills(bill)
        context.delete(bill)
        saveContext()
    }
    
    // Update a bill
    func updateBill(_ bill: Bill, title: String, amount: Double, payer: Person, involvers: [Person]) {
        bill.title = title
        bill.amount = amount
        bill.payer = payer
        bill.removeFromInvolvers(bill.involvers ?? NSSet())
        bill.addToInvolvers(NSSet(array: involvers))
        saveContext()
    }
}
