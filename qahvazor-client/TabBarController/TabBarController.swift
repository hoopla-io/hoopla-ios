//
//  TabBarController.swift
//  itv-new
//
//  Created by Jakhongir Nematov on 30/09/21.
//

import UIKit
import Haptica

protocol TabBarReselectHandling {
    func handleReselect()
}

final class TabBarController: UITabBarController {

    // MARK: - Attributes
    private let mainCoordinator = MainCoordinator(navigationController: UINavigationController())
    private let qrCoordinator   = QRCoordinator(navigationController: UINavigationController())
    private let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController())
    var lastViewController: UIViewController?

    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupControllers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupControllers()
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }

}

// MARK: - Setup
private extension TabBarController {

    func setupControllers() {
        if #available(iOS 17.0, *) {
            traitOverrides.horizontalSizeClass = .compact
        }
        
        mainCoordinator.start()
        qrCoordinator.start()
        profileCoordinator.start()
        
        // Disable default tap on the middle (QR) tab item
        let homeNav    = mainCoordinator.navigationController
        let qrNav      = qrCoordinator.navigationController
        let profileNav = profileCoordinator.navigationController
        
        viewControllers = [homeNav, qrNav, profileNav]
    }
    
    private func appearanceSettings() {
        tabBar.setup()
        delegate = self
    }

}

// MARK: - Actions
private extension TabBarController {

    @objc func astroButtonItemLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began,
              let items = tabBar.items,
              let vcs   = viewControllers,
              items.count == vcs.count else { return }

        let location = recognizer.location(in: tabBar)
        for item in items {
            guard let itemView = item.value(forKey: "view") as? UIView,
                  itemView.frame.contains(location) else { continue }
            animate(item: item, duration: 0.6)
            break
        }
    }

    func animate(item: UITabBarItem, duration: TimeInterval) {
        guard let itemView = item.value(forKey: "view") as? UIView else { return }
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.5) {
            itemView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        animator.addAnimations({ itemView.transform = .identity }, delayFactor: 1.0)
        animator.startAnimation()
        Haptic.selection.generate()
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController,
//                          shouldSelect viewController: UIViewController) -> Bool {
//        // Prevent selecting the disabled placeholder (QR) tab
//        if viewController === qrCoordinator.navigationController {
//            return false
//        }
//        return true
//    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        animationItem(item: item)
//    }
}


extension UITabBar {
    func setup() {
        tintColor = UIColor.label
    }
}
