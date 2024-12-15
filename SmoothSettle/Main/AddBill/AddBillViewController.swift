//
//  AddBillViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import UIKit
import PhotosUI
import AVFoundation // Needed for camera permission checks

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
    
    // Localized Strings
    let invalidAlertTitle = String(localized: "missing_info")
    let fillAllAlertMessage = String(localized: "fill_all_message")
    let ok = String(localized: "OK")
    
    // Store selected payer and involvers by UUID
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
        
        // Recognize taps on the app screen to dismiss the keyboard
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        // Configure modal presentation style for iOS 15 and above
        if #available(iOS 15.0, *) {
            self.modalPresentationStyle = .pageSheet
            let requiredHeight = calculateRequiredHeight()
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customHeight")) { _ in
                return requiredHeight
            }
            
            self.sheetPresentationController?.detents = [customDetent]
            self.sheetPresentationController?.prefersGrabberVisible = false
        } else {
            self.modalPresentationStyle = .formSheet
        }
        
        // Ensure navigation bar appearance consistency
        if #available(iOS 15.0, *) {
            self.navigationController?.navigationBar.scrollEdgeAppearance =
                self.navigationController?.navigationBar.standardAppearance
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set delegates for the slider views
        addBillView.involversSliderView.delegate = self
        addBillView.payerSliderView.delegate = self
        
        // Allow selection in both slider views
        addBillView.payerSliderView.allowSelection = true
        addBillView.involversSliderView.allowSelection = true
        
        // Set the context for each slider view
        addBillView.payerSliderView.context = .payer
        addBillView.involversSliderView.context = .involver
        
        // Assign the people data to both slider views
        addBillView.payerSliderView.people = people
        addBillView.involversSliderView.people = people
        
        // Select all involvers by default
        selectedInvolverIds = people.map { $0.id } // Populate with all UUIDs
        addBillView.involversSliderView.selectedInvolverIds = selectedInvolverIds
        
        // Reload the sliders to reflect the updated selections
        addBillView.payerSliderView.reload()
        addBillView.involversSliderView.reload()
    }

    private func setup() {
        // Setup Navigation Bar (transparent)
        navigationItem.title = String(localized: "add_bill")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: String(localized: "close_button"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "add_button"),
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
        var missingFields: [String] = []
        
        // Validate Title
        let titleText = addBillView.billTitleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if titleText == nil || titleText!.isEmpty {
            missingFields.append(String(localized: "bill_title"))
            print("Invalid title")
        }
        
        // Validate Amount
        let amountText = addBillView.amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        var amountValue: Double?
        if let amountStr = amountText, !amountStr.isEmpty, let amount = Double(amountStr) {
            amountValue = amount
        } else {
            missingFields.append(String(localized: "bill_amount"))
            print("Invalid amount")
        }
        
        // Validate Payer
        if selectedPayerId == nil {
            missingFields.append(String(localized: "bill_payer"))
            print("Invalid payer")
        }
        
        // If any fields are missing, show an alert
        if !missingFields.isEmpty {
            print("Missing fields: \(missingFields)")
            let fields = missingFields.joined(separator: ", ")
         //   let message = String(format: String(localized: "missing_fields_message"), fields)
            let message = fields
            let alert = UIAlertController(title: invalidAlertTitle,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ok, style: .default))
            present(alert, animated: true)
            return
        }
        
        // All required fields are present
        guard let title = titleText,
              let amount = amountValue,
              let payerId = selectedPayerId else {
            // This should never happen, but added for safety
            let alert = UIAlertController(title: invalidAlertTitle,
                                          message: String(localized: "unexpected_error_message"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ok, style: .default))
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
    
    // MARK: - Dismissing the Keyboard
    @objc func hideKeyboardOnTap(){
        view.endEditing(true)
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
        alert.addAction(UIAlertAction(title: ok, style: .default))
        present(alert, animated: true)
    }
    
    // Get the image picker menu
    private func getImagePickerMenu() -> UIMenu {
        let cameraAction = UIAction(title: String(localized: "camera"),
                                    image: UIImage(systemName: "camera")) { [weak self] (_) in
            self?.presentCamera()
        }
        
        let galleryAction = UIAction(title: String(localized: "gallery"),
                                     image: UIImage(systemName: "photo.on.rectangle")) { [weak self] (_) in
            self?.presentPhotoPicker()
        }
        
        return UIMenu(title: String(localized: "select_image"), children: [cameraAction, galleryAction])
    }
    
    func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: String(localized: "camera_not_available"))
            return
        }
        
        // Check camera authorization status
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showImagePicker(sourceType: .camera)
                    } else {
                        self.showPermissionDeniedAlert(for: String(localized: "camera"))
                    }
                }
            }
        case .authorized:
            // Permission granted
            showImagePicker(sourceType: .camera)
        case .denied, .restricted:
            // Permission denied
            showPermissionDeniedAlert(for: String(localized: "camera"))
        @unknown default:
            break
        }
    }
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // Show Image Picker Helper Method
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    // Show Permission Denied Alert
    private func showPermissionDeniedAlert(for resource: String) {
        let alert = UIAlertController(title: String(localized: "access_denied_title"),
                                      message: String(format: String(localized: "access_denied_message"), resource.lowercased()),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "open_settings"), style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: String(localized: "cancel"), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // Handle UIImagePickerController image selection
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
                               [UIImagePickerController.InfoKey: Any]) {
        var selectedImageLocal: UIImage?
        
        // Use the edited image if available, otherwise the original image
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageLocal = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageLocal = originalImage
        }
        
        // Convert the selected image to sRGB color space
        if let imageToConvert = selectedImageLocal,
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
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        guard let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage,
                    in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        if let convertedCGImage = context.makeImage() {
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
            // No action taken if personId is nil
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
