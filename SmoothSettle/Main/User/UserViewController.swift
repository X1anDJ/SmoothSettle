////
////  UserViewController.swift
////  SmoothSettle
////
////  Created by Dajun Xian on 2024/10/11.
////
//
//import Foundation
//import UIKit
//
//class UserViewController: UIViewController {
//    
//    let topView = UIView()
//    let userCircle = UIView()
//    let initialLabel = UILabel()
//    let usernameLabel = UILabel()
//    
//    let tableView = UITableView(frame: .zero, style: .insetGrouped)
//    
//    let wrapperView = UIStackView()
//    let logoutButton = UIButton(type: .system)
//    
//    weak var logoutDelegate: LogoutDelegate?
//    
//    // Assuming there's a user model
//    var username: String = "Dajun Xian" // Replace with actual username
//    var userInitials: String {
//        // Extract initials from the username
//        let nameComponents = username.split(separator: " ")
//        let initials = nameComponents.compactMap { $0.first }.map { String($0).uppercased() }
//        return initials.joined()
//    }
//    
//    enum Section: Int, CaseIterable {
//        case preference
//        case feedback
//        
//        var title: String {
//            switch self {
//            case .preference:
//                return "Preference"
//            case .feedback:
//                return "Feedback"
//            }
//        }
//        
//        var options: [String] {
//            switch self {
//            case .preference:
//                return ["Theme", "Notification", "FaceID"]
//            case .feedback:
//                return ["Support", "Rate SmoothSettle"]
//            }
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = Colors.background1
//        
//        style()
//        layout()
//        
//        let closeButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapCloseButton))
//        navigationItem.rightBarButtonItem = closeButton
//    }
//}
//
//extension UserViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return Section.allCases.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//         guard let section = Section(rawValue: section) else { return 0 }
//         return section.options.count
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//         guard let section = Section(rawValue: section) else { return nil }
//         return section.title
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//         let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
//         guard let section = Section(rawValue: indexPath.section) else { return cell }
//         cell.textLabel?.text = section.options[indexPath.row]
//         
//         let accessoryImage = UIImageView(image: UIImage(systemName: "chevron.right"))
//         accessoryImage.tintColor = .gray
//         cell.accessoryView = accessoryImage
//         
//         cell.selectionStyle = .none
//         return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         tableView.deselectRow(at: indexPath, animated: true)
//         // Handle cell selection if needed
//    }
//}
//
//extension UserViewController {
//    func style() {
//        // Top View
//        topView.translatesAutoresizingMaskIntoConstraints = false
//        topView.backgroundColor = .clear
//        
//        // User Circle
//        userCircle.translatesAutoresizingMaskIntoConstraints = false
//        userCircle.backgroundColor = Colors.accentOrange
//        userCircle.layer.cornerRadius = 40
//        userCircle.clipsToBounds = true
//        
//        // Adding Shadow to userCircle
//        userCircle.layer.shadowColor = UIColor.black.cgColor
//        userCircle.layer.shadowOpacity = 0.3
//        userCircle.layer.shadowOffset = CGSize(width: 0, height: 0)
//        userCircle.layer.shadowRadius = 6
//        userCircle.layer.masksToBounds = false // Important to allow shadow to be visible
//        
//        // Initial Label
//        initialLabel.translatesAutoresizingMaskIntoConstraints = false
//        initialLabel.text = userInitials
//        initialLabel.textColor = .white
//        initialLabel.textAlignment = .center
//        initialLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        
//        // Username Label
//        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
//        usernameLabel.text = username
//        usernameLabel.textColor = .black
//        usernameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        
//        // Table View
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.backgroundColor = Colors.background1
//        tableView.separatorStyle = .singleLine
//        tableView.tableFooterView = UIView()
//        
//        // Wrapper View (Stack View)
//        wrapperView.translatesAutoresizingMaskIntoConstraints = false
//        wrapperView.axis = .vertical
//        wrapperView.spacing = 10
//        wrapperView.alignment = .fill
//        wrapperView.distribution = .fill
//        
//        // Logout Button
//        logoutButton.translatesAutoresizingMaskIntoConstraints = false
//        logoutButton.setTitle("Logout", for: .normal)
//        logoutButton.setTitleColor(view.tintColor, for: .normal)
//        logoutButton.backgroundColor = .clear
//        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
//        
//        // Add Logout Button to Wrapper View
//        wrapperView.addArrangedSubview(logoutButton)
//    }
//    
//    func layout() {
//        // Add Top View and its subviews
//        view.addSubview(topView)
//        topView.addSubview(userCircle)
//        topView.addSubview(usernameLabel)
//        userCircle.addSubview(initialLabel)
//        
//        // Add Table View
//        view.addSubview(tableView)
//        
//        // Add Wrapper View
//        view.addSubview(wrapperView)
//        
//        NSLayoutConstraint.activate([
//            // Top View Constraints
//            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            // Adjust the height to accommodate userCircle and usernameLabel
//            topView.heightAnchor.constraint(equalToConstant: 140),
//            
//            // User Circle Constraints
//            userCircle.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
//            userCircle.topAnchor.constraint(equalTo: topView.topAnchor, constant: 16),
//            userCircle.widthAnchor.constraint(equalToConstant: 80),
//            userCircle.heightAnchor.constraint(equalToConstant: 80),
//            
//            // Initial Label Constraints
//            initialLabel.centerXAnchor.constraint(equalTo: userCircle.centerXAnchor),
//            initialLabel.centerYAnchor.constraint(equalTo: userCircle.centerYAnchor),
//            // Optionally, set the width to ensure it fits multiple initials
//            initialLabel.widthAnchor.constraint(lessThanOrEqualTo: userCircle.widthAnchor, multiplier: 0.8),
//            
//            // Username Label Constraints
//            usernameLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
//            usernameLabel.topAnchor.constraint(equalTo: userCircle.bottomAnchor, constant: 12),
//            
//            // Table View Constraints
//            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: wrapperView.topAnchor, constant: -20),
//            
//            // Wrapper View Constraints
//            wrapperView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            wrapperView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            wrapperView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            logoutButton.heightAnchor.constraint(equalToConstant: 50),
//        ])
//    }
//    
//    @objc func logoutButtonTapped(sender: UIButton) {
//        // Log out from Firebase
//        logoutDelegate?.didLogout()
//    }
//    
//    @objc func didTapCloseButton() {
//        // Dismiss the presented UserViewController and return to MainViewController
//        dismiss(animated: true, completion: nil)
//    }
//
//}
