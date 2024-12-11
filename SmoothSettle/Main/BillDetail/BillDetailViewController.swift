//
//  BillDetailViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/27.
//
import UIKit
import PhotosUI

class BillDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let photoImageView = UIImageView()
    private let photoButton = UIButton()
    private let tableView = UITableView()
    
    // ViewModel
    var viewModel: BillDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        configure()
    }
    
    // MARK: - Setup UI
    private func setupView() {
        view.backgroundColor = Colors.background1
        
        // Setup titleLabel
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup dateLabel
        dateLabel.font = UIFont.systemFont(ofSize: 16)
        dateLabel.textColor = .gray
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup photoImageView
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.layer.cornerRadius = 16
        photoImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        photoImageView.addGestureRecognizer(tapGesture)
        
        // Set up the button's image
        photoButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        photoButton.imageView?.tintColor = Colors.primaryDark
        photoButton.imageView?.contentMode = .scaleAspectFit

        // Add padding around the image
        let padding: CGFloat = 6.0 // Adjust the padding value as needed
        photoButton.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)

        // Button appearance settings
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = 16
        photoButton.layer.borderColor = Colors.primaryDark.cgColor
        photoButton.layer.borderWidth = 1
        photoButton.translatesAutoresizingMaskIntoConstraints = false

        // Configure the menu for the button
        photoButton.menu = getImagePickerMenu()
        photoButton.showsMenuAsPrimaryAction = true

        // Set content alignment
        photoButton.contentHorizontalAlignment = .fill
        photoButton.contentVerticalAlignment = .fill

        
        // Setup tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.background1
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        // Register custom cell
        tableView.register(BillDetailTableViewCell.self, forCellReuseIdentifier: "BillDetailCell")
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        
        if viewModel.image == nil {
            view.addSubview(photoButton)
        } else {
            view.addSubview(photoImageView)
        }
        
        view.addSubview(tableView)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            
            // Date label
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
        ])
        
        if viewModel.image == nil {
            // Constraints for photoButton
            NSLayoutConstraint.activate([
                photoButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
                photoButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                photoButton.widthAnchor.constraint(equalToConstant: 48),
                photoButton.heightAnchor.constraint(equalToConstant: 48),
                
                // TableView
                tableView.topAnchor.constraint(equalTo: photoButton.bottomAnchor, constant: 16),
                tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            ])
        } else {
            // Constraints for photoImageView
            NSLayoutConstraint.activate([
                photoImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
                photoImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                photoImageView.widthAnchor.constraint(equalToConstant: 104),
                photoImageView.heightAnchor.constraint(equalToConstant: 104),
                
                // TableView
                tableView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 16),
                tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            ])
        }
    }
    
    // MARK: - Configure View with ViewModel
    private func configure() {
        titleLabel.text = viewModel.titleText
        dateLabel.text = viewModel.dateText
        
        if let image = viewModel.image {
            photoImageView.image = image
        }
    }
    
    // MARK: - Photo Actions
    @objc private func photoTapped() {
        guard let image = photoImageView.image else { return }
        let photoVC = PhotoViewController()
        photoVC.image = image
        navigationController?.pushViewController(photoVC, animated: true)
    }

    
    private func getImagePickerMenu() -> UIMenu {
        let cameraAction = UIAction(title: "Camera", image: UIImage(systemName: "camera")) { [weak self] (_) in
            self?.presentCamera()
        }

        let galleryAction = UIAction(title: "Gallery", image: UIImage(systemName: "photo.on.rectangle")) { [weak self] (_) in
            self?.presentPhotoPicker()
        }

        return UIMenu(title: "Select Image", children: [cameraAction, galleryAction])
    }
    
    
    // MARK: - Image Picker Methods
    func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: "Camera not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let imageToSave = selectedImage {
            saveImage(imageToSave)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider else { return }
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async {
                    if let imageToSave = image as? UIImage {
                        self?.saveImage(imageToSave)
                    }
                }
            }
        }
    }
    
    // Save Image Using ViewModel
    private func saveImage(_ image: UIImage) {
        viewModel.changeBillImage(to: image)
        updateUIAfterImageChange()
    }
    
    // Update UI After Image Change
    private func updateUIAfterImageChange() {
        // Remove photoButton and add photoImageView
        photoButton.removeFromSuperview()
        view.addSubview(photoImageView)
        setupConstraints() // Re-apply constraints
        photoImageView.image = viewModel.image
        view.layoutIfNeeded()
    }
    
    // Show alert messages
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
extension BillDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Payer and Involvers
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.getPayer() != nil ? 1 : 0
        } else {
            return viewModel.getInvolvers().count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? String(localized: "payer") : String(localized: "participants")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BillDetailCell", for: indexPath) as! BillDetailTableViewCell
        
        cell.backgroundColor = .clear
        
        if indexPath.section == 0 {
            // Payer
            if let payer = viewModel.getPayer() {
                let amount = viewModel.getAmount()
                cell.configure(with: payer, amount: amount, isPayer: true)
            }
        } else {
            // Involvers
            let involvers = viewModel.getInvolvers()
            if indexPath.row < involvers.count {
                let person = involvers[indexPath.row]
                let share = viewModel.getAmount() / Double(involvers.count)
                cell.configure(with: person, amount: share, isPayer: false)
            } else {
                // print("Error: Involver index out of range.")
            }
        }
        // configure the cell to be not tappable
        
        return cell
    }
    
    // Set cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
