//
//  MainViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import UIKit
import Combine

class MainViewController: UIViewController {

    var viewModel = MainViewModel()
    var cancellables = Set<AnyCancellable>()
    
    var mainView: MainView {
        return self.view as! MainView
    }
    
    override func loadView() {
        self.view = MainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        viewModel.loadAllUnsettledTrips()
        
        // Add target for cardRightArrowButton here
        mainView.cardRightArrowButton.addTarget(self, action: #selector(didTapCardRightArrowButton), for: .touchUpInside)
        mainView.cardHeaderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCardRightArrowButton)))
        
        // Set up delegates and data sources
        mainView.peopleSliderView.delegate = self
        mainView.peopleSliderView.allowSelection = false
        
        mainView.customTableView.register(BillTableViewCell.self, forCellReuseIdentifier: "BillCell")
        mainView.customTableView.delegate = self
        mainView.customTableView.dataSource = self
        
        // Set up target-actions for buttons
        mainView.userButton.addTarget(self, action: #selector(didTapUserButton), for: .touchUpInside)
        mainView.settleButton.addTarget(self, action: #selector(didTapSettle), for: .touchUpInside)
        mainView.addBillButton.addTarget(self, action: #selector(didTapAddBill), for: .touchUpInside)
        
        setupTripDropdownMenu()
    }
    
    
    // Set up bindings between the view model and the UI
    func setupBindings() {
        // Observe current trip changes
        viewModel.$currentTripId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tripId in
                if let tripId = tripId, let trip = self?.viewModel.tripRepository.fetchTrip(by: tripId) {
                    self?.updateCurrentTripUI(with: trip)
                    self?.updatePeopleSlider(with: trip.peopleArray)
                    self?.mainView.peopleSliderView.tripId = tripId
                    self?.updateUIElements(isEnabled: true)
                } else {
                    self?.updateUIElements(isEnabled: false)
//                    print("updateUIElements(isEnabled: false)")
                }
            }
            .store(in: &cancellables)
        
        // Observe trips changes and update the dropdown menu
        viewModel.$trips
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setupTripDropdownMenu() // Rebuild the UIMenu whenever trips are updated
            }
            .store(in: &cancellables)
        
        // Observe current people changes
        viewModel.$people
            .receive(on: DispatchQueue.main)
            .sink { [weak self] people in
                self?.updatePeopleSlider(with: people)
                
            }
            .store(in: &cancellables)
        
        // Observe changes in the list of bills and reload the table view
        viewModel.$bills
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.mainView.customTableView.reloadData()
                self?.updateTotalAmount(with: self?.viewModel.bills)
            }
            .store(in: &cancellables)
    }

    func updateCurrentTripUI(with trip: Trip?) {
//        if let trip = trip {
//            let currentTripText = NSMutableAttributedString(string: trip.title ?? "Unnamed Trip")
//            let arrowIconAttachment = NSTextAttachment()
//            arrowIconAttachment.image = UIImage(systemName: "chevron.down")
//            currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
//            mainView.currentTripButton.setAttributedTitle(currentTripText, for: .normal)
//        } else {
//            let currentTripText = NSMutableAttributedString(string: "Add a Trip")
//            let arrowIconAttachment = NSTextAttachment()
//            arrowIconAttachment.image = UIImage(systemName: "chevron.down")
//            currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
//            mainView.currentTripButton.setAttributedTitle(currentTripText, for: .normal)
//        }
        
        let currentTripText = NSMutableAttributedString(string: trip?.title ?? "Add a Trip")
        let arrowIconAttachment = NSTextAttachment()
        arrowIconAttachment.image = UIImage(systemName: "chevron.down")
        currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
        mainView.currentTripButton.setAttributedTitle(currentTripText, for: .normal)
    }
    
    func updatePeopleSlider(with people: [Person]) {
        mainView.peopleSliderView.people = people
    }
    
    func updateTotalAmount(with bills: [Bill]?) {
        let totalAmount = bills?.reduce(0, { $0 + $1.amount }) ?? 0
        mainView.totalAmountLabel.text = "$\(String(format: "%.2f", totalAmount))"
    }
    
    func setupTripDropdownMenu() {
        // Create actions for each existing trip
        let tripMenuActions = viewModel.trips.map { trip in
            UIAction(title: trip.title ?? "Unnamed Trip", image: nil) { [weak self] _ in
                self?.viewModel.selectTrip(by: trip.id) // Use UUID to select the trip
            }
        }
        
        // Add a special action for adding a new trip
        let addTripAction = UIAction(title: "Add a Trip", image: UIImage(systemName: "plus")) { [weak self] _ in
            self?.didTapAddTrip() // Call the function to add a new trip
        }
        
        // Create the UIMenu and append the "Add Trip" action as the last item
        let tripMenu = UIMenu(title: "Switch Trip", children: tripMenuActions + [addTripAction])
        
        // Assign the menu to the currentTripButton
        mainView.currentTripButton.menu = tripMenu
        mainView.currentTripButton.showsMenuAsPrimaryAction = true
    }

    @objc func didTapCardRightArrowButton() {
        let billsViewController = BillsViewController(viewModel: viewModel)
        navigationController?.pushViewController(billsViewController, animated: true)
    }

    
    @objc func didTapUserButton() {
        let userVC = UserViewController()
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            userVC.logoutDelegate = delegate
        }
        let navigationController = UINavigationController(rootViewController: userVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    @objc func didTapAddTrip() {
        let addTripVC = AddTripViewController()
        addTripVC.delegate = self
        addTripVC.modalPresentationStyle = .overCurrentContext
        addTripVC.view.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height * 0.5)
        present(addTripVC, animated: false)
    }
    
    @objc func didTapSettle() {
        let settleVC = SettleViewController()
        settleVC.viewModel = self.viewModel
        settleVC.modalPresentationStyle = .overFullScreen
        
        // Subscribe to the settleSubject and call reload on settlement
        settleVC.settleSubject
            .sink { [weak self] in
                self?.reloadMainViewController() // Call reload method when settled
            }
            .store(in: &cancellables)
        
        present(settleVC, animated: true, completion: nil)
    }


    func reloadMainViewController() {
        // Reload the trip data
        viewModel.loadAllUnsettledTrips()
        
        // Fetch and reload the current trip and its people
        if let currentTripId = viewModel.currentTripId, let currentTrip = viewModel.tripRepository.fetchTrip(by: currentTripId) {
            updateCurrentTripUI(with: currentTrip)
            updatePeopleSlider(with: currentTrip.peopleArray)
        } else {
            updateCurrentTripUI(with: nil)
            updatePeopleSlider(with: [])
        }

        // Reload the UI components
        mainView.customTableView.reloadData()
    }
    
    func updateUIElements(isEnabled: Bool) {
        let disabledAlpha: CGFloat = 0.3
        let enabledAlpha: CGFloat = 1.0

        // Update interactivity and appearance of UI elements
        mainView.peopleSliderView.isUserInteractionEnabled = isEnabled
        mainView.cardHeaderView.isUserInteractionEnabled = isEnabled
        mainView.cardRightArrowButton.isUserInteractionEnabled = isEnabled
        mainView.customTableView.isUserInteractionEnabled = isEnabled
        mainView.settleButton.isUserInteractionEnabled = isEnabled
        mainView.addBillButton.isUserInteractionEnabled = isEnabled

        // Change alpha to visually indicate disabled state
        mainView.peopleSliderView.alpha = isEnabled ? enabledAlpha : disabledAlpha
        mainView.shadowContainerView.alpha = isEnabled ? enabledAlpha : disabledAlpha
//        mainView.cardRightArrowButton.alpha = isEnabled ? enabledAlpha : disabledAlpha
//        mainView.customTableView.alpha = isEnabled ? enabledAlpha : disabledAlpha
        mainView.settleButton.alpha = isEnabled ? enabledAlpha : disabledAlpha
        mainView.addBillButton.alpha = isEnabled ? enabledAlpha : disabledAlpha
        
    }

    @objc func didTapAddBill() {
        let addBillVC = AddBillViewController()
        
        // Pass the current trip ID and people to the AddBillViewController
        if let currentTripId = viewModel.currentTripId {
            addBillVC.currentTripId = currentTripId // Pass the trip ID instead of the whole Trip object
            addBillVC.people = viewModel.people     // You can still pass the people objects if needed
        }
        
        addBillVC.delegate = self // Set the delegate to handle callbacks
        
        let navController = UINavigationController(rootViewController: addBillVC)
        
        // Configure the sheet presentation
        if #available(iOS 15.0, *) {
            navController.modalPresentationStyle = .pageSheet
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        } else {
            navController.modalPresentationStyle = .formSheet
        }
        
        present(navController, animated: true, completion: nil)
    }

}

// Delegate for PeopleSliderView
extension MainViewController: PeopleSliderViewDelegate, PeopleCellDelegate {
    func didRequestRemovePerson(_ personId: UUID?) {
        // Check if personId is valid, do nothing if it's nil
        guard let personId = personId else {
            print("Person ID is nil, no action taken.")
            return
        }
        
        // Use UUID to remove the person
        if !viewModel.requestToRemovePerson(by: personId) {
            print(" involved in bills")
            showAlert(title:"Can't remove", message: "Involved in some bills")
        } else {
            print("Person removed successfully")
            showAlert(title: "Person removed", message: nil)
        }
        mainView.peopleSliderView.hideAllRemoveButtons()
    }

    func showAlert(title: String, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccessAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func didSelectPerson(_ personId: UUID?, for tripId: UUID?, context: SliderContext) {
        // Check if personId exists, do nothing if it's nil
        guard let personId = personId else {
            print("Person ID is nil, no action taken.")
            return
        }
        
        // Add logic to handle person selection using personId
        print("Person selected with ID: \(personId) in trip \(tripId?.uuidString ?? "Unknown") with context: \(context)")
    }

    
    func didTapAddPerson(for tripId: UUID?) {
        guard tripId != nil else { return }
        
        // Show alert to add a person
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Add Person", message: "Enter the name of the person", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Person Name"
            }
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
                if let name = alert.textFields?.first?.text, name.isEmpty {
                    // Show another alert if the name is empty
                    let errorAlert = UIAlertController(title: "Invalid Input", message: "The name cannot be empty.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(errorAlert, animated: true)
                } else if let name = alert.textFields?.first?.text {
                    // Add person to the current trip using tripId
                    self?.viewModel.addPersonToCurrentTrip(name: name)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }
}

// UITableView Delegate and DataSource methods
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath) as? BillTableViewCell else {
            return UITableViewCell()
        }

        let bill = viewModel.bills[indexPath.row]
        
        // Configure the cell using actual data from the bill
        cell.configure(
            billTitle: bill.title ?? "Untitled Bill",
            date: formatDate(bill.date),
            amount: String(format: "%.2f", bill.amount),
            payerName: bill.payer?.name ?? "Unknown",
            involversCount: bill.involvers?.count ?? 0
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let billDetailVC = BillDetailViewController()
        let selectedBill = viewModel.bills[indexPath.row]
        let billDetailViewModel = BillDetailViewModel(tripRepository: viewModel.tripRepository, bill: selectedBill)
        billDetailVC.viewModel = billDetailViewModel
        navigationController?.pushViewController(billDetailVC, animated: true)

    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    // Handle the deletion when the user swipes and taps "Delete"
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bill = viewModel.bills[indexPath.row]
            viewModel.deleteBill(by: bill.id)
            
            // Remove the row from the table view with animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - AddTripViewControllerDelegate
extension MainViewController: AddTripViewControllerDelegate {
    func didAddTrip(title: String, people: [Person], date: Date) {
        // Pass full Person instances, not UUIDs
        viewModel.addNewTrip(title: title, people: people, date: date)
    }
}

// MARK: - AddBillViewControllerDelegate
extension MainViewController: AddBillViewControllerDelegate {
    func didAddBill(title: String, amount: Double, date: Date, payerId: UUID, involverIds: [UUID], image: UIImage?) {
        // Use UUID for the payer and involvers
        viewModel.addBillToCurrentTrip(title: title, amount: amount, date: date, payerId: payerId, involverIds: involverIds, image: image)
    }
    
//    func didAddBill(title: String, amount: Double, date: Date, payerId: UUID, involverIds: [UUID]) {
//        // Use UUID for the payer and involvers
//        viewModel.addBillToCurrentTrip(title: title, amount: amount, date: date, payerId: payerId, involverIds: involverIds)
//    }
}
