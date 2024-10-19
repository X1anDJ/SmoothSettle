
// MARK: - UserCircleView Implementation

//
//  UserCircleView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import UIKit

class UserCircleView: UIView {
    
    enum CircleStyle {
        case style1  // Frame with border
        case style2  // Full background color
    }
    
    // MARK: - Properties
    
    /// Container view to handle shadows
    let shadowContainerView = UIView()
    
    /// Inner circle view that displays the circle
    let innerCircleView = UIView()
    
    // MARK: - Initializers
    
    init(style: CircleStyle, frame: CGRect) {
        super.init(frame: frame)
        setupViews(style: style)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews(style: .style1)  // Default style
    }
    
    // MARK: - Setup Methods
    
    /// Configures the views and their properties
    private func setupViews(style: CircleStyle) {
        // Configure Shadow Container View
        shadowContainerView.frame = bounds
        shadowContainerView.backgroundColor = .clear
        shadowContainerView.layer.cornerRadius = bounds.width / 2
        shadowContainerView.layer.masksToBounds = false  // Allow shadows to be visible
        addSubview(shadowContainerView)
        
        // Configure Inner Circle View
        innerCircleView.frame = bounds
        innerCircleView.layer.cornerRadius = bounds.width / 2
        innerCircleView.layer.masksToBounds = true  // Clip to bounds for circular shape
        
        // Customize the appearance based on the style
        switch style {
        case .style1:
            innerCircleView.layer.borderWidth = 2
            innerCircleView.layer.borderColor = Colors.accentOrange.cgColor
            innerCircleView.backgroundColor = Colors.primaryThin
        case .style2:
            innerCircleView.backgroundColor = Colors.accentOrange
        }
        
        shadowContainerView.addSubview(innerCircleView)
        
        // Static Shadow Configuration for Testing (Optional)
        /*
        shadowContainerView.layer.shadowColor = Colors.accentOrange.cgColor
        shadowContainerView.layer.shadowOpacity = 0.8
        shadowContainerView.layer.shadowRadius = 5.0
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowContainerView.layer.shadowPath = UIBezierPath(ovalIn: shadowContainerView.bounds).cgPath
        */
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowContainerView.frame = bounds
        innerCircleView.frame = bounds
        shadowContainerView.layer.cornerRadius = bounds.width / 2
        innerCircleView.layer.cornerRadius = bounds.width / 2
        
        // Set the shadow path to match the circular shape
        shadowContainerView.layer.shadowPath = UIBezierPath(ovalIn: shadowContainerView.bounds).cgPath
    }
}
