//
//  CardNavigationController.swift
//  CardTest

import UIKit
import WebKit

protocol CardNavigationDelegate {
    func cardViewControllerDidNavigateForward(_ cardViewController: CardNavigationController)
    func cardViewControllerDidNavigateBack(_ cardViewController: CardNavigationController)
}

protocol CardNavigationDatasource {
    func cardViewControllerCanNavigateForward(_ cardViewController: CardNavigationController) -> Bool
    func cardViewControllerCanNavigateBackwards(_ cardViewController: CardNavigationController) -> Bool
}

class CardNavigationController: UIViewController {

    enum CardNavigationDirection {
        case forward, backward
    }
    
    private var leftView: UIView!
    private var centerView: UIView!
    private var rightView: UIView!
    private let centerInsets = UIEdgeInsets(top: 10, left: 20, bottom: -10, right: -20)
    private var centerTop: NSLayoutConstraint!
    private var centerBottom: NSLayoutConstraint!
    private var centerLeading: NSLayoutConstraint!
    private var centerTrailing: NSLayoutConstraint!
    private var viewsLoaded: Bool = false
    
    var navigationView: UIView? {
        didSet {
            guard viewsLoaded else { return }
            guard let navigationView = navigationView else { return }
            centerView.embed(navigationView)
            setupNavigation()
        }
    }
    var allowNavigation: Bool = true {
        didSet {
            guard allowNavigation != oldValue else { return }
            if allowNavigation {
                showNavigation()
            } else {
                hideNavigation()
            }
        }
    }
    var delegate: CardNavigationDelegate?
    var dataSource: CardNavigationDatasource?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupViews()
        setupPanGesture()
        setupNavigation()
    }
    
    private func setupNavigation() {
        leftView.isHidden = canSwipeBackward() == false
        rightView.isHidden = canSwipeForward() == false
    }
    
    private func setupViews() {
        leftView = addBlankView(.red)
        centerView = addBlankView(.green)
        rightView = addBlankView(.blue)
        
        centerTop = centerView.topAnchor.constraint(equalTo: view.topAnchor, constant: centerInsets.top)
        centerTop.isActive = true
        centerBottom = centerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: centerInsets.bottom)
        centerBottom.isActive = true
        centerLeading = centerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: centerInsets.left)
        centerLeading.isActive = true
        centerTrailing = centerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: centerInsets.right)
        centerTrailing.isActive = true

        leftView.topAnchor.constraint(equalTo: centerView.topAnchor).isActive = true
        leftView.heightAnchor.constraint(equalTo: centerView.heightAnchor, constant: 0).isActive = true
        leftView.widthAnchor.constraint(equalTo: centerView.widthAnchor, constant: 0).isActive = true
        leftView.trailingAnchor.constraint(equalTo: centerView.leadingAnchor, constant: -10).isActive = true

        rightView.topAnchor.constraint(equalTo: centerView.topAnchor).isActive = true
        rightView.heightAnchor.constraint(equalTo: centerView.heightAnchor, constant: 0).isActive = true
        rightView.widthAnchor.constraint(equalTo: centerView.widthAnchor, constant: 0).isActive = true
        rightView.leadingAnchor.constraint(equalTo: centerView.trailingAnchor, constant: 10).isActive = true
        
        if let navigationView = navigationView {
            centerView.embed(navigationView)
        }
        
        viewsLoaded = true
    }
    
    // MARK: View Management
    private func addBlankView(_ color: UIColor = .white) -> UIView {
        let blankView = UIView()
        blankView.translatesAutoresizingMaskIntoConstraints = false
        blankView.backgroundColor = color
        view.addSubview(blankView)
        return blankView
    }
    
    private func resetViews(animated: Bool) {
        let duration = animated ? 0.35 : 0
        
        leftView.subviews.forEach { $0.removeFromSuperview() }
        centerView.subviews.forEach { $0.removeFromSuperview() }
        rightView.subviews.forEach { $0.removeFromSuperview() }
        
        if let navigationView = navigationView {
            navigationView.alpha = 0
            centerView.embed(navigationView)
        }
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: [UIView.AnimationOptions.beginFromCurrentState], animations: {
            self.navigationView?.alpha = 1
            self.leftView.center = self.leftViewInitial
            self.centerView.center = self.centerViewInitial
            self.rightView.center = self.rightViewInitial
        }, completion: { finished in
            self.centerViewInitial = CGPoint()
            self.leftViewInitial = CGPoint()
            self.rightViewInitial = CGPoint()
        })
    }
    
    private func moveNavigationView(_ direction: CardNavigationDirection) {
        guard let navigationView = navigationView else { return }
        guard let snapshot = navigationView.snapshotView(afterScreenUpdates: true) else { return }
        
        navigationView.removeFromSuperview()
        centerView.addSubview(snapshot)
        navigationView.alpha = 0
        
        if direction == .forward {
            rightView.embed(navigationView)
        } else {
            leftView.embed(navigationView)
        }
        
        UIView.animate(withDuration: 0.35) {
            navigationView.alpha = 1
        }
    }
    
    // MARK: Public API
    func hideNavigation() {
        centerTop.constant = 0
        centerBottom.constant = 0
        centerLeading.constant = 0
        centerTrailing.constant = 0
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showNavigation() {
        centerTop.constant = centerInsets.top
        centerBottom.constant = centerInsets.bottom
        centerLeading.constant = centerInsets.left
        centerTrailing.constant = centerInsets.right
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
    func removeNavigationView(snapshot: Bool = false) -> UIView? {
        guard let navigationView = navigationView else { return nil }
        
        if snapshot, let snapshotView = navigationView.snapshotView(afterScreenUpdates: true) {
            centerView.embed(snapshotView)
        }
        
        navigationView.removeFromSuperview()
        
        return navigationView
    }
    
    // MARK: Gesture Handling
    // Initial location of views when gesture starts, used also to prevent multiple gestures from firing
    private var centerViewInitial = CGPoint()
    private var leftViewInitial = CGPoint()
    private var rightViewInitial = CGPoint()
    
    // Ask the delegate if we can swipe forward, default to false
    private func canSwipeForward() -> Bool {
        return dataSource?.cardViewControllerCanNavigateForward(self) ?? false
    }
    
    // Ask the delegate if we can swipe backward, default to false
    private func canSwipeBackward() ->  Bool {
        return dataSource?.cardViewControllerCanNavigateBackwards(self) ??  false
    }
    
    private func canComplete(gesture: PanDirectionGestureRecognizer) -> Bool {
        guard let gestureView = gesture.view else { return false }
        let translation = gesture.translation(in: gestureView.superview)
        guard abs(translation.x) >= 50 else { return false }
        
        if translation.x < 0, canSwipeForward() == false {
            return false
        }
        
        if translation.x > 0, canSwipeBackward() == false {
            return false
        }
        
        return true
    }

    private func setupPanGesture() {
        let panGesture = PanDirectionGestureRecognizer(direction: .horizontal, target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    @objc func handlePan(_ gesture: PanDirectionGestureRecognizer) {
        switch gesture.state {
        case .began: handlePanBegan(gesture)
        case .ended: handlePanEnded(gesture)
        case .cancelled: handlePanCancelled(gesture)
        case .changed: handlePanChange(gesture)
        case .possible: print("Possible")
        case .failed: print("Failed")
        }
    }

    private func handlePanBegan(_ gesture: PanDirectionGestureRecognizer) {
        leftViewInitial = leftView.center
        centerViewInitial = centerView.center
        rightViewInitial = rightView.center
    }

    private func handlePanChange(_ gesture: PanDirectionGestureRecognizer) {
        guard let gestureView = gesture.view else { return }

        let translation = gesture.translation(in: gestureView)
        
        // Check for swipe ability
        if abs(translation.x) > 150 {
            if canComplete(gesture: gesture) == false {
                gesture.isEnabled = false
                gesture.isEnabled = true
                return
            }
        }

        // Add the X translation to the view's original position.
        leftView.center = CGPoint(x: leftViewInitial.x + translation.x, y: leftViewInitial.y)
        centerView.center = CGPoint(x: centerViewInitial.x + translation.x, y: centerViewInitial.y)
        rightView.center = CGPoint(x: rightViewInitial.x + translation.x, y: rightViewInitial.y)
    }
    
    private func handlePanEnded(_ gesture: PanDirectionGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        let leftViewMax = CGPoint(x: leftViewInitial.x - leftView.bounds.width, y: leftViewInitial.y)
        let rightViewMax = CGPoint(x: rightViewInitial.x + rightView.bounds.width, y: leftViewInitial.y)

        let translation = gesture.translation(in: gestureView)
        let direction: CardNavigationDirection = translation.x < 0 ? .forward : .backward
        
        // Check that swipe is possible if not reset
        if canComplete(gesture: gesture) == false {
            gesture.isEnabled = false
            gesture.isEnabled = true
            resetViews(animated: true)
            return
        }

        moveNavigationView(direction)
        informDelegateDidNavigate(direction)

        let leftEnd = (direction == .forward) ? leftViewMax : centerViewInitial
        let centerEnd = (direction == .forward) ? leftViewInitial : rightViewInitial
        let rightEnd = (direction == .forward) ? centerViewInitial : rightViewMax
        
        let velocity = gesture.velocity(in: self.view)
        let distanceVector = CGPoint(x: centerViewInitial.x - centerEnd.x, y: centerViewInitial.y - centerEnd.y)
        let totalDistance = sqrt(pow(distanceVector.x, 2) + pow(distanceVector.y, 2))
        let magVelocity = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
        
        let animationDuration: TimeInterval = 1
        let springVelocity: CGFloat = magVelocity / totalDistance / CGFloat(animationDuration)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: springVelocity, options: [UIView.AnimationOptions.beginFromCurrentState], animations: {
            self.leftView.center = leftEnd
            self.centerView.center = centerEnd
            self.rightView.center = rightEnd
        }, completion: { finished in
            self.resetViews(animated: false)
            self.setupNavigation()
        })
    }

    private func handlePanCancelled(_ gesture: PanDirectionGestureRecognizer) {
        resetViews(animated: true)
    }
    
    // MARK: Delegate Notifications
    private func informDelegateDidNavigate(_ direction: CardNavigationDirection) {
        if direction == .forward {
            delegate?.cardViewControllerDidNavigateForward(self)
        } else {
            delegate?.cardViewControllerDidNavigateBack(self)
        }
    }
}

extension CardNavigationController: UIGestureRecognizerDelegate {
 
    // Prevent gesture from firing while animation is still running
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard centerTop.constant != 0 else { return false }
        return centerViewInitial == CGPoint()
    }

}
