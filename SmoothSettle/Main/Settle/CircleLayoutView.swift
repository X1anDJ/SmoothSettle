//
//  CircleLayoutView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import UIKit

class CircleLayoutView: UIView {
    
    // MARK: - Animation Properties
    
    /// Duration for connecting circles animation (Phase 1)
    private let connectUserCirclesDuration: TimeInterval = 1.0
    
    /// Duration for opacity and shadow animation (Phase 2)
    private let opacityShadowAnimationDuration: TimeInterval = 2.5
    
    /// Duration for line fade-out animation (Phase 3)
    private let fadeOutDuration: TimeInterval = 0.5
    
    /// Duration for rotation animation
    private let rotationDuration: TimeInterval = 28.0
    
    /// Shadow properties
    private let shadowRadius: CGFloat = 7.0
    private let shadowOpacity: Float = 0.95
    private let shadowColor: UIColor = Colors.accentOrange
    private let circleOpacity: Float = 0.2
    
    /// Line properties
    private let lineColor: CGColor = Colors.accentOrange.cgColor
    private let connectionLineWidth: CGFloat = 2.0
    
    // MARK: - Properties
    
    /// Array of user IDs (UUIDs) to be displayed in circles
    var userIds: [UUID] = []
    
    /// Simplified transactions data
    var transactions: [TransactionsTableView.Section] = []
    
    /// Size of each user circle
    private let circleSize: CGFloat = 30
    
    /// Flag to ensure circles are laid out only once
    private var circlesLaidOut = false
    
    /// Array to store active lines with associated user IDs
    private var lines: [(CAShapeLayer, UUID, UUID)] = []
    
    /// Array to store lines that can be removed (no transactions between users)
    private var removableLines: [(CAShapeLayer, UUID, UUID)] = []
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup Methods
    
    /// Configures the initial view properties
    private func setupView() {
        backgroundColor = .clear
    }
    
    /// Sets up user circles and connection lines
    private func setupUserCirclesAndLines() {
        // Remove any existing user circles or lines
        self.subviews.forEach { $0.removeFromSuperview() }
        self.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }
        
        guard userIds.count > 0 else { return }
        
        // Calculate the radius of the invisible circle (1/3 of the view's width)
        let radius = self.bounds.width / 3
        let centerX = self.bounds.width / 2
        let centerY = self.bounds.height / 2
        
        // Start from the 12 o'clock direction (angle = 0 radians)
        let startAngle: CGFloat = -CGFloat.pi / 2  // 12 o'clock is -90 degrees
        
        // Calculate the angle between each userCircle based on the number of people
        let angleIncrement = CGFloat(2 * Double.pi) / CGFloat(userIds.count)
        
        // Loop through each user and create a UserCircleView
        for (index, userId) in userIds.enumerated() {
            let angle = startAngle + angleIncrement * CGFloat(index)
            let xPosition = centerX + radius * cos(angle)
            let yPosition = centerY + radius * sin(angle)
            let style: UserCircleView.CircleStyle = (index % 2 == 0) ? .style2 : .style1
            
            let userCircle = UserCircleView(style: style, frame: CGRect(x: xPosition - circleSize / 2, y: yPosition - circleSize / 2, width: circleSize, height: circleSize))
            self.addSubview(userCircle)
        }
        
        // Start the first phase of connection animation
        connectAllCirclesWithLines()
    }
    
    /// Connects each user circle to all other user circles with animated lines
    private func connectAllCirclesWithLines() {
        guard userIds.count > 1 else { return }
        
        for (i, circle1) in subviews.enumerated() {
            // Each user only connects to subsequent users, so we start the loop from the next user
            for j in (i + 1)..<subviews.count {
                let circle2 = subviews[j]
                let fromUserId = userIds[i]
                let toUserId = userIds[j]
                
                let startPoint = offsetPoint(
                    from: circle1.center,
                    to: circle2.center,
                    offset: circleSize / 2
                )
                let endPoint = offsetPoint(
                    from: circle2.center,
                    to: circle1.center,
                    offset: circleSize / 2
                )
                
                drawAnimatedLine(
                    from: startPoint,
                    to: endPoint,
                    fromUserId: fromUserId,
                    toUserId: toUserId
                )
            }
        }
    }
    
    /// Draws an animated line between two points and stores it
    private func drawAnimatedLine(
        from startPoint: CGPoint,
        to endPoint: CGPoint,
        fromUserId: UUID,
        toUserId: UUID
    ) {
        let line = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        line.path = path.cgPath
        line.strokeColor = lineColor
        line.lineWidth = connectionLineWidth
        line.lineCap = .round
        line.strokeEnd = 0.0
        
        layer.addSublayer(line)
        lines.append((line, fromUserId, toUserId))
        
        // Determine if the line should be removable
        if !transactionsExistBetween(from: fromUserId, to: toUserId) &&
           !transactionsExistBetween(from: toUserId, to: fromUserId) {
            removableLines.append((line, fromUserId, toUserId))
        }
        
        // Animate the line drawing
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = connectUserCirclesDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        line.add(animation, forKey: "lineAnimation")
    }
    
    /// Checks if a transaction exists between two users
    private func transactionsExistBetween(from fromUserId: UUID, to toUserId: UUID) -> Bool {
        for section in transactions {
//            if section.fromId == fromUserId {
//                for transaction in section.transactions {
//                    if transaction.toId == toUserId {
//                        return true
//                    }
//                }
//            }
            if section.fromPerson.id == fromUserId {
                for transaction in section.transactions {
                    if transaction.toPerson.id == toUserId {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    /// Calculates an offset point along the direction from startPoint to endPoint
    private func offsetPoint(from startPoint: CGPoint, to endPoint: CGPoint, offset: CGFloat) -> CGPoint {
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let distance = sqrt(dx * dx + dy * dy)
        
        guard distance != 0 else { return startPoint }
        
        let ratio = offset / distance
        let offsetX = dx * ratio
        let offsetY = dy * ratio
        
        return CGPoint(x: startPoint.x + offsetX, y: startPoint.y + offsetY)
    }
    
    /// Starts a continuous rotation animation on the entire view
    private func startRotationAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi  // Full rotation (360 degrees)
        rotation.duration = rotationDuration  // 25 seconds for one complete rotation
        rotation.repeatCount = .infinity  // Repeat forever
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    /// Animates the opacity and shadow of all user circles
    private func animateOpacityAndShadow() {
        // Iterate through all UserCircleView subviews
        for userCircle in subviews.compactMap({ $0 as? UserCircleView }) {
            let shadowLayer = userCircle.shadowContainerView.layer
            
            // Ensure the shadowPath is set
            shadowLayer.shadowPath = UIBezierPath(ovalIn: userCircle.shadowContainerView.bounds).cgPath
            
            // Animate Opacity
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1.0
            opacityAnimation.toValue = circleOpacity
            opacityAnimation.duration = opacityShadowAnimationDuration / 2
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            opacityAnimation.autoreverses = true  // Automatically reverse to original opacity
            opacityAnimation.repeatCount = 1
            
            // Animate Shadow Opacity
            let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowOpacityAnimation.fromValue = 0.0
            shadowOpacityAnimation.toValue = shadowOpacity
            shadowOpacityAnimation.duration = opacityShadowAnimationDuration / 2
            shadowOpacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shadowOpacityAnimation.autoreverses = true  // Automatically reverse to original shadow opacity
            shadowOpacityAnimation.repeatCount = 1
            
            // Animate Shadow Radius
            let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
            shadowRadiusAnimation.fromValue = 0.0
            shadowRadiusAnimation.toValue = shadowRadius
            shadowRadiusAnimation.duration = opacityShadowAnimationDuration / 2
            shadowRadiusAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shadowRadiusAnimation.autoreverses = true
            shadowRadiusAnimation.repeatCount = 1
            
            // Group Animations
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [opacityAnimation, shadowOpacityAnimation, shadowRadiusAnimation]
            animationGroup.duration = opacityShadowAnimationDuration
            animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animationGroup.fillMode = .forwards
            animationGroup.isRemovedOnCompletion = false
            
            // Apply Shadow Properties Initially
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
            shadowLayer.shadowOpacity = 0.0
            shadowLayer.shadowRadius = 0.0
            
            // Add the animation group to the layer
            shadowLayer.add(animationGroup, forKey: "opacityShadowAnimation")
        }
        
        // Schedule to remove shadows after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + opacityShadowAnimationDuration) {
            self.removeShadows()
        }
    }
    
    /// Removes shadows from all user circles
    private func removeShadows() {
        for userCircle in subviews.compactMap({ $0 as? UserCircleView }) {
            let shadowLayer = userCircle.shadowContainerView.layer
            shadowLayer.shadowOpacity = 0.0
            shadowLayer.shadowRadius = 0.0
            shadowLayer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    /// Disconnects and removes lines that have no associated transactions
    private func disconnectRemovableLines() {
        for (line, _, _) in removableLines {
            // Animate line fade-out
            let fadeOut = CABasicAnimation(keyPath: "opacity")
            fadeOut.fromValue = 1.0
            fadeOut.toValue = 0.0
            fadeOut.duration = fadeOutDuration
            fadeOut.fillMode = .forwards
            fadeOut.isRemovedOnCompletion = false
            fadeOut.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            line.add(fadeOut, forKey: "fadeOutAnimation")
            
            // Remove the line from the layer after the animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut.duration) {
                line.removeFromSuperlayer()
            }
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !circlesLaidOut else { return }
        
        setupUserCirclesAndLines()
        circlesLaidOut = true
        startRotationAnimation()
        
        // Schedule opacity and shadow animation after connection animation
        DispatchQueue.main.asyncAfter(deadline: .now() + connectUserCirclesDuration) {
            self.animateOpacityAndShadow()
        }
        
        // Calculate the delay for the fade-out to occur at the middle of the opacity-shadow animation
        let fadeOutDelay = connectUserCirclesDuration + (self.opacityShadowAnimationDuration / 2)
        
        // Schedule the disconnection of removable lines at the middle of opacityShadowAnimationDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay) {
            self.disconnectRemovableLines()
        }
    }
}











////
////  CircleLayoutView.swift
////  SmoothSettle
////
////  Created by Dajun Xian on 2024/10/12.
////
//
//import UIKit
//
//// MARK: - CGPath Extension
//
//extension CGPath {
//    /// Retrieves all points from the CGPath in order.
//    func getPoints() -> [CGPoint] {
//        var points: [CGPoint] = []
//        self.applyWithBlock { element in
//            switch element.pointee.type {
//            case .moveToPoint, .addLineToPoint:
//                points.append(element.pointee.points[0])
//            case .addQuadCurveToPoint, .addCurveToPoint:
//                points.append(element.pointee.points[0])
//                points.append(element.pointee.points[1])
//            case .closeSubpath:
//                break
//            @unknown default:
//                break
//            }
//        }
//        return points
//    }
//}
//
//class CircleLayoutView: UIView {
//    
//    // MARK: - Animation Durations
//    
//    // Phase 1: Connecting Lines
//    private let connectUserCirclesDuration: TimeInterval = 1.5
//    
//    // Phase 2: Opacity and Shadow Animations
//    private let opacityShadowAnimationDuration: TimeInterval = 2.0
//    private let dotAnimationDuration: TimeInterval = 1.0
//    
//    // Phase 3: Disconnecting Lines
//    private let disconnectLinesDuration: TimeInterval = 1.0
//    
//    // Additional Animations
//    private let rotationDuration: TimeInterval = 25.0
//    
//    // MARK: - Animation Properties
//    
//    /// Shadow properties
//    private let shadowRadius: CGFloat = 5.0
//    private let shadowOpacity: Float = 0.8
//    private let shadowColor: UIColor = Colors.accentOrange
//    
//    /// Line properties
//    private let lineColor: CGColor = Colors.accentOrange.cgColor
//    private let connectionLineWidth: CGFloat = 2.0
//    
//    /// Transmitting Dot Properties
//    private let dotSize: CGFloat = 2.0
//    private let dotColor: UIColor = Colors.accentOrange
//    private let dotOpacity: Float = 1.0
//    
//    // MARK: - Properties
//    
//    /// Array of user IDs (UUIDs) to be displayed in circles
//    var userIds: [UUID] = [] {
//        didSet {
//            setNeedsLayout()
//        }
//    }
//    
//    /// Simplified transactions data
//    var transactions: [TransactionsTableView.Section] = []
//    
//    /// Size of each user circle
//    private let circleSize: CGFloat = 30
//    
//    /// Flag to ensure circles are laid out only once
//    private var circlesLaidOut = false
//    
//    /// Array to store active lines with associated user IDs
//    private var lines: [(CAShapeLayer, UUID, UUID)] = []
//    
//    /// Array to store lines that can be removed (no transactions between users)
//    private var removableLines: [(CAShapeLayer, UUID, UUID)] = []
//    
//    /// Array to store transmitting dots
//    private var transmittingDots: [CAShapeLayer] = []
//    
//    // MARK: - Initializers
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    // MARK: - Setup Methods
//    
//    /// Configures the initial view properties
//    private func setupView() {
//        backgroundColor = .clear
//    }
//    
//    /// Sets up user circles and connection lines
//    private func setupUserCirclesAndLines() {
//        // Remove any existing user circles or lines
//        self.subviews.forEach { $0.removeFromSuperview() }
//        self.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }
//        
//        // Clear previous transmitting dots
//        removeTransmittingDots()
//        transmittingDots.removeAll()
//        
//        guard userIds.count > 0 else { return }
//        
//        // Calculate the radius of the invisible circle (1/3 of the view's width)
//        let radius = self.bounds.width / 3
//        let centerX = self.bounds.width / 2
//        let centerY = self.bounds.height / 2
//        
//        // Start from the 12 o'clock direction (angle = -90 degrees)
//        let startAngle: CGFloat = -CGFloat.pi / 2  // 12 o'clock is -90 degrees
//        
//        // Calculate the angle between each userCircle based on the number of people
//        let angleIncrement = CGFloat(2 * Double.pi) / CGFloat(userIds.count)
//        
//        // Loop through each user and create a UserCircleView
//        for (index, userId) in userIds.enumerated() {
//            let angle = startAngle + angleIncrement * CGFloat(index)
//            let xPosition = centerX + radius * cos(angle)
//            let yPosition = centerY + radius * sin(angle)
//            let style: UserCircleView.CircleStyle = (index % 2 == 0) ? .style2 : .style1
//            
//            let userCircle = UserCircleView(style: style, frame: CGRect(x: xPosition - circleSize / 2,
//                                                                        y: yPosition - circleSize / 2,
//                                                                        width: circleSize,
//                                                                        height: circleSize))
//            self.addSubview(userCircle)
//        }
//        
//        // Start the first phase of connection animation
//        connectAllCirclesWithLines()
//    }
//    
//    /// Connects each user circle to all other user circles with animated lines
//    private func connectAllCirclesWithLines() {
//        guard userIds.count > 1 else { return }
//        
//        for (i, circle1) in subviews.enumerated() {
//            // Each user only connects to subsequent users, so we start the loop from the next user
//            for j in (i + 1)..<subviews.count {
//                let circle2 = subviews[j]
//                let fromUserId = userIds[i]
//                let toUserId = userIds[j]
//                
//                let startPoint = offsetPoint(
//                    from: circle1.center,
//                    to: circle2.center,
//                    offset: circleSize / 2
//                )
//                let endPoint = offsetPoint(
//                    from: circle2.center,
//                    to: circle1.center,
//                    offset: circleSize / 2
//                )
//                
//                drawAnimatedLine(
//                    from: startPoint,
//                    to: endPoint,
//                    fromUserId: fromUserId,
//                    toUserId: toUserId
//                )
//            }
//        }
//    }
//    
//    /// Draws an animated line between two points and stores it
//    private func drawAnimatedLine(
//        from startPoint: CGPoint,
//        to endPoint: CGPoint,
//        fromUserId: UUID,
//        toUserId: UUID
//    ) {
//        let line = CAShapeLayer()
//        let path = UIBezierPath()
//        path.move(to: startPoint)
//        path.addLine(to: endPoint)
//        
//        line.path = path.cgPath
//        line.strokeColor = lineColor
//        line.lineWidth = connectionLineWidth
//        line.lineCap = .round
//        line.strokeEnd = 0.0
//        line.opacity = 0.5  // Set initial opacity to 0.5
//        
//        layer.addSublayer(line)
//        lines.append((line, fromUserId, toUserId))
//        
//        // Determine if the line should be removable
//        if !transactionsExistBetween(from: fromUserId, to: toUserId) &&
//            !transactionsExistBetween(from: toUserId, to: fromUserId) {
//            removableLines.append((line, fromUserId, toUserId))
//        }
//        
//        // Animate the line drawing
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = 0.0
//        animation.toValue = 1.0
//        animation.duration = connectUserCirclesDuration
//        animation.fillMode = .forwards
//        animation.isRemovedOnCompletion = false
//        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        line.add(animation, forKey: "lineAnimation")
//    }
//    
//    /// Checks if a transaction exists between two users
//    private func transactionsExistBetween(from fromUserId: UUID, to toUserId: UUID) -> Bool {
//        for section in transactions {
//            if section.fromId == fromUserId {
//                for transaction in section.transactions {
//                    if transaction.toId == toUserId {
//                        return true
//                    }
//                }
//            }
//        }
//        return false
//    }
//    
//    /// Calculates an offset point along the direction from startPoint to endPoint
//    private func offsetPoint(from startPoint: CGPoint, to endPoint: CGPoint, offset: CGFloat) -> CGPoint {
//        let dx = endPoint.x - startPoint.x
//        let dy = endPoint.y - startPoint.y
//        let distance = sqrt(dx * dx + dy * dy)
//        
//        guard distance != 0 else { return startPoint }
//        
//        let ratio = offset / distance
//        let offsetX = dx * ratio
//        let offsetY = dy * ratio
//        
//        return CGPoint(x: startPoint.x + offsetX, y: startPoint.y + offsetY)
//    }
//    
//    /// Starts a continuous rotation animation on the entire view
//    private func startRotationAnimation() {
//        let rotation = CABasicAnimation(keyPath: "transform.rotation")
//        rotation.fromValue = 0
//        rotation.toValue = 2 * Double.pi  // Full rotation (360 degrees)
//        rotation.duration = rotationDuration  // 25 seconds for one complete rotation
//        rotation.repeatCount = .infinity  // Repeat forever
//        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
//        layer.add(rotation, forKey: "rotationAnimation")
//    }
//    
//    /// Animates the opacity and shadow of all user circles and adds transmitting dots to connection lines.
//    private func animateOpacityAndShadow() {
//        // Iterate through all UserCircleView subviews
//        for userCircle in subviews.compactMap({ $0 as? UserCircleView }) {
//            let shadowLayer = userCircle.shadowContainerView.layer
//            
//            // Ensure the shadowPath is set
//            shadowLayer.shadowPath = UIBezierPath(ovalIn: userCircle.shadowContainerView.bounds).cgPath
//            
//            // Animate Opacity
//            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
//            opacityAnimation.fromValue = 1.0
//            opacityAnimation.toValue = 0.7
//            opacityAnimation.duration = opacityShadowAnimationDuration / 2
//            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            opacityAnimation.autoreverses = true  // Automatically reverse to original opacity
//            opacityAnimation.repeatCount = 1
//            
//            // Animate Shadow Opacity
//            let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
//            shadowOpacityAnimation.fromValue = 0.0
//            shadowOpacityAnimation.toValue = shadowOpacity
//            shadowOpacityAnimation.duration = opacityShadowAnimationDuration / 2
//            shadowOpacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            shadowOpacityAnimation.autoreverses = true  // Automatically reverse to original shadow opacity
//            shadowOpacityAnimation.repeatCount = 1
//            
//            // Animate Shadow Radius
//            let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
//            shadowRadiusAnimation.fromValue = 0.0
//            shadowRadiusAnimation.toValue = shadowRadius
//            shadowRadiusAnimation.duration = opacityShadowAnimationDuration / 2
//            shadowRadiusAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            shadowRadiusAnimation.autoreverses = true
//            shadowRadiusAnimation.repeatCount = 1
//            
//            // Group Animations
//            let animationGroup = CAAnimationGroup()
//            animationGroup.animations = [opacityAnimation, shadowOpacityAnimation, shadowRadiusAnimation]
//            animationGroup.duration = opacityShadowAnimationDuration
//            animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            animationGroup.fillMode = .forwards
//            animationGroup.isRemovedOnCompletion = false
//            
//            // Apply Shadow Properties Initially
//            shadowLayer.shadowColor = shadowColor.cgColor
//            shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
//            shadowLayer.shadowOpacity = 0.0
//            shadowLayer.shadowRadius = 0.0
//            
//            // Add the animation group to the layer
//            shadowLayer.add(animationGroup, forKey: "opacityShadowAnimation")
//        }
//        
//        // Add transmitting dots to all connection lines
//        for line in lines {
//            addTransmittingDots(to: line.0)
//        }
//        
//        // Schedule to remove shadows and transmitting dots after animation completes
//        DispatchQueue.main.asyncAfter(deadline: .now() + opacityShadowAnimationDuration) {
//            self.removeShadows()
//            self.removeTransmittingDots()
//            self.animateRemainingLinesToFullOpacity()
//        }
//    }
//    
//    /// Removes shadows from all user circles
//    private func removeShadows() {
//        for userCircle in subviews.compactMap({ $0 as? UserCircleView }) {
//            let shadowLayer = userCircle.shadowContainerView.layer
//            shadowLayer.shadowOpacity = 0.0
//            shadowLayer.shadowRadius = 0.0
//            shadowLayer.shadowColor = UIColor.clear.cgColor
//        }
//    }
//    
//    /// Disconnects and removes lines that have no associated transactions
//    private func disconnectRemovableLines() {
//        for (line, _, _) in removableLines {
//            // Animate line fade-out
//            let fadeOut = CABasicAnimation(keyPath: "opacity")
//            fadeOut.fromValue = 0.5
//            fadeOut.toValue = 0.0
//            fadeOut.duration = disconnectLinesDuration
//            fadeOut.fillMode = .forwards
//            fadeOut.isRemovedOnCompletion = false
//            fadeOut.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            line.add(fadeOut, forKey: "fadeOutAnimation")
//            
//            // Remove the line from the layer after the animation completes
//            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut.duration) {
//                line.removeFromSuperlayer()
//            }
//        }
//    }
//    
//    /// Animates remaining lines to full opacity (1.0)
//    private func animateRemainingLinesToFullOpacity() {
//        for (line, _, _) in lines {
//            // Check if the line is not in removableLines
//            let isRemovable = removableLines.contains { $0.0 == line }
//            if !isRemovable {
//                // Animate opacity to 1.0
//                let opacityAnimation = CABasicAnimation(keyPath: "opacity")
//                opacityAnimation.fromValue = 0.5
//                opacityAnimation.toValue = 1.0
//                opacityAnimation.duration = disconnectLinesDuration
//                opacityAnimation.fillMode = .forwards
//                opacityAnimation.isRemovedOnCompletion = false
//                opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//                line.add(opacityAnimation, forKey: "increaseOpacityAnimation")
//                
//                // Set the final opacity to 1.0 to maintain state after animation
//                line.opacity = 1.0
//            }
//        }
//    }
//    
//    // MARK: - Transmitting Dots Methods
//    
//    /// Creates and configures a transmitting dot layer.
//    /// - Returns: A configured CAShapeLayer representing the dot.
//    private func createDotLayer() -> CAShapeLayer {
//        let dotLayer = CAShapeLayer()
//        let dotPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
//        dotLayer.path = dotPath.cgPath
//        dotLayer.fillColor = dotColor.cgColor
//        dotLayer.opacity = dotOpacity
//        dotLayer.bounds = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
//        return dotLayer
//    }
//    
//    /// Creates a position animation for the dot along the given path.
//    /// - Parameter path: The CGPath along which the dot will move.
//    /// - Returns: A configured CAKeyframeAnimation for the dot's position.
//    private func createPositionAnimation(for path: CGPath) -> CAKeyframeAnimation {
//        let animation = CAKeyframeAnimation(keyPath: "position")
//        animation.path = path
//        animation.duration = dotAnimationDuration
//        animation.repeatCount = .infinity
//        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        animation.calculationMode = .paced
//        return animation
//    }
//    
//    /// Generates a reversed CGPath from the given path.
//    /// - Parameter path: The original CGPath.
//    /// - Returns: A new CGPath that is the reverse of the original.
//    private func reversedPath(_ path: CGPath) -> CGPath? {
//        let points = path.getPoints()
//        if points.isEmpty { return nil }
//        
//        let mutablePath = CGMutablePath()
//        mutablePath.move(to: points.last!)
//        for point in points.reversed().dropFirst() {
//            mutablePath.addLine(to: point)
//        }
//        // Do not close the path to maintain it as an open line.
//        return mutablePath.copy()
//    }
//    
//    /// Adds transmitting dots to a given connection line.
//    /// - Parameter line: The CAShapeLayer representing the connection line.
//    private func addTransmittingDots(to line: CAShapeLayer) {
//        guard let path = line.path else { return }
//        guard let reversedCGPath = reversedPath(path) else { return }
//        
//        // Original Path Animation (From start to end)
//        let dotLayer1 = createDotLayer()
//        dotLayer1.position = startPoint(of: path)
//        let animation1 = createPositionAnimation(for: path)
//        dotLayer1.add(animation1, forKey: "transmitAnimation1")
//        layer.addSublayer(dotLayer1)
//        
//        // Reversed Path Animation (From end to start)
//        let dotLayer2 = createDotLayer()
//        dotLayer2.position = endPoint(of: path)
//        let animation2 = createPositionAnimation(for: reversedCGPath)
//        dotLayer2.add(animation2, forKey: "transmitAnimation2")
//        layer.addSublayer(dotLayer2)
//        
//        // Store the dot layers for later removal
//        transmittingDots.append(dotLayer1)
//        transmittingDots.append(dotLayer2)
//    }
//    
//    /// Retrieves the start point of a CGPath.
//    /// - Parameter path: The CGPath.
//    /// - Returns: The start CGPoint.
//    private func startPoint(of path: CGPath) -> CGPoint {
//        var start = CGPoint.zero
//        path.applyWithBlock { element in
//            if element.pointee.type == .moveToPoint {
//                start = element.pointee.points[0]
//            }
//        }
//        return start
//    }
//    
//    /// Retrieves the end point of a CGPath.
//    /// - Parameter path: The CGPath.
//    /// - Returns: The end CGPoint.
//    private func endPoint(of path: CGPath) -> CGPoint {
//        var end = CGPoint.zero
//        path.applyWithBlock { element in
//            switch element.pointee.type {
//            case .addLineToPoint:
//                end = element.pointee.points[0]
//            case .addQuadCurveToPoint:
//                end = element.pointee.points[1]
//            case .addCurveToPoint:
//                end = element.pointee.points[2]
//            case .closeSubpath:
//                break
//            default:
//                break
//            }
//        }
//        return end
//    }
//    
//    /// Removes all transmitting dots from the view.
//    private func removeTransmittingDots() {
//        for dot in transmittingDots {
//            dot.removeFromSuperlayer()
//        }
//        transmittingDots.removeAll()
//    }
//    
//    // MARK: - Layout
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        guard !circlesLaidOut else { return }
//        
//        setupUserCirclesAndLines()
//        circlesLaidOut = true
//        startRotationAnimation()
//        
//        // Schedule opacity and shadow animation after connection animation
//        DispatchQueue.main.asyncAfter(deadline: .now() + connectUserCirclesDuration) {
//            self.animateOpacityAndShadow()
//            
//            // Schedule the disconnection of removable lines after opacity and shadow animation
//            DispatchQueue.main.asyncAfter(deadline: .now() + self.opacityShadowAnimationDuration) {
//                self.disconnectRemovableLines()
//            }
//        }
//    }
//}
