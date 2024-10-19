//
//  ArchiveViewModel.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/14.
//
import Combine
import Foundation

class ArchiveViewModel {
    
    // MARK: - Properties
    private let tripRepository: TripRepository
    private var cancellables = Set<AnyCancellable>()
    
    // Published settled trips
    @Published var settledTrips: [Trip] = []
    
    // MARK: - Initialization
    init(tripRepository: TripRepository = TripRepository.shared) {
        self.tripRepository = tripRepository
        bindToRepository()
    }
    
    // MARK: - Bind to TripRepository
    private func bindToRepository() {
        // Subscribe to settledTripsPublisher and update settledTrips
        tripRepository.settledTripsPublisher
            .receive(on: DispatchQueue.main)  // Ensure updates happen on the main thread
            .sink { [weak self] trips in
                self?.settledTrips = trips
//                print("Settled trip count in ArchiveViewModel: \(trips.count)")
//                print("Their dates are: \(trips.map { $0.date })")
            }
            .store(in: &cancellables)
    }
    
    // Method to group trips by year
    func groupTripsByYear(_ trips: [Trip]) -> [Int: [Trip]] {
        var groupedTrips = [Int: [Trip]]()
        let calendar = Calendar.current
        
//        print("Grouping count: \(trips.count)")
        for trip in trips {
            if let tripDate = trip.date {
//                print("Trip with date: \(tripDate)")
                let year = calendar.component(.year, from: tripDate)
                if groupedTrips[year] == nil {
                    groupedTrips[year] = [trip]
                } else {
                    groupedTrips[year]?.append(trip)
                }
            } else {
//                print("Trip \(trip.title ?? "Unknown Title") has no date!")
            }
        }
//        
//        print("Grouped trips by year: \(groupedTrips.count)")
        return groupedTrips
    }


}
