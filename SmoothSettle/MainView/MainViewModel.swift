//
//  MainViewModel.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/22.
//

import Foundation
import Combine
import CoreData

class MainViewModel: ObservableObject {
    
    // MARK: - Published properties for UI Binding
    @Published var trips: [Trip] = []             // All available trips
    @Published var currentTrip: Trip?             // Currently selected trip
    @Published var people: [Person] = []          // People involved in the current trip
    @Published var bills: [Bill] = []             // Bills related to the current trip
    
    // Repository to manage CoreData operations
    private let tripRepository: TripRepository
    
    // MARK: - Initializer with Dependency Injection
    init(tripRepository: TripRepository = TripRepository()) {
        self.tripRepository = tripRepository
        loadAllTrips() // Load trips on initialization
    }
    
    // MARK: - Methods to Load Data
    
    // Load all trips from the repository
    func loadAllTrips() {
        trips = tripRepository.fetchAllTrips()
        print("Trip count: \(trips.count)")
        if let firstTrip = trips.first {
            selectTrip(firstTrip) // Set the first trip as the default selected trip
        }
    }
    
    // Select a trip, fetch its related data (people and bills)
    func selectTrip(_ trip: Trip) {
        currentTrip = trip
        people = tripRepository.fetchPeople(for: trip)
        bills = tripRepository.fetchBills(for: trip)
    }
    
    // Add a new trip with title, people, and date
    func addNewTrip(title: String, people: [Person], date: Date) {
        let newTrip = tripRepository.createTrip(title: title, people: people, date: date)
        trips.append(newTrip)
        selectTrip(newTrip) // Automatically select the new trip
    }
    
    // Delete a trip
    func deleteTrip(_ trip: Trip) {
        tripRepository.deleteTrip(trip)
        trips.removeAll { $0 == trip }
        if let firstTrip = trips.first {
            selectTrip(firstTrip) // Select the next available trip
        } else {
            currentTrip = nil
            people = []
            bills = []
        }
    }
    
    // Add a new person to the current trip
    func addPersonToCurrentTrip(name: String) {
        guard let currentTrip = currentTrip else { return }
        let newPerson = tripRepository.addPerson(to: currentTrip, name: name)
        people.append(newPerson)
    }
    
    // Add a new bill to the current trip
    func addBillToCurrentTrip(title: String, amount: Double, date: Date, payer: Person, involvers: [Person]) {
        guard let currentTrip = currentTrip else { return }
        let newBill = tripRepository.addBill(to: currentTrip, title: title, amount: amount, date: date, payer: payer, involvers: involvers)
        bills.append(newBill)
    }
    
    // Update the current trip (e.g., if it's settled)
    func updateTripSettledStatus(isSettled: Bool) {
        guard let currentTrip = currentTrip else { return }
        currentTrip.settled = isSettled
        tripRepository.saveContext() // Persist changes
    }
    
    func requestToRemovePerson(_ person: Person) -> Bool {
        guard let currentTrip = currentTrip else { return false }
        
        // Call the repository method to remove the person
        let wasRemoved = tripRepository.removePerson(person, from: currentTrip)
        
        // If the person was removed, reload the people array
        if wasRemoved {
            people = tripRepository.fetchPeople(for: currentTrip) // Reload people array
        }
        
        return wasRemoved
    }

}
