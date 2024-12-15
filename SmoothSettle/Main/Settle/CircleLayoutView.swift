//
//  CircleLayoutView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import UIKit

class CircleLayoutView: UIView {
    
    // MARK: - Animation Properties
    
    private let connectUserCirclesDuration: TimeInterval = 1.0
    private let opacityShadowAnimationDuration: TimeInterval = 2.5
    private let fadeOutDuration: TimeInterval = 0.5
    
    private let rotationDuration: TimeInterval = 28.0
    
    private let shadowRadius: CGFloat = 7.0
    private let shadowOpacity: Float = 0.95
    private let shadowColor: UIColor = Colors.accentOrange
    private let circleOpacity: Float = 0.2
    
    private let lineColor: CGColor = Colors.accentOrange.cgColor
    private let connectionLineWidth: CGFloat = 2.0
    
    var userIds: [UUID] = []
    var transactions: [TransactionsTableView.Section] = []
    
    private let circleSize: CGFloat = 30
    private var circlesLaidOut = false
    
    private var lines: [(CAShapeLayer, UUID, UUID)] = []
    private var removableLines: [(CAShapeLayer, UUID, UUID)] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    private func setupUserCirclesAndLines() {
        self.subviews.forEach { $0.removeFromSuperview() }
        self.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }
        
        guard userIds.count > 0 else { return }
        
        let radius = self.bounds.width / 3
        let centerX = self.bounds.width / 2
        let centerY = self.bounds.height / 2
        let startAngle: CGFloat = -CGFloat.pi / 2
        let angleIncrement = CGFloat(2 * Double.pi) / CGFloat(userIds.count)
        
        for (index, userId) in userIds.enumerated() {
            let angle = startAngle + angleIncrement * CGFloat(index)
            let xPosition = centerX + radius * cos(angle)
            let yPosition = centerY + radius * sin(angle)
            let style: UserCircleView.CircleStyle = (index % 2 == 0) ? .style2 : .style1
            
            let userCircle = UserCircleView(style: style, frame: CGRect(x: xPosition - circleSize / 2, y: yPosition - circleSize / 2, width: circleSize, height: circleSize))
            self.addSubview(userCircle)
        }
        
        connectAllCirclesWithLines()
    }
    
    private func connectAllCirclesWithLines() {
        guard userIds.count > 1 else { return }
        
        for (i, circle1) in subviews.enumerated() {
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
        
        let fromToExists = transactionsExistBetween(from: fromUserId, to: toUserId)
        let toFromExists = transactionsExistBetween(from: toUserId, to: fromUserId)
        
        if !fromToExists && !toFromExists {
            removableLines.append((line, fromUserId, toUserId))
        } else {
            if fromToExists {
                addArrow(at: startPoint, pointingFrom: startPoint, to: endPoint)
            }
            if toFromExists {
                addArrow(at: endPoint, pointingFrom: endPoint, to: startPoint)
            }
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = connectUserCirclesDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        line.add(animation, forKey: "lineAnimation")
    }

    private func addArrow(at point: CGPoint, pointingFrom start: CGPoint, to end: CGPoint) {
        DispatchQueue.main.asyncAfter(deadline: .now() + connectUserCirclesDuration + opacityShadowAnimationDuration/1.7 ) { [weak self] in
            let arrowLength: CGFloat = 14.0
            let arrowWidth: CGFloat = 12.0
            
            let arrowPath = UIBezierPath()
            arrowPath.move(to: CGPoint(x: 0, y: 0))
            arrowPath.addLine(to: CGPoint(x: -arrowWidth/2, y: arrowLength))
            arrowPath.addLine(to: CGPoint(x: arrowWidth/2, y: arrowLength))
            arrowPath.close()
            
            let arrowLayer = CAShapeLayer()
            arrowLayer.path = arrowPath.cgPath
            arrowLayer.fillColor = Colors.accentOrange.cgColor
            
            let dx = end.x - start.x
            let dy = end.y - start.y
            let angle = atan2(dy, dx)
            
            arrowLayer.position = point
            arrowLayer.setAffineTransform(CGAffineTransform(rotationAngle: angle - CGFloat.pi/2))
            
            self?.layer.addSublayer(arrowLayer)
        }
    }
    
    private func transactionsExistBetween(from fromUserId: UUID, to toUserId: UUID) -> Bool {
        for section in transactions {
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
    
    private func startRotationAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = rotationDuration
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private func animateOpacityAndShadow() {
        for userCircle in subviews.compactMap({ $0 as? UserCircleView }) {
            let shadowLayer = userCircle.shadowContainerView.layer
            shadowLayer.shadowPath = UIBezierPath(ovalIn: userCircle.shadowContainerView.bounds).cgPath
            
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1.0
            opacityAnimation.toValue = circleOpacity
            opacityAnimation.duration = opacityShadowAnimationDuration / 2
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            opacityAnimation.autoreverses = true
            
            let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
            shadowOpacityAnimation.fromValue = 0.0
            shadowOpacityAnimation.toValue = shadowOpacity
            shadowOpacityAnimation.duration = opacityShadowAnimationDuration / 2
            shadowOpacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shadowOpacityAnimation.autoreverses = true
            
            let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
            shadowRadiusAnimation.fromValue = 0.0
            shadowRadiusAnimation.toValue = shadowRadius
            shadowRadiusAnimation.duration = opacityShadowAnimationDuration / 2
            shadowRadiusAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shadowRadiusAnimation.autoreverses = true
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [opacityAnimation, shadowOpacityAnimation, shadowRadiusAnimation]
            animationGroup.duration = opacityShadowAnimationDuration
            animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animationGroup.fillMode = .forwards
            animationGroup.isRemovedOnCompletion = false
            
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
            shadowLayer.shadowOpacity = 0.0
            shadowLayer.shadowRadius = 0.0
            
            shadowLayer.add(animationGroup, forKey: "opacityShadowAnimation")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + opacityShadowAnimationDuration) {
            self.removeShadows()
        }
    }
    
    private func removeShadows() {
        for userCircle in subviews.compactMap({ $0 as? UserCircleView }) {
            let shadowLayer = userCircle.shadowContainerView.layer
            shadowLayer.shadowOpacity = 0.0
            shadowLayer.shadowRadius = 0.0
            shadowLayer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    private func disconnectRemovableLines() {
        for (line, _, _) in removableLines {
            let fadeOut = CABasicAnimation(keyPath: "opacity")
            fadeOut.fromValue = 1.0
            fadeOut.toValue = 0.0
            fadeOut.duration = fadeOutDuration
            fadeOut.fillMode = .forwards
            fadeOut.isRemovedOnCompletion = false
            fadeOut.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            line.add(fadeOut, forKey: "fadeOutAnimation")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut.duration) {
                line.removeFromSuperlayer()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !circlesLaidOut else { return }
        
        setupUserCirclesAndLines()
        circlesLaidOut = true
        
        // Instead of starting rotation here, do it asynchronously after layout completes.
        DispatchQueue.main.async {
            self.startRotationAnimation()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + connectUserCirclesDuration) {
            self.animateOpacityAndShadow()
        }
        
        let fadeOutDelay = connectUserCirclesDuration + (self.opacityShadowAnimationDuration / 2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay) {
            self.disconnectRemovableLines()
        }
    }
}
