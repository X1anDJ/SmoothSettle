//
//  TripSelectionViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/12/3.
//
import UIKit
import Combine

protocol TripSelectionDelegate: AnyObject {
    func didSelectTrip(_ trip: Trip)
}

class TripSelectionViewController: UIViewController {
    
    private let tableView = UITableView()
    private var trips: [Trip] = []
    private var cancellables = Set<AnyCancellable>()
    let viewModel: MainViewModel
    weak var delegate: TripSelectionDelegate?
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupTableView()
        setupBindings()
        setupNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Set up the navigation bar
    private func setupNavigationBar() {
        navigationItem.title = "Select Trip"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddTrip))
    }

    // Set up the table view
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TripCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Bind to the view model
    private func setupBindings() {
        viewModel.$trips
            .receive(on: DispatchQueue.main)
            .sink { [weak self] trips in
                self?.trips = trips
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func didTapAddTrip() {
        let addTripVC = AddTripViewController()
        addTripVC.delegate = self
        addTripVC.modalPresentationStyle = .overCurrentContext
        present(addTripVC, animated: false)
    }
}

extension TripSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let trip = trips[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        cell.textLabel?.text = trip.title ?? "Unnamed Trip"
        cell.accessoryType = trip.id == viewModel.currentTripId ? .checkmark : .none
        return cell
    }
    
    // UITableViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrip = trips[indexPath.row]
        delegate?.didSelectTrip(selectedTrip)
        dismiss(animated: true)
    }
    
    // Enable swipe to delete
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Handle deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let tripToDelete = trips[indexPath.row]
            // Confirm deletion
            let alert = UIAlertController(title: "Delete Trip",
                                          message: "Are you sure you want to delete \"\(tripToDelete.title ?? "this trip")\"?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.viewModel.deleteTrip(by: tripToDelete.id)
            }))
            present(alert, animated: true)
        }
    }
}

extension TripSelectionViewController: AddTripViewControllerDelegate {
    func didAddTrip(title: String, people: [Person], date: Date) {
        viewModel.addNewTrip(title: title, people: people, date: date)
    }
}
