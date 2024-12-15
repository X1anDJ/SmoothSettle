import CoreData
import Combine
import UIKit

class TripRepository {
    // MARK: - Singleton Instance
    static let shared = TripRepository()
    
    // CoreData managed object context
    private let context: NSManagedObjectContext
    
    // Combine Publisher for archived trips
    private var archivedTripsSubject = CurrentValueSubject<[Trip], Never>([])

    // Dependency injection to pass the managed object context
    private init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        loadArchivedTrips()  // Load archived trips when the repository is initialized
    }
    
    // MARK: - Combine Publisher

    var archivedTripsPublisher: AnyPublisher<[Trip], Never> {
        archivedTripsSubject.eraseToAnyPublisher()  // Expose as read-only publisher
    }
    
    // Combine Publisher for unarchived trips
    private var unarchivedTripsSubject = CurrentValueSubject<[Trip], Never>([])

    // Public publisher for external subscription
    var unarchivedTripsPublisher: AnyPublisher<[Trip], Never> {
        unarchivedTripsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Managing Trips

    // Fetch all trips from CoreData
    func fetchAllTrips() -> [Trip] {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
//            // print("Failed to fetch trips: \(error)")
            return []
        }
    }
    
    // Fetch unarchived trips from CoreData
    func fetchUnarchivedTrips() -> [Trip] {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "archived == NO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.returnsObjectsAsFaults = false // Ensure objects are fully realized

        do {
            let trips = try context.fetch(fetchRequest)
            unarchivedTripsSubject.send(trips) // Publish changes
            return trips
        } catch {
            // print("Failed to fetch unarchived trips: \(error)")
            return []
        }
    }


    

    // Fetch archived trips from CoreData
    func fetchArchivedTrips() -> [Trip] {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "archived == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let trips = try context.fetch(fetchRequest)
            trips.forEach { trip in
                _ = trip.date  // Access the date property to force it to load
            }
            archivedTripsSubject.send(trips)  // Publish changes
            return trips
        } catch {
            // print("Failed to fetch archived trips: \(error)")
            return []
        }
    }


    
    // Load archived trips initially
    private func loadArchivedTrips() {
        _ = fetchArchivedTrips()  // Load trips into the subject when initialized
    }
    
    
    // Fetch a specific trip by UUID
    func fetchTrip(by id: UUID) -> Trip? {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)  // Fetch by UUID
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
//            // print("Failed to fetch trip by id: \(error)")
            return nil
        }
    }
    
    /// Create a new trip with title, people, date, and optional currency
    /// - Parameters:
    ///   - title: The title of the trip
    ///   - people: An array of `Person` objects involved in the trip
    ///   - date: The date of the trip
    ///   - currency: Optional currency code (e.g., "USD", "EUR"). If nil, defaults to user's locale currency
    /// - Returns: The newly created `Trip` object
    func createTrip(title: String, people: [Person], date: Date, currency: String? = nil) -> Trip {
        let trip = Trip(context: context)
        trip.id = UUID()
        trip.title = title
        trip.date = date
        trip.archived = false
        trip.settled = false
        
        // Set currency if provided, else default to user's locale currency
        if let currency = currency {
            trip.currency = currency
        } else {
            trip.currency = Locale.current.currencyCode
        }
        
        trip.addToPeople(NSSet(array: people))
        
        saveContext()
        
        return trip
    }

    
//    // Delete a trip
//    func deleteTrip(by id: UUID) {
//        if let trip = fetchTrip(by: id) {
//            context.delete(trip)
//            saveContext()
//        } else {
////            // print("Trip with id \(id) not found")
//        }
//    }
    
    // Unarchive a trip (move it back to current trips)
    func unarchiveTrip(by tripId: UUID) {
        guard let trip = fetchTrip(by: tripId) else {
       //     // print("Trip not found for tripId: \(tripId)")
            return
        }
        
        // Check if trip is already unarchived
        if !trip.archived {
   //         // print("Trip with tripId: \(tripId) is already unarchived.")
            return
        }
        
        // Mark the trip as unarchived
        trip.archived = false
        markTripAsNotSettled(tripId: tripId)
        
        // Remove transactions since they are no longer relevant
        if let transactions = trip.transactions as? Set<Transaction> {
            for transaction in transactions {
                context.delete(transaction)
            }
            trip.transactions = nil
        }
        
        // Save the context to persist changes
        do {
            try context.save()
       //     // print("Trip unarchived successfully for tripId: \(tripId)")
            
            // Update the unarchived trips publisher
            fetchUnarchivedTrips()
            // Update the archived trips publisher as well
            fetchArchivedTrips()
        } catch {
          //  // print("Failed to unarchive Trip with tripId: \(tripId): \(error)")
        }
    }
    
    // Delete a trip
    func deleteTrip(by id: UUID) {
        if let trip = fetchTrip(by: id) {
            // Delete related bills
            if let bills = trip.bills as? Set<Bill> {
                for bill in bills {
                    context.delete(bill)
                }
            }
            
            // Delete related transactions
            if let transactions = trip.transactions as? Set<Transaction> {
                for transaction in transactions {
                    context.delete(transaction)
                }
            }
            
            // Finally, delete the trip
            context.delete(trip)
            saveContext()
            
            // Update the archived trips publisher
            fetchArchivedTrips()
            fetchUnarchivedTrips()
        } else {
  //          // print("Trip with id \(id) not found")
        }
    }
    

    func fetchAmount(_ amount: Double, by tripID: UUID) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = fetchTrip(by: tripID)?.currency ?? Locale.current.currencyCode ?? "USD" // Fallback to USD
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    // Save any changes to CoreData
    func saveContext() {
        do {
            try context.save()
        } catch {
//            // print("Failed to save context: \(error)")
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
        let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trip.id == %@", tripId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            return try context.fetch(fetchRequest)
        } catch {
    //        // print("Failed to fetch bills for tripId \(tripId): \(error)")
            return []
        }
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
//            // print("Failed to fetch person by id: \(error)")
            return nil
        }
    }

    // Add a person to a trip
    func addPerson(to tripId: UUID, name: String, balance: Double = 0.0) -> Person? {
        guard let trip = fetchTrip(by: tripId) else {
//            // print("Trip not found")
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
//            // print("Trip or Person not found")
            return false
        }

   //     // print("Removing person \(person.name ?? "Unnamed") from trip \(trip.title ?? "Unnamed")")
        
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
//            // print("Person not found")
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
//            // print("Bill not found")
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
//            // print("Failed to fetch bill by id: \(error)")
            return nil
        }
    }

    // Add a bill to a trip
    func addBill(to tripId: UUID, title: String, amount: Double, date: Date, payerId: UUID, involversIds: [UUID], image: UIImage?) -> Bill? {
        guard let trip = fetchTrip(by: tripId),
              let payer = fetchPerson(by: payerId),
              !involversIds.isEmpty else {
//            // print("Trip or Payer not found, or no involvers specified")
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
//            // print("Trip or Bill not found")
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
//            // print("Bill or Payer not found")
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

extension TripRepository {
    // MARK: - Time Period Calculation

    /// Calculates the time period for a given trip based on its bills.
    /// - Parameter trip: The trip for which to calculate the time period.
    /// - Returns: A formatted string representing the time period, or nil if no bills are present.
    func getTimePeriod(for trip: Trip) -> String? {
        guard let bills = trip.bills as? Set<Bill>, !bills.isEmpty else {
            return nil
        }
        
        // Extract bill dates, ignoring nil dates
        let billDates = bills.compactMap { $0.date }
        
        guard let earliestDate = billDates.min(),
              let latestDate = billDates.max() else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let startDate = dateFormatter.string(from: earliestDate)
        let endDate = dateFormatter.string(from: latestDate)
        
        return "\(startDate) - \(endDate)"
    }
}

// MARK: - Simplifying Transactions and Settling Trips

extension TripRepository {
    
    // Simplify Transactions and Create Transaction Entities
    func simplifyTransactions(for tripId: UUID) -> [Transaction] {
  //      // print("Trip Repo 446")
        guard let trip = fetchTrip(by: tripId),
              let peopleSet = trip.people,
              let billsSet = trip.bills else {
  //          // print("Trip, People, or Bills not found for tripId: \(tripId)")
            return []
        }

        // Check if transactions already exist to prevent duplicates
        if let existingTransactions = trip.transactions, existingTransactions.count > 0 {
//            // print("Transactions already exist for tripId: \(tripId). Skipping creation.")
//            return existingTransactions.allObjects as? [Transaction] ?? []
            
            if let transactions = trip.transactions as? Set<Transaction> {
                for transaction in transactions {
                    context.delete(transaction)
                }
                trip.transactions = nil
            }
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
        let _ = simplifyDebts.runSimplifyAlgorithm()

        // Convert the simplified transactions into readable format with UUIDs and create Transaction entities
        var transactionEntities: [Transaction] = []
        let context = self.context

        for (key, amount) in simplifyDebts.transactions {
            let fromIndex = key.to
            let toIndex = key.from

            // Ensure indices are within bounds
            guard fromIndex < people.count, toIndex < people.count else {
                // print("Invalid indices in SimplifyDebts result: fromIndex=\(fromIndex), toIndex=\(toIndex)")
                continue
            }

            let fromPerson = people[fromIndex]
            let toPerson = people[toIndex]
            let amountInDollars = Double(amount) / 100.0  // Convert cents back to dollars

            if amountInDollars > 0 {
                // Create a new Transaction entity
                let transaction = Transaction(context: context)
                transaction.id = UUID()
                transaction.amount = amountInDollars
                transaction.settled = false
                transaction.fromPerson = fromPerson
                transaction.toPerson = toPerson
                transaction.trip = trip

                // Add to trip's transactions
                trip.addToTransactions(transaction)

                transactionEntities.append(transaction)
            }
        }

        // Save the context to persist Transaction entities
        do {
            try context.save()
            // print("Simplified Transactions saved successfully for trip name: \(String(describing: trip.title)),  tripId: \(tripId)")
        } catch {
            // print("Failed to save Transactions for tripId: \(tripId): \(error)")
        }

        return transactionEntities
    }

    // Archived a trip and mark it as archived
    func archiveTrip(by tripId: UUID) {
        guard let trip = fetchTrip(by: tripId) else {
            // print("Trip not found for tripId: \(tripId)")
            return
        }
        
        // Check if trip is already archived
        if trip.archived {
            // print("Trip with tripId: \(tripId) is already archived.")
            return
        }

        // Call the simplification function to process the transactions
        let simplifiedTransactions = simplifyTransactions(for: trip.id)

        // Mark the trip as archived
        trip.archived = true

        // Save the context to persist changes
        do {
            try context.save()
            // print("Trip archived successfully for tripId: \(tripId)")
        } catch {
            // print("Failed to archive Trip with tripId: \(tripId): \(error)")
        }

        // Update the archived trips publisher
        fetchArchivedTrips()
    }
    
    // Fetch all transactions for a trip
    func fetchAllTransactions(for tripId: UUID) -> [Transaction] {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trip.id == %@", tripId as CVarArg)
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let transactions = try context.fetch(fetchRequest)
            // print("Fetched \(transactions.count) transactions for tripId: \(tripId)")
            return transactions
        } catch {
            // print("Failed to fetch all transactions for tripId: \(tripId): \(error)")
            return []
        }
    }
    
    
    
    /// Marks a trip as settled if all its transactions are settled.
    /// - Parameter tripId: The UUID of the trip to mark as settled.
    func markTripAsSettled(tripId: UUID) {
        guard let trip = fetchTrip(by: tripId) else {
            // print("Trip not found for tripId: \(tripId)")
            return
        }
        
        // Check if trip is already settled
        if trip.settled {
            // print("Trip \(trip.title ?? "Unnamed") is already settled.")
            return
        }
        
        // Verify that all transactions are settled
        let transactions = fetchAllTransactions(for: tripId)
        let allSettled = transactions.allSatisfy { $0.settled }
        
        if allSettled {
            trip.settled = true
            saveContext()
            // print("Trip \(trip.title ?? "Unnamed") has been marked as settled.")
            
            // Notify subscribers about the update
            fetchArchivedTrips()
        } else {
            // print("Cannot mark Trip \(trip.title ?? "Unnamed") as settled because not all transactions are settled.")
        }
    }
    
    /// Marks a trip as not settled if all its transactions are settled.
    /// - Parameter tripId: The UUID of the trip to mark as settled.
    func markTripAsNotSettled(tripId: UUID) {
        guard let trip = fetchTrip(by: tripId) else {
            // print("Trip not found for tripId: \(tripId)")
            return
        }
        
        trip.settled = false
        saveContext()
        fetchArchivedTrips()

    }
}




extension TripRepository {
    // Method to create mock data for testing with more country leaders, trips, and entertaining bills
    func createMockData() {

//        CoreDataManager.shared.resetPersistentStore()
        let userDefaults = UserDefaults.standard
        let mockDataKey = "hasCreatedMockData"
//        userDefaults.set(false, forKey: mockDataKey)


        // Check if mock data has already been created
        if userDefaults.bool(forKey: mockDataKey) {
            print("Userdefaults has created, mock data already exists.")
            return
        }
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        // Create People (Country Leaders)
        let person1 = Person(context: context)
        person1.id = UUID()
        person1.name = "Andreas Gursky"
        person1.balance = 0.0
        
        let person2 = Person(context: context)
        person2.id = UUID()
        person2.name = "Hilla Becher"
        person2.balance = 0.0
        
        let person3 = Person(context: context)
        person3.id = UUID()
        person3.name = "Bernd Becher"
        person3.balance = 0.0
        
        let person4 = Person(context: context)
        person4.id = UUID()
        person4.name = "Stephen Shore"
        person4.balance = 0.0
        
        let person5 = Person(context: context)
        person5.id = UUID()
        person5.name = "William Eggleston"
        person5.balance = 0.0
        
        let person6 = Person(context: context)
        person6.id = UUID()
        person6.name = "Alec Soth"
        person6.balance = 0.0
        
        let person7 = Person(context: context)
        person7.id = UUID()
        person7.name = "Mark Rothko"
        person7.balance = 0.0
        
        let person8 = Person(context: context)
        person8.id = UUID()
        person8.name = "Piet Mondrian"
        person8.balance = 0.0
        
        let person9 = Person(context: context)
        person9.id = UUID()
        person9.name = "Optimus Prime"
        person9.balance = 0.0
        
        let person10 = Person(context: context)
        person10.id = UUID()
        person10.name = "Jackson Pollock"
        person10.balance = 0.0
        
        let person11 = Person(context: context)
        person11.id = UUID()
        person11.name = "Andrei Tarkovsky"
        person11.balance = 0.0
        
        let person12 = Person(context: context)
        person12.id = UUID()
        person12.name = "Henri Matisse"
        person12.balance = 0.0
        
        let person13 = Person(context: context)
        person13.id = UUID()
        person13.name = "Edgar Degas"
        person13.balance = 0.0
        

        // Mock trip #1: Archived Trip (Hawaii Surfing Retreat)
        let trip1 = createTrip(title: "Midnight in Paris (sample)", people: [person1, person2, person3, person4, person5, person6, person7], date: Date().addingTimeInterval(-86400 * 2)) // 10 days ago
        addBill(to: trip1.id, title: "Hotel Le Meurice", amount: 3250.00, date: Date().addingTimeInterval(-86400 * 9), payerId: person1.id, involversIds: [person2.id, person4.id, person5.id, person7.id], image: nil)
        addBill(to: trip1.id, title: "Le Pre Catlan", amount: 2200.00, date: Date().addingTimeInterval(-86400 * 8), payerId: person3.id, involversIds: [person1.id, person3.id, person6.id, person7.id], image: nil)
        addBill(to: trip1.id, title: "LECLAIREUR", amount: 4000.00, date: Date().addingTimeInterval(-86400 * 7), payerId: person6.id, involversIds: [person2.id, person3.id, person4.id, person5.id, person6.id, person7.id], image: nil)
        addBill(to: trip1.id, title: "Hotel Le Bristol", amount: 7140.00, date: Date().addingTimeInterval(-86400 * 6), payerId: person2.id, involversIds: [person1.id, person2.id, person3.id, person4.id, person5.id, person6.id, person7.id], image: nil)
        addBill(to: trip1.id, title: "MUSÉE DE L'ORANGERIE", amount: 1370.00, date: Date().addingTimeInterval(-86400 * 5), payerId: person4.id, involversIds: [person3.id, person4.id, person5.id, person6.id], image: nil)
        addBill(to: trip1.id, title: "Faubourg St Honoré", amount: 3200.00, date: Date().addingTimeInterval(-86400 * 1), payerId: person5.id, involversIds: [person1.id, person2.id], image: nil)
        addBill(to: trip1.id, title: "Maxim’s", amount: 4800.00, date: Date().addingTimeInterval(-86400 * 2), payerId: person5.id, involversIds: [person1.id, person2.id, person3.id, person5.id], image: nil)

        // Mock trip #6: Archived Trip (Russia Winter Festival)
        let trip6 = createTrip(title: "Stranger in Moscow (sample)", people: [person8, person9, person10, person11, person12, person13], date: Date().addingTimeInterval(-86400 * 90)); // 90 days ago
        addBill(to: trip6.id, title: "Vodka Bath", amount: 200.00, date: Date().addingTimeInterval(-86400 * 89), payerId: person12.id, involversIds: [person8.id, person10.id], image: nil);
        addBill(to: trip6.id, title: "Bear Petting", amount: 150.00, date: Date().addingTimeInterval(-86400 * 88), payerId: person13.id, involversIds: [person8.id, person10.id], image: nil);
        addBill(to: trip6.id, title: "Another Vodka Bath", amount: 300, date: Date().addingTimeInterval(-86400 * 85), payerId: person9.id, involversIds: [person9.id, person11.id, person10.id] , image: nil);
        addBill(to: trip6.id, title: "Corn Feast", amount: 420, date: Date().addingTimeInterval(-86400 * 65), payerId: person10.id, involversIds: [person8.id, person9.id, person11.id, person10.id] , image: nil);
        addBill(to: trip6.id, title: "Ice Skating", amount: 250.00, date: Date().addingTimeInterval(-86400 * 64), payerId: person12.id, involversIds: [person8.id, person9.id, person11.id, person12.id, person10.id], image: nil);
        addBill(to: trip6.id, title: "Adult Doll Workshop", amount: 100.00, date: Date().addingTimeInterval(-86400 * 63), payerId: person11.id, involversIds: [person11.id, person9.id], image: nil);
        addBill(to: trip6.id, title: "Borscht Tasting", amount: 80.00, date: Date().addingTimeInterval(-86400 * 62), payerId: person10.id, involversIds: [person8.id, person10.id], image: nil);
        addBill(to: trip6.id, title: "Ballet Class", amount: 500.00, date: Date().addingTimeInterval(-86400 * 60), payerId: person8.id, involversIds: [person11.id, person12.id, person13.id, person10.id], image: nil);
        addBill(to: trip6.id, title: "Vodka Shower", amount: 450.00, date: Date().addingTimeInterval(-86400 * 59), payerId: person11.id, involversIds: [person8.id, person9.id, person11.id, person12.id], image: nil);
        addBill(to: trip6.id, title: "Caviar Sampling", amount: 300.00, date: Date().addingTimeInterval(-86400 * 58), payerId: person11.id, involversIds: [person8.id, person9.id, person10.id], image: nil);

        addBill(to: trip6.id, title: "Stolen", amount: 40.00, date: Date().addingTimeInterval(-86400 * 56), payerId: person11.id, involversIds: [person13.id, person12.id, person11.id], image: nil);



        archiveTrip(by: trip6.id)

        // Save the context to store the mock data
        saveContext()
        
        userDefaults.set(true, forKey: mockDataKey)
        // print("Mock data created with \(fetchAllTrips().count) trips.")
    }

}

