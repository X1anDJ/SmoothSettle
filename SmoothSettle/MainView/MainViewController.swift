import UIKit
import Combine

class MainViewController: UIViewController {

    var viewModel = MainViewModel()
    var cancellables = Set<AnyCancellable>()
    
    // UI Components
    let stackView = UIStackView()
    let titleLabel = UILabel()
    let currentTripButton = UIButton()
    let addTripButton = UIButton()
    let peopleSliderView = PeopleSliderView()
    let containerView = UIView() // Container for the table view to apply the shadow
    let customTableView = UITableView()
    let addBillButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage()
        style()
        layout()
        setupBindings()
        viewModel.loadAllTrips()
        
        peopleSliderView.delegate = self
        peopleSliderView.allowSelection = false
        
        customTableView.register(BillTableViewCell.self, forCellReuseIdentifier: "BillCell")
        
        // Adding rounded corners to the table view
        customTableView.layer.cornerRadius = 15
        customTableView.layer.masksToBounds = true
        
        // Set up the shadow for containerView
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = false // Allow shadow to be outside bounds
    }
    
    func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = UIImage(named: "background0")
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
    
    // Set up bindings between the view model and the UI
    func setupBindings() {
        // Observe current trip changes
        viewModel.$currentTrip
            .receive(on: DispatchQueue.main)
            .sink { [weak self] trip in
                self?.updateCurrentTripUI(with: trip)
                self?.updatePeopleSlider(with: trip?.peopleArray ?? [])
                self?.peopleSliderView.trip = trip
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
                self?.customTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func updateCurrentTripUI(with trip: Trip?) {
        if let trip = trip {
            let currentTripText = NSMutableAttributedString(string: trip.title ?? "Unnamed Trip")
            let arrowIconAttachment = NSTextAttachment()
            arrowIconAttachment.image = UIImage(systemName: "chevron.down")
            currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
            currentTripButton.setAttributedTitle(currentTripText, for: .normal)
        } else {
            currentTripButton.setAttributedTitle(NSAttributedString(string: "No Trip Selected"), for: .normal)
        }
    }
    
    func updatePeopleSlider(with people: [Person]) {
        peopleSliderView.people = people
    }
}

extension MainViewController {
    func style() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Current Trip"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .extraLargeTitle)
        titleLabel.textAlignment = .left
        
        currentTripButton.translatesAutoresizingMaskIntoConstraints = false
        let arrowIconAttachment = NSTextAttachment()
        arrowIconAttachment.image = UIImage(systemName: "chevron.down")
        let currentTripText = NSMutableAttributedString(string: "Select Trip ")
        currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
        currentTripButton.setAttributedTitle(currentTripText, for: .normal)
        currentTripButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .extraLargeTitle2)
        currentTripButton.contentHorizontalAlignment = .left
        currentTripButton.addTarget(self, action: #selector(showTripDropdown), for: .touchUpInside)
        
        addTripButton.translatesAutoresizingMaskIntoConstraints = false
        let plusIcon = UIImage(systemName: "plus")
        addTripButton.setImage(plusIcon, for: .normal)
        addTripButton.tintColor = .systemBlue
        addTripButton.addTarget(self, action: #selector(didTapAddTrip), for: .touchUpInside)
        
        peopleSliderView.translatesAutoresizingMaskIntoConstraints = false
        peopleSliderView.delegate = self
        
        addBillButton.translatesAutoresizingMaskIntoConstraints = false
        addBillButton.setTitle("Add a Bill", for: .normal)
        addBillButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        addBillButton.setTitleColor(.systemBlue, for: .normal)
        addBillButton.addTarget(self, action: #selector(didTapAddBill), for: .touchUpInside)
        
        // Set up the container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear // Make container view clear to see shadow
        
        customTableView.translatesAutoresizingMaskIntoConstraints = false
        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.register(UITableViewCell.self, forCellReuseIdentifier: "BillCell")
    }
    
    func layout() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(currentTripButton)
        
        view.addSubview(stackView)
        view.addSubview(addTripButton)
        view.addSubview(peopleSliderView)
        view.addSubview(addBillButton)
        view.addSubview(containerView)
        
        containerView.addSubview(customTableView) // Add table view inside the container

        NSLayoutConstraint.activate([
            // Stack View Constraints
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // Add Trip Button Constraints
            addTripButton.centerYAnchor.constraint(equalTo: currentTripButton.centerYAnchor),
            addTripButton.leadingAnchor.constraint(equalTo: currentTripButton.trailingAnchor, constant: 8),

            // People Slider View Constraints
            peopleSliderView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            peopleSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            peopleSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            peopleSliderView.heightAnchor.constraint(equalToConstant: 80),

            // Container View (TableView) Constraints
            containerView.topAnchor.constraint(equalTo: peopleSliderView.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: addBillButton.topAnchor, constant: -16),

            // Custom TableView inside the containerView Constraints
            customTableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            customTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            customTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            customTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Add Bill Button Constraints
            addBillButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addBillButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addBillButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addBillButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func didTapAddTrip() {
        let addTripVC = AddTripViewController()
        addTripVC.delegate = self
        addTripVC.modalPresentationStyle = .overCurrentContext
        addTripVC.view.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height * 0.5)
        present(addTripVC, animated: false)
    }
    
    @objc func didTapAddBill() {
        let addBillVC = AddBillViewController()
        addBillVC.modalPresentationStyle = .overCurrentContext
        addBillVC.view.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height * 0.6)
        
        addBillVC.currentTrip = viewModel.currentTrip
        addBillVC.people = viewModel.people
        addBillVC.delegate = self
        present(addBillVC, animated: false)
    }

    @objc func showTripDropdown() {
        let dropdownMenu = UIAlertController(title: "Switch Trip", message: nil, preferredStyle: .actionSheet)
        
        for trip in viewModel.trips {
            dropdownMenu.addAction(UIAlertAction(title: trip.title, style: .default, handler: { [weak self] _ in
                self?.viewModel.selectTrip(trip)
            }))
        }
        
        dropdownMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(dropdownMenu, animated: true)
    }
}

// Delegate for PeopleSliderView
extension MainViewController: PeopleSliderViewDelegate {
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
                if let name = alert.textFields?.first?.text, !name.isEmpty {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath) as! BillTableViewCell
        let bill = viewModel.bills[indexPath.row]
        
        // Configure the cell using actual data from the bill
        cell.configure(billTitle: bill.title ?? "Untitled Bill",
                       date: formatDate(bill.date),
                       amount: String(format: "%.2f", bill.amount),
                       payerName: bill.payer?.name ?? "Unknown",
                       involversCount: bill.involvers?.count ?? 0)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
