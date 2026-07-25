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
    private let mapCoordinator = MapCoordinator(navigationController: UINavigationController())
    private let cartCoordinator = CartCoordinator(navigationController: UINavigationController())
    private let historyCoordinator  = HistoryCoordinator(navigationController: UINavigationController())
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartCountDidUpdate(_:)),
            name: .cartCountDidUpdate,
            object: nil
        )
        CartBadgeManager.shared.refresh()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup
private extension TabBarController {

    func setupControllers() {
        if #available(iOS 17.0, *) {
            traitOverrides.horizontalSizeClass = .compact
        }
        
        mainCoordinator.start()
        mapCoordinator.start()
        cartCoordinator.start()
        historyCoordinator.start()
        profileCoordinator.start()
        
        let homeNav     = mainCoordinator.navigationController
        let mapNav      = mapCoordinator.navigationController
        let cartNav     = cartCoordinator.navigationController
        let historyNav  = historyCoordinator.navigationController
        let profileNav  = profileCoordinator.navigationController
        if UserDefaults.standard.isAuthed() {
            viewControllers = [homeNav, mapNav, cartNav, historyNav, profileNav]
        } else {
            viewControllers = [homeNav, mapNav, historyNav, profileNav]
        }
    }
    
    private func appearanceSettings() {
        tabBar.setup()
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

    @objc func cartCountDidUpdate(_ notification: Notification) {
        let count = notification.userInfo?["count"] as? Int ?? 0
        cartCoordinator.navigationController.tabBarItem.badgeValue = count > 0 ? String(count) : nil
        cartCoordinator.navigationController.tabBarItem.badgeColor = .systemRed
    }
}

extension UITabBar {
    func setup() {
        tintColor = UIColor.label
    }
}

extension UITabBarController {
    func selectTab(_ tab: AppTab) {
        guard let index = viewControllers?.firstIndex(where: {
            $0.tabBarItem.tag == tab.rawValue
        }) else { return }
        selectedIndex = index
    }
}
