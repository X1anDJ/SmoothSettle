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
        viewModel.loadAllTrips()
        
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
//        mainView.addTripButton.addTarget(self, action: #selector(didTapAddTrip), for: .touchUpInside)
        
        
        mainView.settleButton.addTarget(self, action: #selector(didTapSettle), for: .touchUpInside)
        
        mainView.addBillButton.addTarget(self, action: #selector(didTapAddBill), for: .touchUpInside)
//        mainView.currentTripButton.addTarget(self, action: #selector(showTripDropdown), for: .touchUpInside)
        
        setupTripDropdownMenu()
    }
    
    
    // Set up bindings between the view model and the UI
    func setupBindings() {
        // Observe current trip changes
        viewModel.$currentTrip
            .receive(on: DispatchQueue.main)
            .sink { [weak self] trip in
                self?.updateCurrentTripUI(with: trip)
                self?.updatePeopleSlider(with: trip?.peopleArray ?? [])
                self?.mainView.peopleSliderView.trip = trip
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
            }
            .store(in: &cancellables)
    }
    


    func updateCurrentTripUI(with trip: Trip?) {
        if let trip = trip {
            let currentTripText = NSMutableAttributedString(string: trip.title ?? "Unnamed Trip")
            let arrowIconAttachment = NSTextAttachment()
            arrowIconAttachment.image = UIImage(systemName: "chevron.down")
            currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
            mainView.currentTripButton.setAttributedTitle(currentTripText, for: .normal)
        } else {
            mainView.currentTripButton.setAttributedTitle(NSAttributedString(string: "No Trip Selected"), for: .normal)
        }
    }
    
    func updatePeopleSlider(with people: [Person]) {
        mainView.peopleSliderView.people = people
    }
    
    func setupTripDropdownMenu() {
        // Create actions for each existing trip
        let tripMenuActions = viewModel.trips.map { trip in
            UIAction(title: trip.title ?? "Unnamed Trip", image: nil) { [weak self] _ in
                self?.viewModel.selectTrip(trip)
            }
        }
        
        // Add a special action for adding a new trip
        let addTripAction = UIAction(title: "Add Trip", image: UIImage(systemName: "plus")) { [weak self] _ in
            self?.didTapAddTrip() // Call the function to add a new trip
        }
        
        
        // Create the UIMenu and append the "Add Trip" action as the last item
        let tripMenu = UIMenu(title: "Switch Trip", children: tripMenuActions + [addTripAction])
        
        // Assign the menu to the currentTripButton
        mainView.currentTripButton.menu = tripMenu
        mainView.currentTripButton.showsMenuAsPrimaryAction = true
    }

    @objc func didTapCardRightArrowButton() {
        let billsViewController = BillsViewController()
        navigationController?.pushViewController(billsViewController, animated: true)
    }
    
    
    @objc func didTapUserButton() {
        let userVC = UserViewController()
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            userVC.logoutDelegate = delegate
        }
        let navigationController = UINavigationController(rootViewController: userVC)
        navigationController.modalPresentationStyle = .pageSheet
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
        let settleVC = SettleViewController() // Replace with your custom view controller
        settleVC.modalPresentationStyle = .pageSheet
        self.present(settleVC, animated: true, completion: nil)
    }

    @objc func didTapAddBill() {
        let addBillVC = AddBillViewController()
        addBillVC.currentTrip = viewModel.currentTrip
        addBillVC.people = viewModel.people
        addBillVC.delegate = self

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
    func didRequestRemovePerson(_ person: Person) {
        if !viewModel.requestToRemovePerson(person) {
            print("Failed to remove person because they are involved in bills")
        } else {
            print("Person removed successfully")
        }
        mainView.peopleSliderView.hideAllRemoveButtons()
    }
    
    func didSelectPerson(_ person: Person, for trip: Trip?, context: SliderContext) {
        // Add logic to handle person selection if needed
    }
    
    func didTapAddPerson(for trip: Trip?) {
        guard let trip = trip else { return }
        
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
                    // Add person to the current trip
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
        
        // Create and configure the BillDetailView
        let billDetailView = BillDetailView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        billDetailView.center = self.view.center
        billDetailView.configure(with: viewModel.bills[indexPath.row])
        
        // Add it to the current view
        self.view.addSubview(billDetailView)
        
        // Animate its appearance
        billDetailView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            billDetailView.alpha = 1
        }
    }
}

extension MainViewController: AddTripViewControllerDelegate {
    func didAddTrip(title: String, people: [Person], date: Date) {
        viewModel.addNewTrip(title: title, people: people, date: date)
    }
}

extension MainViewController: AddBillViewControllerDelegate {
    func didAddBill(title: String, amount: Double, date: Date, payer: Person, involvers: [Person]) {
        viewModel.addBillToCurrentTrip(title: title, amount: amount, date: date, payer: payer, involvers: involvers)
    }
}
