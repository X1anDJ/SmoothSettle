//
//  ArchiveViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import UIKit
import Combine

class ArchiveActionViewController: UIViewController {

    let circleLayoutView = CircleLayoutView()  // Custom circle layout view
    let transactionsTableView = TransactionsTableView() // Transactions table view
    let archiveButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)
    let buttonsView = UIStackView()
    let lowerBackgroundView = UIView()
    
    // New Label for No Transactions
    let noTransactionsLabel = UILabel()
    
    var viewModel: MainViewModel?
    var archiveSubject = PassthroughSubject<Void, Never>()
    
    // Constraints for initial and final states
    private var initialCircleCenterYConstraint: NSLayoutConstraint!
    private var finalCircleTopConstraint: NSLayoutConstraint!
    
    private var initialLowerBgCenterYConstraint: NSLayoutConstraint!
    private var initialLowerBgWidthConstraint: NSLayoutConstraint!
    private var initialLowerBgHeightConstraint: NSLayoutConstraint!
    private var finalLowerBgTopConstraint: NSLayoutConstraint!
    private var finalLowerBgLeadingConstraint: NSLayoutConstraint!
    private var finalLowerBgTrailingConstraint: NSLayoutConstraint!
    private var finalLowerBgBottomConstraint: NSLayoutConstraint!
    
    // Final Constraints Storage
    private var finalConstraints: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set view's background with appearance of thick material
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)

        setupViews()
        setupInitialConstraints()
        setupFinalConstraints()

        // Only activate initial constraints at start
        activateInitialConstraints()
        
        // Disable archive button initially
        archiveButton.isEnabled = false
        
        // Hide transactions table initially
        transactionsTableView.alpha = 0.0
        lowerBackgroundView.alpha = 0.6
        archiveButton.alpha = 0.3
        noTransactionsLabel.isHidden = true  // Initially hidden
        
        // Fetch data
        if let viewModel = viewModel, let currentTripId = viewModel.currentTripId {
            if let currentTrip = viewModel.tripRepository.fetchTrip(by: currentTripId) {
                let userIds = currentTrip.peopleArray.compactMap { $0.id }
                circleLayoutView.userIds = userIds

                transactionsTableView.tripRepository = viewModel.tripRepository
                transactionsTableView.currentTrip = currentTripId
                transactionsTableView.isSelectable = false
                transactionsTableView.loadTransactions()
                self.circleLayoutView.transactions = transactionsTableView.sections
            }
        }
        
        // Layout with initial state applied
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // After 1.8 seconds, animate to final layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.animateToFinalState()
        }
    }
    
    func setupViews() {
        circleLayoutView.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.isScrollEnabled = true
        
        lowerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        lowerBackgroundView.backgroundColor = Colors.background0
        lowerBackgroundView.layer.cornerRadius = 8
        lowerBackgroundView.clipsToBounds = true

        // Archive Button
        archiveButton.translatesAutoresizingMaskIntoConstraints = false
        let archiveButtonLocalized = String(localized: "archive_button")
        archiveButton.setTitle(archiveButtonLocalized, for: .normal)
        archiveButton.tintColor = .white
        archiveButton.setTitleColor(.white, for: .normal)
        archiveButton.backgroundColor = Colors.primaryDark
        archiveButton.layer.cornerRadius = 15
        archiveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        archiveButton.addTarget(self, action: #selector(didTapArchiveTrip), for: .touchUpInside)

        // Close Button
        let closeButtonLocalized = String(localized: "close_button")
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle(closeButtonLocalized, for: .normal)
        closeButton.setTitleColor(Colors.primaryDark, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        closeButton.backgroundColor = .clear
        closeButton.layer.cornerRadius = 15
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.axis = .vertical
        buttonsView.spacing = 8
        buttonsView.distribution = .fillEqually
        buttonsView.addArrangedSubview(archiveButton)
        buttonsView.addArrangedSubview(closeButton)
        view.addSubview(lowerBackgroundView)
        lowerBackgroundView.addSubview(transactionsTableView)
        view.addSubview(circleLayoutView)

        view.addSubview(buttonsView)
        
        // Setup No Transactions Label
        noTransactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        let noTransactionText = String(localized: "no_transactions")
        noTransactionsLabel.text = noTransactionText
        noTransactionsLabel.textColor = .systemGray
        noTransactionsLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        noTransactionsLabel.textAlignment = .center
        noTransactionsLabel.isHidden = true  // Initially hidden
        lowerBackgroundView.addSubview(noTransactionsLabel)
        
        // Constraints for No Transactions Label
        NSLayoutConstraint.activate([
            noTransactionsLabel.centerXAnchor.constraint(equalTo: lowerBackgroundView.centerXAnchor),
            noTransactionsLabel.centerYAnchor.constraint(equalTo: lowerBackgroundView.centerYAnchor),
            noTransactionsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: lowerBackgroundView.leadingAnchor, constant: 16),
            noTransactionsLabel.trailingAnchor.constraint(lessThanOrEqualTo: lowerBackgroundView.trailingAnchor, constant: -16)
        ])
    }

    func setupInitialConstraints() {
        // Initial: CircleLayoutView in center
        initialCircleCenterYConstraint = circleLayoutView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        // Initial: LowerBackgroundView behind circle, centered, and sized relative to circle
        initialLowerBgCenterYConstraint = lowerBackgroundView.centerYAnchor.constraint(equalTo: circleLayoutView.centerYAnchor)
        initialLowerBgWidthConstraint = lowerBackgroundView.widthAnchor.constraint(equalTo: circleLayoutView.widthAnchor, multiplier: 1.0)
        initialLowerBgHeightConstraint = lowerBackgroundView.heightAnchor.constraint(equalTo: circleLayoutView.heightAnchor, multiplier: 1.0)
        
        NSLayoutConstraint.activate([
            circleLayoutView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialCircleCenterYConstraint,
            circleLayoutView.heightAnchor.constraint(equalToConstant: 300),
            circleLayoutView.widthAnchor.constraint(equalToConstant: 300),
            
            lowerBackgroundView.centerXAnchor.constraint(equalTo: circleLayoutView.centerXAnchor),
            initialLowerBgCenterYConstraint,
            initialLowerBgWidthConstraint,
            initialLowerBgHeightConstraint,
            
            buttonsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttonsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsView.heightAnchor.constraint(equalToConstant: 88 + 8),
        ])
        
        // We'll not add transaction table constraints here, they will be handled in final constraints setup
        // but we must ensure transactionsTableView is contained in lowerBackgroundView for final state.
    }

    func setupFinalConstraints() {
        // Final: Circle on top
        finalCircleTopConstraint = circleLayoutView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        
        // Final: LowerBackgroundView anchors
        finalLowerBgTopConstraint = lowerBackgroundView.topAnchor.constraint(equalTo: circleLayoutView.bottomAnchor, constant: 24)
        finalLowerBgLeadingConstraint = lowerBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        finalLowerBgTrailingConstraint = lowerBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        finalLowerBgBottomConstraint = lowerBackgroundView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -16)
        
        // Transaction TableView final constraints inside lowerBackgroundView
        let transactionsConstraints = [
            transactionsTableView.topAnchor.constraint(equalTo: lowerBackgroundView.topAnchor, constant: 16),
            transactionsTableView.leadingAnchor.constraint(equalTo: lowerBackgroundView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: lowerBackgroundView.trailingAnchor, constant: -16),
            transactionsTableView.bottomAnchor.constraint(equalTo: lowerBackgroundView.bottomAnchor, constant: -16)
        ]
        
        // We'll activate these final constraints after the animation.
        // For now, keep them deactivated. We'll store them for later use.
        NSLayoutConstraint.deactivate([
            finalCircleTopConstraint,
            finalLowerBgTopConstraint,
            finalLowerBgLeadingConstraint,
            finalLowerBgTrailingConstraint,
            finalLowerBgBottomConstraint
        ] + transactionsConstraints)
        
        // Store them in a property, or we can just remember them here and activate them later.
        finalConstraints = [
            finalCircleTopConstraint,
            finalLowerBgTopConstraint,
            finalLowerBgLeadingConstraint,
            finalLowerBgTrailingConstraint,
            finalLowerBgBottomConstraint
        ] + transactionsConstraints
    }

    private func activateInitialConstraints() {
        // We already activated initial constraints in setupInitialConstraints.
        // Just ensure final constraints are off.
        NSLayoutConstraint.deactivate(finalConstraints)
    }

    private func animateToFinalState() {
        // Deactivate initial constraints that conflict with final state
        NSLayoutConstraint.deactivate([
            initialCircleCenterYConstraint,
            initialLowerBgCenterYConstraint,
            initialLowerBgWidthConstraint,
            initialLowerBgHeightConstraint
        ])
        
        // Activate final constraints
        NSLayoutConstraint.activate(finalConstraints)

        // Determine if there are any bills/transactions
        var hasTransactions = false
        if let viewModel = viewModel, let currentTripId = viewModel.currentTripId {
            if let currentTrip = viewModel.tripRepository.fetchTrip(by: currentTripId) {
                hasTransactions = !currentTrip.billsArray.isEmpty
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            // Fade in transaction table or no transactions label
            self.lowerBackgroundView.alpha = 1.0
            self.archiveButton.alpha = 1.0
            self.archiveButton.isEnabled = true
            
            if hasTransactions {
                self.transactionsTableView.alpha = 1.0
                self.noTransactionsLabel.isHidden = true
            } else {
                self.transactionsTableView.alpha = 0.0
                self.noTransactionsLabel.isHidden = false
            }
            
            // Re-layout the view with the final constraints
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func didTapArchiveTrip() {
        guard let viewModel = viewModel else { return }
        
        viewModel.archiveCurrentTrip()
        archiveSubject.send(())

        dismiss(animated: true) {
            // Get a reference to the AppDelegate
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   let tabBarController = appDelegate.tabBarController {
                    tabBarController.selectedIndex = 1
                }
            }
        }
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
