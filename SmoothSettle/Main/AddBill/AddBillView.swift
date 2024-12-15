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
    let dateLabel = UILabel()
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
        backgroundColor = Colors.background0
        layer.cornerRadius = 14
        clipsToBounds = true
        
        let titleSize = CGFloat(16)
        
        // Bill Title Section Label
        billTitleSectionLabel.text = String(localized: "bill_title")
        billTitleSectionLabel.font = UIFont.systemFont(ofSize: titleSize, weight: .semibold)
        billTitleSectionLabel.textColor = Colors.primaryDark
        billTitleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Bill Title TextField
        billTitleTextField.placeholder = String(localized: "enter_bill_title")
        billTitleTextField.borderStyle = .roundedRect
        billTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        billTitleTextField.autocorrectionType = .no
        billTitleTextField.autocapitalizationType = .none
        billTitleTextField.backgroundColor = Colors.background1
        
        // Camera Button
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        cameraButton.tintColor = Colors.primaryDark
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.layer.cornerRadius = 5
        cameraButton.backgroundColor = Colors.background1
        cameraButton.imageView?.contentMode = .scaleAspectFit
        cameraButton.clipsToBounds = true
        
        // Date Picker
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.backgroundColor = Colors.background0
        datePicker.layer.cornerRadius = 5
        datePicker.clipsToBounds = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Amount Section Label
        amountSectionLabel.text = String(localized: "bill_amount")
        amountSectionLabel.font = UIFont.systemFont(ofSize: titleSize, weight: .semibold)
        amountSectionLabel.textColor = Colors.primaryDark
        amountSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount TextField
        amountTextField.placeholder = String(localized: "enter_amount")
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.backgroundColor = Colors.background1
        
//        // Currency Button
//        currencyButton.setTitle("USD", for: .normal)
//        currencyButton.setTitleColor(UIColor.systemBlue, for: .normal)
//        currencyButton.translatesAutoresizingMaskIntoConstraints = false
//        currencyButton.layer.cornerRadius = 8
//        currencyButton.backgroundColor = Colors.background0
        
        // Payer Section Label
        let payerSectionLabelLocalized = String(localized: "bill_payer")
        payerSectionLabel.text = payerSectionLabelLocalized
        payerSectionLabel.font = UIFont.systemFont(ofSize: titleSize, weight: .semibold)
        payerSectionLabel.textColor = Colors.primaryDark
        payerSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Payer Slider View
        payerSliderView.translatesAutoresizingMaskIntoConstraints = false
        payerSliderView.sliderType = .noAddButon
        
        // Involvers Section Label
        let involversSectionLabelLocalized = String(localized: "participants")
        involversSectionLabel.text = involversSectionLabelLocalized
        involversSectionLabel.font = UIFont.systemFont(ofSize: titleSize, weight: .semibold)
        involversSectionLabel.textColor = Colors.primaryDark
        involversSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Involvers Slider View
        involversSliderView.translatesAutoresizingMaskIntoConstraints = false
        involversSliderView.sliderType = .noAddButon

        
        // Date label styling
        dateLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        dateLabel.textColor = Colors.primaryDark
        dateLabel.backgroundColor = Colors.background1
        dateLabel.layer.cornerRadius = 5
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center
        // Important: label should NOT intercept touches
        dateLabel.isUserInteractionEnabled = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func layout() {
        addSubview(billTitleSectionLabel)
        addSubview(billTitleTextField)
        addSubview(cameraButton)
        addSubview(datePicker)
        addSubview(dateLabel)
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
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            datePicker.heightAnchor.constraint(equalToConstant: 44),
            
            dateLabel.centerYAnchor.constraint(equalTo: billTitleTextField.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: cameraButton.leadingAnchor, constant: -8),
            dateLabel.widthAnchor.constraint(equalToConstant: 120),
            dateLabel.heightAnchor.constraint(equalToConstant: 44),
            
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
            payerSliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16 ),
            payerSliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            payerSliderView.heightAnchor.constraint(equalToConstant: 88),
            
            // Involvers Section
            involversSectionLabel.topAnchor.constraint(equalTo: payerSliderView.bottomAnchor, constant: 16),
            involversSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            involversSectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            involversSliderView.topAnchor.constraint(equalTo: involversSectionLabel.bottomAnchor, constant: 8),
            involversSliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            involversSliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            involversSliderView.heightAnchor.constraint(equalToConstant: 88),
        ])
        
        updateLabelWithDate(datePicker.date)
    }
    @objc private func dateChanged() {
        updateLabelWithDate(datePicker.date)
    }
    
    private func updateLabelWithDate(_ date: Date) {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            dateLabel.text = String(localized: "Today")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            dateLabel.text = formatter.string(from: date)
        }
    }
    
}
