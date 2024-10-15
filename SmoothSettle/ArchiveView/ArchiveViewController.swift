//
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
        
        for trip in viewModel.settledTrips {
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
    
    private func handleCardTap(for trip: Trip) {
        // Handle navigation or actions when a card is tapped
        print("Tapped on trip: \(trip.title ?? "Unknown Title")")
    }
}
