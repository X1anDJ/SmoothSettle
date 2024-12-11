//
//  TripPopoverViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/12/3.
//
import UIKit
import Combine

protocol TripPopoverDelegate: AnyObject {
    func didSelectTrip(_ trip: Trip)
}

class TripPopoverViewController: UIViewController {
    
    private let tableView = UITableView()
    private let addTripButton = UIButton(type: .system)
    private var trips: [Trip] = []
    private var cancellables = Set<AnyCancellable>()
    let viewModel: MainViewModel
    weak var delegate: TripPopoverDelegate?
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViews()
        setupBindings()
        // Adjust preferredContentSize as needed
        preferredContentSize = CGSize(width: 250, height: 300) // Adjust height as needed
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Set up the views
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(addTripButton)
        view.backgroundColor = Colors.background1
        setupTableView()
        setupAddTripButton()
        setupConstraints()
    }

    // Set up the table view
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TripCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Colors.background1
    }

    // Set up the Add Trip button
    private func setupAddTripButton() {
        addTripButton.setTitle(String(localized: "add_a_trip"), for: .normal)
        addTripButton.titleLabel?.textColor = Colors.primaryDark
        addTripButton.setTitleColor(Colors.primaryDark, for: .normal)
        addTripButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        addTripButton.addTarget(self, action: #selector(didTapAddTrip), for: .touchUpInside)
        addTripButton.translatesAutoresizingMaskIntoConstraints = false
        addTripButton.backgroundColor = Colors.background1
        
        // Add shadow to the top of the button
        addTripButton.layer.masksToBounds = false
        addTripButton.layer.shadowColor = Colors.primaryDark.cgColor
        addTripButton.layer.shadowOpacity = 0.1
        addTripButton.layer.shadowOffset = CGSize(width: 0, height: -1) // Negative height to position shadow above
        addTripButton.layer.shadowRadius = 2
    }

    // Set up constraints
    private func setupConstraints() {
        // Constraints for addTripButton
        NSLayoutConstraint.activate([
            addTripButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addTripButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addTripButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            addTripButton.heightAnchor.constraint(equalToConstant: 44) // Standard button height
        ])
        
        // Constraints for tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addTripButton.topAnchor)
        ])
    }

    // Bind to the view model
    private func setupBindings() {
        viewModel.$trips
            .receive(on: DispatchQueue.main)
            .sink { [weak self] trips in
                self?.trips = trips
                self?.tableView.reloadData()
                self?.adjustPreferredContentSize()
            }
            .store(in: &cancellables)
    }

    // Adjust the preferred content size based on the content
    private func adjustPreferredContentSize() {
        // Calculate the required height
        let maxVisibleTrips = min(trips.count, 5) // Show up to 5 trips without scrolling
        let rowHeight: CGFloat = 44 // Standard table view cell height
        let totalHeight = CGFloat(maxVisibleTrips) * rowHeight + addTripButton.frame.height
        preferredContentSize = CGSize(width: 250, height: totalHeight)
    }
    
    @objc private func didTapAddTrip() {
        let addTripVC = AddTripViewController()
        addTripVC.delegate = self
        addTripVC.modalPresentationStyle = .formSheet
        present(addTripVC, animated: true)
    }
}

extension TripPopoverViewController: UITableViewDataSource, UITableViewDelegate {
    // UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let trip = trips[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        cell.imageView?.image = nil  // Remove any image from the left side
        cell.textLabel?.textAlignment = .left  // Ensure text is aligned to the left
        cell.textLabel?.text = trip.title ?? "Unnamed Trip"
        cell.accessoryView = nil
        cell.backgroundColor = Colors.background1
        // Set accessoryView with checkmark if it's the current trip
        if trip.id == viewModel.currentTripId {
            let checkmarkImage = UIImageView(image: UIImage(systemName: "checkmark"))
            checkmarkImage.tintColor = Colors.accentOrange
            cell.accessoryView = checkmarkImage
        }

        return cell
    }

    // UITableViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrip = trips[indexPath.row]
        delegate?.didSelectTrip(selectedTrip)
        dismiss(animated: true)
    }
    
    // Enable swipe to delete for trip cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Handle deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let tripToDelete = trips[indexPath.row]
            // Confirm deletion
            let message = String(localized: "delete_trip_message")
            let alert = UIAlertController(title: String(localized: "delete_trip"),
                                          message: "\(message) \"\(tripToDelete.title ?? "this trip")\"?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: String(localized: "close_button"), style: .cancel))
            alert.addAction(UIAlertAction(title: String(localized: "delete"), style: .destructive, handler: { [weak self] _ in
                self?.viewModel.deleteTrip(by: tripToDelete.id)
            }))
            present(alert, animated: true)
        }
    }
    
    // Add this method to remove the separator for the last cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Check if this is the last row in the table view
        if indexPath.row == trips.count - 1 {
            // Remove the separator for the last cell
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.width)
        } else {
            // Reset separatorInset to the default value
            cell.separatorInset = tableView.separatorInset
        }
    }
}

extension TripPopoverViewController: AddTripViewControllerDelegate {
    func didAddTrip(title: String, people: [Person], date: Date, currency: String) {
        viewModel.addNewTrip(title: title, people: people, date: date, currency: currency)
    }
}
