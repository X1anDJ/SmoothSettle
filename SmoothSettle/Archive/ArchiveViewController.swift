//  ArchiveViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/14.
//

import UIKit
import Combine

class ArchiveViewController: UIViewController {
    
    let archiveView = ArchiveView()
    let viewModel = ArchiveViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func loadView() {
        self.view = archiveView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe changes in settledTrips and update UI
        bindViewModel()
    }
    
    private func bindViewModel() {
        // Observe the settledTrips in the viewModel
        viewModel.$settledTrips
            .receive(on: DispatchQueue.main)  // Ensure updates happen on the main thread
            .sink { [weak self] _ in
                self?.populateCards()  // Reload cards when trips update
            }
            .store(in: &cancellables)
    }
    
    private func populateCards() {
        // Remove all existing cards if any
        archiveView.clearCards()
        
        let settledTripsCount = viewModel.settledTrips.count
        
        // Group trips by year
        let tripsByYear = viewModel.groupTripsByYear(viewModel.settledTrips)
        
        if tripsByYear.isEmpty {
            archiveView.showEmptyState(true)  // Show empty state if there are no trips
        } else {
            archiveView.showEmptyState(false)
            
            // Iterate over each year and its corresponding trips
            for (year, trips) in tripsByYear.sorted(by: { $0.key > $1.key }) {  // Sort by year, descending order
                // Add a year label to the ArchiveView
                archiveView.addYearLabel(year)
                
                // Add a card view for each trip in the current year
                for trip in trips {
                    let cardView = CardView()
                    cardView.translatesAutoresizingMaskIntoConstraints = false
                    cardView.configure(with: trip)
                    
                    // Handle card tap action
                    cardView.onCardTapped = { [weak self] in
                        self?.handleCardTap(for: trip)
                    }
                    
                    // Add the card to the ArchiveView
                    archiveView.addCardView(cardView)
                }
            }
        }
    }
    
    private func handleCardTap(for trip: Trip) {
        // Initialize ArchiveTripController
        let archiveTripController = ArchiveTripController()
        archiveTripController.trip = trip
        archiveTripController.tripRepository = viewModel.tripRepository // Pass the repository
        
        // Set the title
        archiveTripController.title = trip.title ?? "Trip Details"
        
        // Push onto the navigation stack
        navigationController?.pushViewController(archiveTripController, animated: true)
    }
}
