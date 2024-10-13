//
//  UserCircleView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import Foundation
import UIKit

class UserCircleView: UIView {

    enum CircleStyle {
        case style1  // Frame with border
        case style2  // Full background color
    }

    init(style: CircleStyle, frame: CGRect) {
        super.init(frame: frame)
        setupView(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(style: CircleStyle) {
        // Customize the appearance based on the style
        switch style {
        case .style1:
            self.layer.borderWidth = 2
            self.layer.borderColor = Colors.accentOrange.cgColor
            self.backgroundColor = Colors.primaryThin
        case .style2:
            self.backgroundColor = Colors.accentOrange
        }
        
        // Round the view to make it a circle
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.masksToBounds = true
    }
}
