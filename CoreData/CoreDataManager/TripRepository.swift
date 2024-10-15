import CoreData
import Combine
import UIKit

class TripRepository {
    // MARK: - Singleton Instance
    static let shared = TripRepository()
    
    // CoreData managed object context
    private let context: NSManagedObjectContext
    
    // Combine Publisher for settled trips
    private var settledTripsSubject = CurrentValueSubject<[Trip], Never>([])

    // Dependency injection to pass the managed object context
    private init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        loadSettledTrips()  // Load settled trips when the repository is initialized
    }
    
    // MARK: - Combine Publisher

    var settledTripsPublisher: AnyPublisher<[Trip], Never> {
        settledTripsSubject.eraseToAnyPublisher()  // Expose as read-only publisher
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
            let trips = try context.fetch(fetchRequest)
            settledTripsSubject.send(trips)  // Publish changes
            print("Fetch settled trips from CoreData")
            return trips
        } catch {
            print("Failed to fetch settled trips: \(error)")
            return []
        }
    }
    
    // Load settled trips initially
    private func loadSettledTrips() {
        _ = fetchSettledTrips()  // Load trips into the subject when initialized
    }
    
    
    // Fetch a specific trip by UUID
    func fetchTrip(by id: UUID) -> Trip? {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)  // Fetch by UUID
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch trip by id: \(error)")
            return nil
        }
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
    func deleteTrip(by id: UUID) {
        if let trip = fetchTrip(by: id) {
            context.delete(trip)
            saveContext()
        } else {
            print("Trip with id \(id) not found")
        }
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
    func fetchPeople(for tripId: UUID) -> [Person] {
        guard let trip = fetchTrip(by: tripId) else { return [] }
        return trip.peopleArray
    }
    
    // Fetch bills for a specific trip
    func fetchBills(for tripId: UUID) -> [Bill] {
        guard let trip = fetchTrip(by: tripId) else { return [] }
        return trip.billsArray
    }
}

// MARK: - Managing People

extension TripRepository {

    // Fetch a person by UUID
    func fetchPerson(by id: UUID) -> Person? {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)  // Fetch by UUID
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch person by id: \(error)")
            return nil
        }
    }

    // Add a person to a trip
    func addPerson(to tripId: UUID, name: String, balance: Double = 0.0) -> Person? {
        guard let trip = fetchTrip(by: tripId) else {
            print("Trip not found")
            return nil
        }
        
        let person = Person(context: context)
        person.id = UUID()  // Assign a unique UUID
        person.name = name
        person.balance = balance
        trip.addToPeople(person)
        saveContext()
        return person
    }

    // Remove a person from a trip by their UUID
    func removePerson(by personId: UUID, from tripId: UUID) -> Bool {
        guard let trip = fetchTrip(by: tripId),
              let person = fetchPerson(by: personId) else {
            print("Trip or Person not found")
            return false
        }

        // Check if the person is involved in any bill
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

    // Update a person by UUID
    func updatePerson(by id: UUID, name: String, balance: Double) {
        guard let person = fetchPerson(by: id) else {
            print("Person not found")
            return
        }
        person.name = name
        person.balance = balance
        saveContext()
    }
}

// MARK: - Managing Bills

extension TripRepository {

    // Update a bill's image by UUID
    func changeBillImage(billId: UUID, image: UIImage?) {
        guard let bill = fetchBill(by: billId) else {
            print("Bill not found")
            return
        }
        
        // Update image data
        if let image = image {
            bill.imageData = image.jpegData(compressionQuality: 0.8)
        } else {
            bill.imageData = nil
        }
        
        saveContext()
    }
    
    // Fetch a bill by UUID
    func fetchBill(by id: UUID) -> Bill? {
        let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)  // Fetch by UUID
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch bill by id: \(error)")
            return nil
        }
    }

    // Add a bill to a trip
    func addBill(to tripId: UUID, title: String, amount: Double, date: Date, payerId: UUID, involversIds: [UUID], image: UIImage?) -> Bill? {
        guard let trip = fetchTrip(by: tripId),
              let payer = fetchPerson(by: payerId),
              !involversIds.isEmpty else {
            print("Trip or Payer not found, or no involvers specified")
            return nil
        }

        let bill = Bill(context: context)
        bill.id = UUID()  // Assign a unique UUID
        bill.title = title
        bill.amount = amount
        bill.payer = payer
        bill.trip = trip
        bill.date = date

        // Handle image data
        if let image = image {
            bill.imageData = image.jpegData(compressionQuality: 0.8) // Adjust compression quality as needed
        }

        // Fetch involvers by their IDs and add them to the bill
        let involvers = involversIds.compactMap { fetchPerson(by: $0) }
        bill.addToInvolvers(NSSet(array: involvers))
        trip.addToBills(bill)
        saveContext()
        return bill
    }

    // Remove a bill by UUID
    func removeBill(by billId: UUID, from tripId: UUID) {
        guard let trip = fetchTrip(by: tripId),
              let bill = fetchBill(by: billId) else {
            print("Trip or Bill not found")
            return
        }

        trip.removeFromBills(bill)
        context.delete(bill)
        saveContext()
    }

    // Update a bill by UUID
    func updateBill(by billId: UUID, title: String, amount: Double, date: Date, payerId: UUID, involversIds: [UUID], image: UIImage?) {
        guard let bill = fetchBill(by: billId),
              let payer = fetchPerson(by: payerId) else {
            print("Bill or Payer not found")
            return
        }

        bill.title = title
        bill.amount = amount
        bill.date = date
        bill.payer = payer

        // Handle image data
        if let image = image {
            bill.imageData = image.jpegData(compressionQuality: 0.8)
        } else {
            bill.imageData = nil
        }

        bill.removeFromInvolvers(bill.involvers ?? NSSet())

        // Fetch involvers by their IDs and add them to the bill
        let involvers = involversIds.compactMap { fetchPerson(by: $0) }
        bill.addToInvolvers(NSSet(array: involvers))
        saveContext()
    }
}


// MARK: - Simplifying Transactions and Settling Trips

extension TripRepository {
    
    func simplifyTransactions(for tripId: UUID) -> [(fromId: UUID, toId: UUID, amount: Double)] {
        guard let trip = fetchTrip(by: tripId),
              let peopleSet = trip.people,
              let billsSet = trip.bills else {
            return []
        }
        
        let people = peopleSet.allObjects as? [Person] ?? []
        let bills = billsSet.allObjects as? [Bill] ?? []
        
        // Map Person to a unique index for processing
        let personToIndex = Dictionary(uniqueKeysWithValues: people.enumerated().map { ($1, $0) })
        
        // Initialize the SimplifyDebts class
        let simplifyDebts = SimplifyDebts(totalPeopleCount: people.count)
        
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
        
        // Convert the simplified transactions into readable format with UUIDs
        var simplifiedTransactions: [(fromId: UUID, toId: UUID, amount: Double)] = []
        for (key, amount) in simplifyDebts.transactions {
            let fromPerson = people[key.from] // Accessing Person by index
            let toPerson = people[key.to]     // Accessing Person by index
            let amountInDollars = Double(amount) / 100.0  // Convert cents back to dollars

            if amountInDollars > 0 {
                simplifiedTransactions.append((fromId: fromPerson.id, toId: toPerson.id, amount: amountInDollars))
            }
        }
        print(simplifiedTransactions)
        return simplifiedTransactions
    }

    // Settle a trip and mark it as settled
    func settleTrip(by tripId: UUID) {
        guard let trip = fetchTrip(by: tripId) else { return }
        
        // Call the simplification function to process the transactions
        let simplifiedTransactions = simplifyTransactions(for: trip.id)
        
        // Mark the trip as settled
        trip.settled = true
        saveContext()
        
        print("Settlements for Trip: \(trip.title ?? "")")
        // Update the settled trips publisher
        _ = fetchSettledTrips()
    }

}
