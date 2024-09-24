import UIKit

protocol PeopleSliderViewDelegate: AnyObject {
    func didTapAddPerson(for trip: Trip?)
    func didSelectPerson(_ person: Person, for trip: Trip?, context: SliderContext)
}

enum SliderContext {
    case payer
    case involver
}

class PeopleSliderView: UIView {
    
    var context: SliderContext?
    
    // Collection View to show the circular cells
    private let collectionView: UICollectionView
    
    // Delegate for handling button taps and person selection
    weak var delegate: PeopleSliderViewDelegate?
    
    // People array from the current trip or new trip
    var people: [Person] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // Selected payer and involvers
    var selectedPayer: Person?
    var selectedInvolvers: [Person] = []
    
    // Current Trip (nil if adding a new trip)
    var trip: Trip?
    
    // Flag to disable or enable selection
     var allowSelection: Bool = true // Default to true (for AddBillView)
     
    
    // Custom initializer
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        
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
        print("Reloading PeopleSliderView")
         collectionView.reloadData()
     }
}

// MARK: - UICollectionViewDataSource and UICollectionViewDelegateFlowLayout
extension PeopleSliderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if people.count == 0 {
            return 2
        }
        
        return people.count + 1 // +1 for the "plus" button
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
            let person = people[indexPath.item - 1] // Adjust index for the "plus" button
            let isSelected = (person == selectedPayer || selectedInvolvers.contains(person))
            cell.configure(with: person, isSelected: isSelected) // Highlight if selected
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // "plus" button tapped
            delegate?.didTapAddPerson(for: trip) // Trigger delegate method for adding a new person
        } else if people.count == 0 && indexPath.item == 1 {
            delegate?.didTapAddPerson(for: trip)
        } else {
            // A person was tapped, trigger delegate for person selection
            let person = people[indexPath.item - 1]
            print("Selected person: \(person.name ?? "Unknown")")
            if allowSelection { // You can pass the context based on which slider this view represents
                delegate?.didSelectPerson(person, for: trip, context: context ?? .payer ) // or .involver depending on the slider
            }
        }
    }
    
    // Layout for the circular cells (60x60 size)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}
