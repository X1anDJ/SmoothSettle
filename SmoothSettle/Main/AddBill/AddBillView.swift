//
//  AddBillView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/14.
//

import UIKit

class AddBillView: UIView {
    
    // UI Elements
    let billTitleTextField = UITextField()
    let amountTextField = UITextField()
    let payerSliderView = PeopleSliderView()
    let involversSliderView = PeopleSliderView()
    
    // Buttons
    let cameraButton = UIButton()
//    let currencyButton = UIButton()
    
    // Date Picker
    let datePicker = UIDatePicker()
    
    // Section labels
    let billTitleSectionLabel = UILabel()
    let amountSectionLabel = UILabel()
    let payerSectionLabel = UILabel()
    let involversSectionLabel = UILabel()
    
    // Initialize with frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    // Required initializer (for using from storyboard or XIB)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        style()
        layout()
    }
    
    private func style() {
        backgroundColor = Colors.background1
        layer.cornerRadius = 16
        clipsToBounds = true
        
        // Bill Title Section Label
        billTitleSectionLabel.text = String(localized: "bill_title")
        billTitleSectionLabel.font = UIFont.systemFont(ofSize: 14)
        billTitleSectionLabel.textColor = .gray
        billTitleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Bill Title TextField
        billTitleTextField.placeholder = String(localized: "enter_bill_title")
        billTitleTextField.borderStyle = .roundedRect
        billTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Camera Button
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        cameraButton.tintColor = UIColor.systemBlue
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.layer.cornerRadius = 8
        cameraButton.backgroundColor = Colors.background0
        cameraButton.imageView?.contentMode = .scaleAspectFit
        cameraButton.clipsToBounds = true
        
        // Date Picker
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount Section Label
        amountSectionLabel.text = String(localized: "Amount")
        amountSectionLabel.font = UIFont.systemFont(ofSize: 14)
        amountSectionLabel.textColor = .gray
        amountSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount TextField
        amountTextField.placeholder = String(localized: "enter_amount")
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
//        // Currency Button
//        currencyButton.setTitle("USD", for: .normal)
//        currencyButton.setTitleColor(UIColor.systemBlue, for: .normal)
//        currencyButton.translatesAutoresizingMaskIntoConstraints = false
//        currencyButton.layer.cornerRadius = 8
//        currencyButton.backgroundColor = Colors.background0
        
        // Payer Section Label
        let payerSectionLabelLocalized = String(localized: "payer")
        payerSectionLabel.text = payerSectionLabelLocalized
        payerSectionLabel.font = UIFont.systemFont(ofSize: 14)
        payerSectionLabel.textColor = .gray
        payerSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Payer Slider View
        payerSliderView.translatesAutoresizingMaskIntoConstraints = false
        
        // Involvers Section Label
        let involversSectionLabelLocalized = String(localized: "participants")
        involversSectionLabel.text = involversSectionLabelLocalized
        involversSectionLabel.font = UIFont.systemFont(ofSize: 14)
        involversSectionLabel.textColor = .gray
        involversSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Involvers Slider View
        involversSliderView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layout() {
        addSubview(billTitleSectionLabel)
        addSubview(billTitleTextField)
        addSubview(cameraButton)
        addSubview(datePicker)
        addSubview(amountSectionLabel)
        addSubview(amountTextField)
//        addSubview(currencyButton)
        addSubview(payerSectionLabel)
        addSubview(payerSliderView)
        addSubview(involversSectionLabel)
        addSubview(involversSliderView)
        
        NSLayoutConstraint.activate([
            // Bill Title Section
            billTitleSectionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            billTitleSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            billTitleSectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Camera Button
            cameraButton.centerYAnchor.constraint(equalTo: billTitleTextField.centerYAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cameraButton.widthAnchor.constraint(equalToConstant: 44),
            cameraButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Date Picker
            datePicker.centerYAnchor.constraint(equalTo: billTitleTextField.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: cameraButton.leadingAnchor, constant: -8),
            
            // Bill Title TextField
            billTitleTextField.topAnchor.constraint(equalTo: billTitleSectionLabel.bottomAnchor, constant: 8),
            billTitleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            billTitleTextField.trailingAnchor.constraint(equalTo: datePicker.leadingAnchor, constant: -8),
            billTitleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Amount Section
            amountSectionLabel.topAnchor.constraint(equalTo: billTitleTextField.bottomAnchor, constant: 16),
            amountSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            amountSectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Amount TextField
            amountTextField.topAnchor.constraint(equalTo: amountSectionLabel.bottomAnchor, constant: 8),
            amountTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            amountTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Payer Section
            payerSectionLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 16),
            payerSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            payerSectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            payerSliderView.topAnchor.constraint(equalTo: payerSectionLabel.bottomAnchor, constant: 8),
            payerSliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            payerSliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            payerSliderView.heightAnchor.constraint(equalToConstant: 80),
            
            // Involvers Section
            involversSectionLabel.topAnchor.constraint(equalTo: payerSliderView.bottomAnchor, constant: 16),
            involversSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            involversSectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            involversSliderView.topAnchor.constraint(equalTo: involversSectionLabel.bottomAnchor, constant: 8),
            involversSliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            involversSliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            involversSliderView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
}
