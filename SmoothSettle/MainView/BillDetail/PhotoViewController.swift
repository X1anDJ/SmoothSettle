//
//  PhotoViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/27.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var image: UIImage?
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        configure()
    }
    
    private func setupView() {
        view.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // Add gesture recognizer to dismiss on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configure() {
        imageView.image = image
    }
    
    @objc private func dismissTapped() {
        navigationController?.popViewController(animated: true)
    }
}
