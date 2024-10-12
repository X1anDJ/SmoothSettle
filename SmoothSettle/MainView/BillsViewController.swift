//
//  BillsViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import Foundation
import UIKit

class BillsViewController: UIViewController {

    let customTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Bills"
        
        setupTableView()
    }
    
    func setupTableView() {
        customTableView.translatesAutoresizingMaskIntoConstraints = false
        customTableView.register(UITableViewCell.self, forCellReuseIdentifier: "BillCell")
        view.addSubview(customTableView)
        
        NSLayoutConstraint.activate([
            customTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
