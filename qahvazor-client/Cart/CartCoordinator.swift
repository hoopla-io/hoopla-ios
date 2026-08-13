//
//  CartCoordinator.swift
//  qahvazor-client
//

import UIKit

extension Notification.Name {
    static let cartDidChange = Notification.Name("com.hoopla.cartDidChange")
    static let cartCountDidUpdate = Notification.Name("com.hoopla.cartCountDidUpdate")
}

enum AppTab: Int {
    case home = 0
    case map = 1
    case cart = 2
    case orders = 3
    case profile = 4
}

final class CartCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewController = CartViewController()
        viewController.coordinator = self
        let tabIcon = UIImage(named: AssetsImage.tabCart.rawValue)
        viewController.tabBarItem = UITabBarItem(
            title: "",
            image: tabIcon,
            selectedImage: tabIcon
        )
        viewController.tabBarItem.tag = AppTab.cart.rawValue
        navigationController.pushViewController(viewController, animated: false)
    }

    func showOrder(_ order: OrderHistory) {
        let viewController = HistoryDetailViewController()
        viewController.coordinator = HistoryCoordinator(navigationController: navigationController)
        viewController.data = order
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }

    func pushToCashbeckVC(
        viewController: CartViewController,
        totalPrice: Double,
        cashbackAmount: Double
    ) {
        let cashbackViewController = CashbeckViewController()
        cashbackViewController.totalPrice = totalPrice
        cashbackViewController.selectedCashbekPrice = cashbackAmount
        cashbackViewController.delegate = viewController
        cashbackViewController.loadViewIfNeeded()
        cashbackViewController.view.layoutIfNeeded()

        if let sheet = cashbackViewController.sheetPresentationController {
            sheet.preferredCornerRadius = 16
            sheet.prefersGrabberVisible = true

            let detentIdentifier = UISheetPresentationController.Detent.Identifier("current")
            let detent = UISheetPresentationController.Detent.custom(
                identifier: detentIdentifier
            ) { context in
                context.maximumDetentValue * 0.4
            }
            sheet.detents = [detent]
            sheet.selectedDetentIdentifier = detentIdentifier
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }

        navigationController.present(cashbackViewController, animated: true)
    }
}

final class CartBadgeManager {
    static let shared = CartBadgeManager()

    private init() {}

    func cartDidChange() {
        NotificationCenter.default.post(name: .cartDidChange, object: nil)
        refresh()
    }

    func refresh() {
        guard UserDefaults.standard.isAuthed() else {
            publish(count: 0)
            return
        }

        Task {
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.cartCount.rawValue,
                requestMethod: .get,
                completionHandler: { result in
                    switch result {
                    case .Success(let data):
                        let count = (try? CustomDecoder().decode(JSONData<CartCount>.self, from: data).data?.count) ?? 0
                        self.publish(count: count)
                    case .Error:
                        break
                    }
                }
            )
        }
    }

    private func publish(count: Int) {
        NotificationCenter.default.post(
            name: .cartCountDidUpdate,
            object: nil,
            userInfo: ["count": max(count, 0)]
        )
    }
}
