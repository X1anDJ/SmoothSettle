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
        if let navigationController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.clear

            // Apply the appearance to scrollEdgeAppearance and standardAppearance
            if #available(iOS 15.0, *) {
                navigationController.navigationBar.scrollEdgeAppearance = appearance
                navigationController.navigationBar.standardAppearance = appearance
            } else {
                // For iOS versions prior to 15.0
                navigationController.navigationBar.standardAppearance = appearance
            }
        }
        // Observe changes in archivedTrips and update UI
        bindViewModel()
    }
    
    private func bindViewModel() {
        // Observe the archivedTrips in the viewModel
        viewModel.$archivedTrips
            .receive(on: DispatchQueue.main)  // Ensure updates happen on the main thread
            .sink { [weak self] _ in
                self?.populateCards()  // Reload cards when trips update
            }
            .store(in: &cancellables)
    }
    
    private func populateCards() {
        // Remove all existing cards if any
        archiveView.clearCards()
        
        let archivedTripsCount = viewModel.archivedTrips.count
        
        // Group trips by year
        let tripsByYear = viewModel.groupTripsByYear(viewModel.archivedTrips)
        
        if tripsByYear.isEmpty {
            print("tripsByYear is empty")
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
                    
                    // Handle long press action
                    cardView.onLongPress = { [weak self] in
                        self?.handleCardLongPress(for: trip)
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
    
    private func handleCardLongPress(for trip: Trip) {
        // Present the UIMenu as an action sheet
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Move to Current Trip action
        let moveToCurrentTripAction = UIAlertAction(title: "Move to Current Trip", style: .default) { [weak self] _ in
            self?.moveTripToCurrent(trip)
        }
        
        // Delete Trip action
        let deleteTripAction = UIAlertAction(title: "Delete Trip", style: .destructive) { [weak self] _ in
            self?.deleteTrip(trip)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add actions to the alert controller
        alertController.addAction(moveToCurrentTripAction)
        alertController.addAction(deleteTripAction)
        alertController.addAction(cancelAction)
        
        // Set modal presentation style
        alertController.modalPresentationStyle = .overCurrentContext
        
        // Present the alert controller
        present(alertController, animated: true)
    }
    
    private func moveTripToCurrent(_ trip: Trip) {
        // Call the repository method to unarchive the trip
        viewModel.tripRepository.unarchiveTrip(by: trip.id)
        // Optionally, provide user feedback
        let alert = UIAlertController(title: "Trip Moved", message: "\(trip.title ?? "Trip") has been moved to current trips.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func deleteTrip(_ trip: Trip) {
        // Confirm deletion
        let confirmAlert = UIAlertController(title: "Delete Trip", message: "Are you sure you want to delete \(trip.title ?? "this trip")?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.tripRepository.deleteTrip(by: trip.id)
            // Optionally, provide user feedback
            let deletedAlert = UIAlertController(title: "Trip Deleted", message: "\(trip.title ?? "Trip") has been deleted.", preferredStyle: .alert)
            deletedAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(deletedAlert, animated: true)
        })
        present(confirmAlert, animated: true)
    }
}
