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
                print("Settle trip count: \(trips.count)")
            }
            .store(in: &cancellables)
    }
}
