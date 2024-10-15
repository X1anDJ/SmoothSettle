import UIKit

class CircleLayoutView: UIView {

    // Array of user IDs (UUIDs) to be displayed in circles
    var userIds: [UUID] = []
    var transactions: [TransactionsTableView.Section] = [] // Simplified transactions data
    let circleSize: CGFloat = 30
    let connectUserCirclesDuration = 2.0  // First phase: Connecting circles duration
    let rotationDuration = 25.0
    let lineColor = Colors.accentOrange.cgColor // Line color for the connections
    let connectionLineWidth = CGFloat(2)
    private var circlesLaidOut = false
    private var connectionTimer: Timer?

    // Store lines to be animated
    private var lines: [(CAShapeLayer, UUID, UUID)] = []

    // Store lines that can be removed
    private var removableLines: [(CAShapeLayer, UUID, UUID)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Set up the view background or other styling
    private func setupView() {
        self.backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !circlesLaidOut {
            setupUserCirclesAndLines()
            circlesLaidOut = true
            startRotationAnimation()

            // Schedule the disconnection of removable lines after the connection animation duration
            DispatchQueue.main.asyncAfter(deadline: .now() + connectUserCirclesDuration) {
                self.disconnectRemovableLines()
            }
        }
    }

    // Layout the user circles and lines along the perimeter of an invisible circle
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
        for (index, _) in userIds.enumerated() {
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

    // Connect each user circle to all other user circles (Phase 1) with animation
    private func connectAllCirclesWithLines() {
        guard userIds.count > 1 else { return }

        for (i, circle1) in subviews.enumerated() {
            // Each user only connects to subsequent users, so we start the loop from the next user
            for j in (i+1)..<subviews.count {
                let circle2 = subviews[j]
                drawAnimatedLine(from: offsetPoint(from: circle1.center, to: circle2.center, offset: circleSize / 2),
                                 to: offsetPoint(from: circle2.center, to: circle1.center, offset: circleSize / 2),
                                 fromUserId: userIds[i], toUserId: userIds[j])
            }
        }
    }

    // Check if a transaction exists between two users using their UUIDs
    private func transactionExistsBetween(from fromUserId: UUID, to toUserId: UUID) -> Bool {
        for section in transactions {
            if section.fromId == fromUserId {
                for transaction in section.transactions {
                    if transaction.toId == toUserId {
                        return true
                    }
                }
            }
        }
        return false
    }

    // Draw a line between two points with animation and store the line
    private func drawAnimatedLine(from startPoint: CGPoint, to endPoint: CGPoint, fromUserId: UUID, toUserId: UUID) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        line.path = linePath.cgPath
        line.strokeColor = lineColor
        line.lineWidth = connectionLineWidth
        line.lineCap = .round
        line.strokeEnd = 0.0

        // Add the line layer to the view
        self.layer.addSublayer(line)

        // Store the line with the associated user data
        lines.append((line, fromUserId, toUserId))

        // Check if the line should be removable (i.e., no transaction between users)
        if !transactionExistsBetween(from: fromUserId, to: toUserId) && !transactionExistsBetween(from: toUserId, to: fromUserId) {
//            print("Line between \(fromUserId) and \(toUserId) can be removed, no transactions found.")
            removableLines.append((line, fromUserId, toUserId))
        }

        // Animate the stroke end from 0 to 1 over connectUserCirclesDuration (2 seconds)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = connectUserCirclesDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        line.add(animation, forKey: "lineAnimation")
    }

    // Offset a point by a given amount along the direction between two points
    private func offsetPoint(from startPoint: CGPoint, to endPoint: CGPoint, offset: CGFloat) -> CGPoint {
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let distance = sqrt(dx * dx + dy * dy)
        let ratio = offset / distance
        let offsetX = dx * ratio
        let offsetY = dy * ratio
        return CGPoint(x: startPoint.x + offsetX, y: startPoint.y + offsetY)
    }

    // Add rotation animation to the entire view
    private func startRotationAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi  // Full rotation (360 degrees)
        rotation.duration = rotationDuration  // 25 seconds for one complete rotation
        rotation.repeatCount = .infinity  // Repeat forever
        self.layer.add(rotation, forKey: "rotationAnimation")
    }

    // Disconnect lines that can be removed after the initial animation completes
    private func disconnectRemovableLines() {
        for (line, fromUserId, toUserId) in removableLines {
//            print("Disconnecting line between \(fromUserId) and \(toUserId)")
            
            // Animate the line removal (fade out and remove from the layer)
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 1.0
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            line.add(animation, forKey: "fadeOutAnimation")
            
            // Remove the line from the layer after the fade-out animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                line.removeFromSuperlayer()
            }
        }
    }
}
