import UIKit

class BillTableViewCell: UITableViewCell {
    
    // UI Elements
    let billTitleLabel = UILabel()
    let dateLabel = UILabel()
    let payerCircleView = UIView()
    let payerInitialsLabel = UILabel()
    let paidLabel = UILabel()
    let involversCircleContainerView = UIView()
    let amountLabel = UILabel()
    
    // Properties to store involvers count
    private var storedInvolversCount: Int = 0
    
    // Initialize the cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // Setup UI elements
    private func setupViews() {
        // Bill Title Label
        billTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        billTitleLabel.textColor = .black
        billTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Label
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Payer Circle and Initials Label
        payerCircleView.backgroundColor = Colors.primaryMedium
        payerCircleView.translatesAutoresizingMaskIntoConstraints = false
        
        payerInitialsLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        payerInitialsLabel.textColor = .white
        payerInitialsLabel.textAlignment = .center
        payerInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        payerCircleView.addSubview(payerInitialsLabel)
        
        // Paid Label
        paidLabel.text = "Paid for"
        paidLabel.textAlignment = .center
        paidLabel.font = UIFont.systemFont(ofSize: 14)
        paidLabel.textColor = .black
        paidLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Involvers Circle Container View
        involversCircleContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount Label
        amountLabel.font = UIFont.boldSystemFont(ofSize: 18)
        amountLabel.textColor = .black
        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // Setup constraints manually
    private func setupConstraints() {
        contentView.addSubview(billTitleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(payerCircleView)
        contentView.addSubview(paidLabel)
        contentView.addSubview(involversCircleContainerView)
        contentView.addSubview(amountLabel)
        
        // First Row Constraints
        NSLayoutConstraint.activate([
            billTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            billTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            billTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),
            
            dateLabel.centerYAnchor.constraint(equalTo: billTitleLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        // Payer Circle Constraints
        NSLayoutConstraint.activate([
            payerCircleView.topAnchor.constraint(equalTo: billTitleLabel.bottomAnchor, constant: 8),
            payerCircleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            payerCircleView.widthAnchor.constraint(equalToConstant: 30),
            payerCircleView.heightAnchor.constraint(equalTo: payerCircleView.widthAnchor),
        ])
        payerCircleView.layer.cornerRadius = 15
        
        // Center initials inside payer's circle
        NSLayoutConstraint.activate([
            payerInitialsLabel.centerXAnchor.constraint(equalTo: payerCircleView.centerXAnchor),
            payerInitialsLabel.centerYAnchor.constraint(equalTo: payerCircleView.centerYAnchor),
        ])
        
        // Paid Label Constraints
        NSLayoutConstraint.activate([
            paidLabel.centerYAnchor.constraint(equalTo: payerCircleView.centerYAnchor),
            paidLabel.leadingAnchor.constraint(equalTo: payerCircleView.trailingAnchor, constant: 8),
            paidLabel.widthAnchor.constraint(equalToConstant: 60),
        ])
        
        // Amount Label Constraints
        NSLayoutConstraint.activate([
            amountLabel.centerYAnchor.constraint(equalTo: payerCircleView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.widthAnchor.constraint(equalToConstant: 90),
        ])
        
        // Involvers Circle Container Constraints
        NSLayoutConstraint.activate([
            involversCircleContainerView.centerYAnchor.constraint(equalTo: payerCircleView.centerYAnchor),
            involversCircleContainerView.leadingAnchor.constraint(equalTo: paidLabel.trailingAnchor, constant: 8),
            involversCircleContainerView.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),
            involversCircleContainerView.heightAnchor.constraint(equalToConstant: 20), // Will be updated dynamically
        ])
        
        // Bottom Constraint
        NSLayoutConstraint.activate([
            payerCircleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // Configure the cell with data
    func configure(billTitle: String, date: String, amount: String, payerName: String, involversCount: Int) {
        billTitleLabel.text = billTitle
        dateLabel.text = date
        amountLabel.text = "$\(amount)"
        payerInitialsLabel.text = getInitials(from: payerName)
        storedInvolversCount = involversCount
        
        // Update involvers
        updateInvolvers()
    }
    
    // Update involver circles
    private func updateInvolvers() {
        // Remove existing involver views
        involversCircleContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let spacing: CGFloat = 4.0
        
        // Calculate available width for involvers
        let leftFixedWidths: CGFloat = 16 + 30 + 8 + 60 + 8  // Left margin, payerCircleView, spacing, paidLabel, spacing
        let rightFixedWidths: CGFloat = 8 + 90 + 16          // spacing, amountLabel, right margin
        let totalFixedWidths = leftFixedWidths + rightFixedWidths
        
        let availableWidth = contentView.bounds.width - totalFixedWidths
        
        // Total spacing between circles
        let totalSpacing = CGFloat(max(storedInvolversCount - 1, 0)) * spacing
        
        // Calculate circle width
        var circleWidth = (availableWidth - totalSpacing) / CGFloat(storedInvolversCount)
        
        // Minimum and maximum circle widths
        let minCircleWidth: CGFloat = 5.0
        let maxCircleWidth: CGFloat = 15.0
        
        // Clamp circleWidth between min and max values
        circleWidth = max(min(circleWidth, maxCircleWidth), minCircleWidth)
        
        // Update container height constraint to match circle size
        for constraint in involversCircleContainerView.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant = circleWidth
                break
            }
        }
        
        // Create involver circles
        var previousCircle: UIView? = nil
        for _ in 0..<storedInvolversCount {
            let circleView = UIView()
            circleView.backgroundColor = Colors.accentOrange
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.layer.cornerRadius = circleWidth / 2
            circleView.layer.masksToBounds = true
            
            involversCircleContainerView.addSubview(circleView)
            
            // Constraints for circleView
            NSLayoutConstraint.activate([
                circleView.widthAnchor.constraint(equalToConstant: circleWidth),
                circleView.heightAnchor.constraint(equalToConstant: circleWidth),
                circleView.centerYAnchor.constraint(equalTo: involversCircleContainerView.centerYAnchor)
            ])
            
            if let previous = previousCircle {
                NSLayoutConstraint.activate([
                    circleView.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: spacing)
                ])
            } else {
                NSLayoutConstraint.activate([
                    circleView.leadingAnchor.constraint(equalTo: involversCircleContainerView.leadingAnchor)
                ])
            }
            
            previousCircle = circleView
        }
        
        // Adjust trailing anchor of the last circle
        if let lastCircle = previousCircle {
            NSLayoutConstraint.activate([
                lastCircle.trailingAnchor.constraint(lessThanOrEqualTo: involversCircleContainerView.trailingAnchor)
            ])
        }
    }
    
    // Helper function to get initials from the payer's name
    private func getInitials(from name: String) -> String {
        let nameComponents = name.components(separatedBy: " ")
        let initials = nameComponents.compactMap { $0.first }.map { String($0) }.joined()
        return initials
    }
}

