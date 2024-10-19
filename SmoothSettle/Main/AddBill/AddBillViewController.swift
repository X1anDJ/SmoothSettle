//
//  AddBillViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import UIKit
import PhotosUI

protocol AddBillViewControllerDelegate: AnyObject {
    func didAddBill(title: String,
                    amount: Double,
                    date: Date,
                    payerId: UUID,
                    involverIds: [UUID],
                    image: UIImage?)
}

class AddBillViewController: UIViewController,
                             UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate,
                             PHPickerViewControllerDelegate {
    
    // Delegate to notify the MainViewController of the added bill
    weak var delegate: AddBillViewControllerDelegate?
    
    // Custom View
    let addBillView = AddBillView()
    
    // Now store selected payer and involvers by UUID
    var selectedPayerId: UUID?
    var selectedInvolverIds: [UUID] = []
    var selectedImage: UIImage?
    
    // Pass the current trip and people
    var currentTripId: UUID?
    var people: [Person] = [] // Still using Person to populate the slider
    
    override func loadView() {
        self.view = addBillView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupActions()
        
        if #available(iOS 15.0, *) {
            self.modalPresentationStyle = .pageSheet
            let requiredHeight = calculateRequiredHeight()
            let customDetent = UISheetPresentationController.Detent
                .custom(identifier: .init("customHeight")) { _ in
                    return requiredHeight
                }
            
            self.sheetPresentationController?.detents = [customDetent]
            self.sheetPresentationController?.prefersGrabberVisible = false
        } else {
            self.modalPresentationStyle = .formSheet
        }
        
        if #available(iOS 15.0, *) {
            self.navigationController?.navigationBar.scrollEdgeAppearance =
                self.navigationController?.navigationBar.standardAppearance
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBillView.involversSliderView.delegate = self
        addBillView.payerSliderView.delegate = self
        addBillView.payerSliderView.allowSelection = true
        addBillView.involversSliderView.allowSelection = true
        
        addBillView.payerSliderView.context = .payer
        addBillView.involversSliderView.context = .involver
        
        addBillView.payerSliderView.people = people
        addBillView.involversSliderView.people = people
        
        // Reload the sliders to reflect any data changes
        addBillView.payerSliderView.reload()
        addBillView.involversSliderView.reload()
    }
    
    private func setup() {
        // Setup Navigation Bar (transparent)
        navigationItem.title = "Add Bill"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapConfirmButton))
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.shadowImage = UIImage()
            appearance.shadowColor = nil
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.isTranslucent = true
        }
        
        // Setup cameraButton
        addBillView.cameraButton.addTarget(self,
                                           action: #selector(cameraButtonTapped),
                                           for: .touchUpInside)
        addBillView.cameraButton.menu = getImagePickerMenu()
        addBillView.cameraButton.showsMenuAsPrimaryAction = true
    }
    
    private func setupActions() {
        // Swipe down to dismiss the view
        let swipeDownGesture = UISwipeGestureRecognizer(target: self,
                                                        action: #selector(didTapCancelButton))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }
    
    // Calculate the necessary height based on the content
    private func calculateRequiredHeight() -> CGFloat {
        let padding: CGFloat = 30
        
        // Heights of all elements
        let billTitleHeight: CGFloat = 50 // TextField height
        let amountHeight: CGFloat = 50
        let payerSliderHeight: CGFloat = 100
        let involverSliderHeight: CGFloat = 100
        
        // Total required height
        let totalHeight = billTitleHeight + amountHeight +
                          payerSliderHeight + involverSliderHeight +
                          (padding * 6)
        return totalHeight
    }
    
    // Handle confirm button action
    @objc private func didTapConfirmButton() {
        guard let title = addBillView.billTitleTextField.text, !title.isEmpty,
              let amountText = addBillView.amountTextField.text,
              let amount = Double(amountText),
              let payerId = selectedPayerId else {
            let alert = UIAlertController(title: "Invalid Input",
                                          message: "Please fill all the required fields.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Get the selected date from the datePicker
        let selectedDate = addBillView.datePicker.date
        
        // Notify the delegate with the new bill data using UUIDs
        delegate?.didAddBill(
            title: title,
            amount: amount,
            date: selectedDate,
            payerId: payerId,
            involverIds: selectedInvolverIds,
            image: selectedImage // Pass the selected image
        )
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Camera Button Actions
    @objc private func cameraButtonTapped() {
        // The menu is already set; this method is not strictly necessary
        // unless you want to perform additional actions
    }
    
    // Show alert messages
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Get the image picker menu
    private func getImagePickerMenu() -> UIMenu {
        let cameraAction = UIAction(title: "Camera",
                                    image: UIImage(systemName: "camera")) { [weak self] (_) in
            self?.presentCamera()
        }
        
        let galleryAction = UIAction(title: "Gallery",
                                     image: UIImage(systemName: "photo.on.rectangle")) { [weak self] (_) in
            self?.presentPhotoPicker()
        }
        
        return UIMenu(title: "Select Image", children: [cameraAction, galleryAction])
    }
    
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
    
    // Handle UIImagePickerController image selection
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
                               [UIImagePickerController.InfoKey: Any]) {
        var selectedImage: UIImage?
        
        // Use the edited image if available, otherwise the original image
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        // Convert the selected image to sRGB color space
        if let imageToConvert = selectedImage,
           let sRGBImage = convertToSRGB(imageToConvert) {
            self.selectedImage = sRGBImage
            // Update the cameraButton image
            updateCameraButtonImage()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Handle PHPicker image selection
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss the picker once the selection is made
        picker.dismiss(animated: true)
        
        // Extract the item providers from the results
        let itemProviders = results.map(\.itemProvider)
        
        // Iterate over each item provider to check and load images
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    DispatchQueue.main.async {
                        // Ensure the image is valid
                        if let pickedImage = image as? UIImage,
                           let sRGBImage = self?.convertToSRGB(pickedImage) {
                            self?.selectedImage = sRGBImage
                            // Update the cameraButton image
                            self?.updateCameraButtonImage()
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Convert image to sRGB color space
    func convertToSRGB(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        context?.draw(cgImage,
                      in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        if let convertedCGImage = context?.makeImage() {
            return UIImage(cgImage: convertedCGImage)
        }
        return nil
    }
    
    // Update the cameraButton image based on whether an image is selected
    private func updateCameraButtonImage() {
        DispatchQueue.main.async {
            if self.selectedImage != nil {
                self.addBillView.cameraButton.setImage(UIImage(systemName: "camera.fill"),
                                                       for: .normal)
            } else {
                self.addBillView.cameraButton.setImage(UIImage(systemName: "camera"),
                                                       for: .normal)
            }
        }
    }
}

// MARK: - PeopleSliderViewDelegate for Payer and Involvers
extension AddBillViewController: PeopleSliderViewDelegate {

    func didRequestRemovePerson(_ personId: UUID?) {
        // Handle removing a person, if needed
    }

    func didTapAddPerson(for tripId: UUID?) {
        // Handle adding a person, if needed
    }

    func didSelectPerson(_ personId: UUID?, for tripId: UUID?, context: SliderContext) {
        guard let personId = personId else {
            print("Person ID is nil, no action taken.")
            return
        }

        switch context {
        case .payer:
            // Toggle the selected payer ID
            if selectedPayerId == personId {
                selectedPayerId = nil
            } else {
                selectedPayerId = personId
            }
            addBillView.payerSliderView.selectedPayerId = selectedPayerId
            addBillView.payerSliderView.reload()

        case .involver:
            // Toggle the selected involvers
            if selectedInvolverIds.contains(personId) {
                selectedInvolverIds.removeAll { $0 == personId }
            } else {
                selectedInvolverIds.append(personId)
            }
            addBillView.involversSliderView.selectedInvolverIds = selectedInvolverIds
            addBillView.involversSliderView.reload()
        }
    }
}
