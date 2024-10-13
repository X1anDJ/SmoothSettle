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
    
    // Fetch unsettled trips from CoreData
    func fetchUnsettledTrips() -> [Trip] {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "settled == NO")
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch unsettled trips: \(error)")
            return []
        }
    }

    // Fetch settled trips from CoreData
    func fetchSettledTrips() -> [Trip] {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "settled == YES")
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch settled trips: \(error)")
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
        trip.id = UUID()  // Assign a unique UUID
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
        person.id = UUID()  // Assign a unique UUID
        person.name = name
        person.balance = balance
        trip.addToPeople(person)
        saveContext()
        return person
    }

    // Remove a person from a trip
    func removePerson(_ person: Person, from trip: Trip) -> Bool {
        // Check if the person is involved in any bill
        print("Trip repo checking if the person is involved in any bill")
        for bill in trip.billsArray {
            if bill.payer == person || bill.involversArray.contains(person) {
                // Person is involved in a bill, so cannot be removed
                return false
            }
        }
        
        // If the person is not involved in any bill, proceed with removal
        trip.removeFromPeople(person)
        context.delete(person)
        saveContext()
        
        return true
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
        bill.id = UUID()  // Assign a unique UUID
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

// MARK: - Simplifying Transactions and Settling Trips

extension TripRepository {
    
    func simplifyTransactions(for trip: Trip) -> [(from: String, to: String, amount: Double)] {
        guard let peopleSet = trip.people, let billsSet = trip.bills else {
            return []
        }
        
        let people = peopleSet.allObjects as? [Person] ?? []
        let bills = billsSet.allObjects as? [Bill] ?? []
        
        // Map Person to a unique index for processing
        let personToIndex = Dictionary(uniqueKeysWithValues: people.enumerated().map { ($1, $0) })
        
        // Initialize the SimplifyDebts class
        let simplifyDebts = SimplifyDebts()
        
        // Process each bill
        for bill in bills {
            guard let payer = bill.payer, let involversSet = bill.involvers else { continue }
            let involvers = involversSet.allObjects as? [Person] ?? []
            
            // Calculate share per person (assuming equal share)
            let share = Int64(bill.amount * 100) / Int64(involvers.count)  // Using cents to avoid floating point errors
            
            if let payerIndex = personToIndex[payer] {
                // Add transactions from the payer to each involver
                for involver in involvers {
                    if let involverIndex = personToIndex[involver], payer != involver {
                        simplifyDebts.addTransaction(from: payerIndex, to: involverIndex, amount: share)
                    }
                }
            }
        }
        
        // Run the simplification algorithm
        let result = simplifyDebts.runSimplifyAlgorithm()
        
        // Convert the simplified transactions into readable format
        var simplifiedTransactions: [(from: String, to: String, amount: Double)] = []
        for (key, amount) in simplifyDebts.transactions {
            let fromPerson = people[key.from] // Direct access without optional binding
            let toPerson = people[key.to]     // Direct access without optional binding
            let amountInDollars = Double(amount) / 100.0  // Convert cents back to dollars

            if amountInDollars > 0 {
                simplifiedTransactions.append((from: fromPerson.name ?? "Unknown", to: toPerson.name ?? "Unknown", amount: amountInDollars))
            }
        }
        
        return simplifiedTransactions
    }

    // Settle a trip and mark it as settled
    func settleTrip(_ trip: Trip) {
        // Call the simplification function to process the transactions
        let simplifiedTransactions = simplifyTransactions(for: trip)

        // Mark the trip as settled
        trip.settled = true
        saveContext()
    }
}
