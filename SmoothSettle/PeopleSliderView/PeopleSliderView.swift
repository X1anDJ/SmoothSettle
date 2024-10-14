import UIKit

protocol PeopleSliderViewDelegate: AnyObject {
    func didRequestRemovePerson(_ personId: UUID?)
    func didTapAddPerson(for tripId: UUID?)
    func didSelectPerson(_ personId: UUID?, for tripId: UUID?, context: SliderContext)
}

enum SliderContext {
    case payer
    case involver
}

class PeopleSliderView: UIView {
    
    var context: SliderContext?
    
    // Collection View to show the circular cells
    private var collectionView: UICollectionView
    
    // Delegate for handling button taps and person selection
    weak var delegate: PeopleSliderViewDelegate?
    
    // People array from the current trip or new trip
    var people: [Person] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // Selected payer and involvers (now using UUID?)
    var selectedPayerId: UUID?
    var selectedInvolverIds: [UUID] = []
    
    // Current Trip ID (nil if adding a new trip)
    var tripId: UUID?
    
    // Flag to disable or enable selecting person
    var allowSelection: Bool = true // Default to true (for AddBillView)
     
    var isRemoveModeActive: Bool = false  // Track remove mode
    private var tapGesture: UITapGestureRecognizer!
    
    // Custom initializer
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        self.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = false
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)
        
        collectionView.register(PeopleCell.self, forCellWithReuseIdentifier: "PeopleCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload() {
        collectionView.reloadData()
    }

    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            isRemoveModeActive = true   // Now user can tap outside to hide the remove buttons
            
            for case let cell as PeopleCell in collectionView.visibleCells {
                cell.showRemoveButton()
            }
            self.tapGesture.isEnabled = true
        }
    }
    
    @objc private func handleTapOutside() {
        hideAllRemoveButtons()
    }
    
    func hideAllRemoveButtons() {
        if isRemoveModeActive {
            for case let cell as PeopleCell in collectionView.visibleCells {
                cell.hideRemoveButton()
            }
            isRemoveModeActive = false  // Reset flag when done
            self.tapGesture.isEnabled = false  // Disable the gesture after hiding
        }
    }
}

// MARK: - UICollectionViewDataSource and UICollectionViewDelegateFlowLayout
extension PeopleSliderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if people.count == 0 {
            return 2
        } else {
            
            return people.count + 1 // +1 for the "plus" button
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCell", for: indexPath) as! PeopleCell

        if people.count == 0 && indexPath.item == 1 {
            cell.configureEmptyButton()
            return cell
        }

        if indexPath.item == 0 {
            // First cell is always the "plus" button for adding new people
            cell.configureAsAddButton()
        } else {
            cell.delegate = self
            let person = people[indexPath.item - 1] // Adjust index for the "plus" button
            print("Person: \(String(describing: person.name))")
//            let isSelected = (person == selectedPayer || selectedInvolvers.contains(person))
//            cell.configure(with: person, isSelected: isSelected) // Highlight if selected
            
            let isSelected = (person.id == selectedPayerId || (selectedInvolverIds.contains(person.id)))
            cell.configure(with: person.id, name: person.name, isSelected: isSelected)
        }

        return cell
    }



    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        print("Cell tapped at index \(indexPath.item)")
        
        if indexPath.item == 0 {
            // "plus" button tapped
            delegate?.didTapAddPerson(for: tripId) // Trigger delegate method for adding a new person
        } else if people.count == 0 && indexPath.item == 1 {
            delegate?.didTapAddPerson(for: tripId)
        } else {
            // A person was tapped, trigger delegate for person selection
            let person = people[indexPath.item - 1]
            if allowSelection {
                delegate?.didSelectPerson(person.id, for: tripId, context: context ?? .payer) // Pass person.id and tripId
            }
        }
    }

    // Layout for the circular cells (60x60 size)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}

extension PeopleSliderView: PeopleCellDelegate {

    func didRequestRemovePerson(_ personId: UUID?) {
        // Check if personId is valid, do nothing if it's nil
        print("Pressed remove")
        guard let personId = personId else {
            return
        }

        
        // Pass the valid personId to the delegate method
        delegate?.didRequestRemovePerson(personId)
    }
}
