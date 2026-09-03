//
//  MainCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit
import SwiftMessages
import Hero

final class MainCoordinator: Coordinator {
    
    internal var childCoordinators = [Coordinator]()
    internal var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MainViewController()
        let tabIcon = UIImage(named: AssetsImage.tabHome.rawValue)
        vc.tabBarItem = UITabBarItem(
            title: "",
            image: tabIcon,
            selectedImage: tabIcon
        )
        vc.tabBarItem.tag = AppTab.home.rawValue
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func startSearch() {
        let vc = SearchViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func pushToSearchShop(partner: Company) {
        let vc = SearchShopViewController(partner: partner)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func pushToSearchShop(partnerId: Int, partnerName: String? = nil) {
        let vc = SearchShopViewController(partnerId: partnerId, partnerName: partnerName)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToShopDetail(id: Int, item: Shop?) {
        let vc = ShopDetailViewController()
        vc.data = item
        vc.shopId = id
        vc.distance = item?.distance
        vc.coordinator = self
//        vc.hero.isEnabled = true
//        navigationController.hero.isEnabled = true
        navigationController.pushViewController(vc, animated: true)
    }

    func pushToOrderDetail(_ item: OrderHistory) {
        let vc = HistoryDetailViewController()
        vc.coordinator = HistoryCoordinator(navigationController: navigationController)
        vc.data = item
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToConfirmOrderVC(viewController: UIViewController, data: Products, shop: Shop?) {
        let vc = ConfirmOrderViewController()
        vc.drinkData = data
        vc.shopData = shop
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToPaymentVC(amount: Double? = nil) {
        let vc = PaymentViewController()
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController)
        vc.coordinator = profileCoordinator
        vc.amount = amount
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToScannerVC(viewController: UIViewController) {
        let vc = ScannerViewController()
        if let viewController = viewController as? MainViewController {
            vc.delegate = viewController
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToNotificationsVC() {
        let vc = NotificationsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToNotificationsDetailVC(notificationId: Int) {
        let vc = NotificationsDetailViewController()
        vc.notificationId = notificationId
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToCheckoutVC(
        shopData: Shop?,
        drinkData: Products?,
        totalPrice: Double,
        comment: String?,
        modifiers: [Modification],
        cashbackPercent: Int?
    ) {
        let vc = CheckoutViewController()
        vc.coordinator = self
        vc.shopData = shopData
        vc.drinkData = drinkData
        vc.totalPrice = totalPrice
        vc.comment = comment
        vc.selectedModifiers = modifiers
        vc.cashbackPercent = cashbackPercent
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToCashbeckVC(viewController: UIViewController, totalPrice: Double, cashbackAmount: Double) {
        let vc = CashbeckViewController()
        vc.totalPrice = totalPrice
        vc.selectedCashbekPrice = cashbackAmount
        vc.loadViewIfNeeded()
        vc.view.layoutIfNeeded()
        if let viewController = viewController as? CheckoutViewController {
            vc.delegate = viewController
        }
        if let sheet = vc.sheetPresentationController {
            sheet.preferredCornerRadius = 16
            sheet.prefersGrabberVisible = true
            
            let smallId = UISheetPresentationController.Detent.Identifier("current")
            let small = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
                return context.maximumDetentValue * 0.4
            }
            sheet.detents = [small]
            sheet.selectedDetentIdentifier = smallId
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        navigationController.present(vc, animated: true)
    }

    func presentPromocodeVC(viewController: UIViewController, shopId: Int, drinkId: Int, modifiers: [Modification]) {
        let vc = PromocodeViewController()
        vc.shopId = shopId
        vc.drinkId = drinkId
        vc.modifiers = modifiers
        if let viewController = viewController as? CheckoutViewController {
            vc.delegate = viewController
        }
        if let sheet = vc.sheetPresentationController {
            sheet.preferredCornerRadius = 24
            sheet.prefersGrabberVisible = false

            let promocodeId = UISheetPresentationController.Detent.Identifier("promocode")
            sheet.detents = [.large()]
            sheet.selectedDetentIdentifier = promocodeId
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        navigationController.present(vc, animated: true)
    }
    
    func presentReviewVC(data: OrderHistory) {
        let vc = ReviewViewController()
        vc.data = data
        if let sheet = vc.sheetPresentationController {
            sheet.preferredCornerRadius = 16
            sheet.prefersGrabberVisible = true
            
            let reviewId = UISheetPresentationController.Detent.Identifier("review")
            let reviewDetent = UISheetPresentationController.Detent.custom(identifier: reviewId) { context in
                return context.maximumDetentValue * 0.75
            }
            sheet.detents = [reviewDetent, .large()]
            sheet.selectedDetentIdentifier = reviewId
        }
        navigationController.present(vc, animated: true)
    }
    
    func presentStoryDetailVC(
        groups: [Stories],
        selectedGroupIndex: Int,
        initialGroup: Stories,
        storyLoader: @escaping MainStoryLoader
    ) {
        let vc = MainStoryViewController(
            groups: groups,
            selectedGroupIndex: selectedGroupIndex,
            initialGroup: initialGroup,
            storyLoader: storyLoader
        )
        vc.onOpenAction = { [weak self, weak vc] action, storyTitle in
            vc?.dismiss(animated: true) {
                self?.handleStoryLinkAction(action, storyTitle: storyTitle)
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        navigationController.present(vc, animated: true)
    }

    private func handleStoryLinkAction(_ action: StoryLinkAction, storyTitle: String?) {
        switch action {
        case .partner(let partnerId):
            pushToSearchShop(partnerId: partnerId, partnerName: storyTitle)
        case .url(let url):
            navigationController.openViaSafariVC(url.absoluteString, from: navigationController)
        case .shop(let shopId):
            pushToShopDetail(id: shopId, item: nil)
        }
    }
}
