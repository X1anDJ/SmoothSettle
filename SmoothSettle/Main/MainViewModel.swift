//
//  MainViewModel.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/22.
//
import Foundation
import Combine
import CoreData
import UIKit

class MainViewModel: ObservableObject {
    
    // MARK: - Published properties for UI Binding
    @Published var trips: [Trip] = []             // All available trips
    @Published var currentTripId: UUID?           // Currently selected trip's UUID
    @Published var people: [Person] = []          // People involved in the current trip
    @Published var bills: [Bill] = []             // Bills related to the current trip
    
    // Repository to manage CoreData operations
    let tripRepository: TripRepository
    
    // Combine cancellables set
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - Initializer with Dependency Injection
    init(tripRepository: TripRepository = TripRepository.shared) {
        self.tripRepository = tripRepository
        //loadAllUnarchivedTrips() // Load trips on initialization
        
        bindToRepository()
    }
    
    
    // MARK: - Bind to Repository
    private func bindToRepository() {
        tripRepository.unarchivedTripsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] trips in
                self?.trips = trips
                self?.handleTripsUpdate()
            }
            .store(in: &cancellables)
    }
    
    private func handleTripsUpdate() {
        if let currentTripId = currentTripId, trips.contains(where: { $0.id == currentTripId }) {
            // Current trip is still valid, do nothing
        } else if let firstTrip = trips.first {
            selectTrip(by: firstTrip.id)
        } else {
            // No trips available
            currentTripId = nil
            people = []
            bills = []
        }
    }
    
    
    
    // MARK: - Methods to Load Data
    
    
    // Load all unarchived trips from the repository
    func loadAllUnarchivedTrips() {
        trips = tripRepository.fetchUnarchivedTrips()
        // Sort it here, fix later
        if let firstTrip = trips.first {
            selectTrip(by: firstTrip.id) // Set the first trip as the default selected trip using UUID
        }
    }
    
    // Select a trip by its UUID, fetch its related data (people and bills)
    func selectTrip(by tripId: UUID) {
        currentTripId = tripId
        if tripRepository.fetchTrip(by: tripId) != nil {
            people = tripRepository.fetchPeople(for: tripId) // Use UUID to fetch people
            bills = tripRepository.fetchBills(for: tripId)   // Use UUID to fetch bills
        }
    }
    
    // Add a new trip with title, people, and date
    func addNewTrip(title: String, people: [Person], date: Date, currency: String) {
        let newTrip = tripRepository.createTrip(title: title, people: people, date: date, currency: currency)
        trips.append(newTrip)
        selectTrip(by: newTrip.id) // Automatically select the new trip using UUID
    }
    
    func deleteTrip(by tripId: UUID) {
        tripRepository.deleteTrip(by: tripId)
        // No need to manually remove the trip from the array; the Combine publisher will handle it.
        
        //        // Check if the deleted trip was the current trip
        //        if currentTripId == tripId {
        //            if let firstTrip = trips.first {
        //                selectTrip(by: firstTrip.id)
        //            } else {
        //                // No trips left; reset state
        //                currentTripId = nil
        //                people = []
        //                bills = []
        //            }
        //        }
    }
    
    
    // Add a new person to the current trip
    func addPersonToCurrentTrip(name: String) {
        guard let currentTripId = currentTripId else { return }
        if let newPerson = tripRepository.addPerson(to: currentTripId, name: name) {
            people.append(newPerson)
        }
    }
    
    // Add a new bill to the current trip
    func addBillToCurrentTrip(title: String, amount: Double, date: Date, payerId: UUID, involverIds: [UUID], image: UIImage?) {
        guard let currentTripId = currentTripId else { return }
        if let _ = tripRepository.addBill(to: currentTripId, title: title, amount: amount, date: date, payerId: payerId, involversIds: involverIds, image: image) {
            // Re-fetch the bills from the repository to ensure they are sorted correctly
            bills = tripRepository.fetchBills(for: currentTripId)
        }
    }
    
    
    func deleteBill(by billId: UUID) {
        guard let currentTripId = currentTripId else { return }
        
        // Call the repository method to delete the bill
        tripRepository.removeBill(by: billId, from: currentTripId)
        
        // Remove the bill from the local array
        bills = tripRepository.fetchBills(for: currentTripId)
    }
    
    // Simplify the current trip
    func simplifyCurrentTrip() {
        guard let currentTripId = currentTripId else { return }
        
        tripRepository.simplifyTransactions(for: currentTripId)
    }
    
    // Update the current trip (e.g., if it's archived)
    func updateTripArchivedStatus(isArchived: Bool) {
        guard let currentTripId = currentTripId, let trip = tripRepository.fetchTrip(by: currentTripId) else { return }
        trip.archived = isArchived
        tripRepository.saveContext() // Persist changes
    }
    
    // Archive the current trip
    func archiveCurrentTrip() {
        guard let currentTripId = currentTripId else {
            // print("No current trip selected.")
            return
        }
        
        // Archive the trip using the repository
        tripRepository.archiveTrip(by: currentTripId)
        
        // Reset the state before reloading the trips
        resetState()
        
        // Reload unarchived trips after settling the current trip
        loadAllUnarchivedTrips()
    }
    
    // Function to reset state
    private func resetState() {
        currentTripId = nil
        people = []
        bills = []
        trips = []
    }
    
    // Request to remove a person from the current trip by UUID
    func requestToRemovePerson(by personId: UUID) -> Bool {
        guard let currentTripId = currentTripId else { return false }
        
        // Call the repository method to remove the person using their UUID
        let wasRemoved = tripRepository.removePerson(by: personId, from: currentTripId)
        
        // If the person was removed, reload the people array
        if wasRemoved {
            people = tripRepository.fetchPeople(for: currentTripId) // Reload people array using UUID
        }
        
        return wasRemoved
    }
    
    func getAmount(for amount: Double) -> String {
        tripRepository.fetchAmount(amount, by: currentTripId ?? UUID())
    }
}
