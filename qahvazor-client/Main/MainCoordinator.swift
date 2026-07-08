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
        vc.tabBarItem = UITabBarItem(title: "home".localized, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        vc.tabBarItem.tag = 0
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func startSearch() {
        let vc = SearchViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
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
    
    func pushToConfirmOrderVC(viewController: UIViewController, data: Drinks, shop: Shop?) {
        let vc = ConfirmOrderViewController()
        vc.drinkData = data
        vc.shopData = shop
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToSubscriptionVC() {
        let vc = SubscriptionViewController()
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController)
        vc.coordinator = profileCoordinator
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
        drinkData: Drinks?,
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
    
    func presentStoryDetailVC(data: StoryDetail) {
        let vc = MainStoryViewController(story: data)
        if let sheet = vc.sheetPresentationController {
            sheet.preferredCornerRadius = 16
            sheet.prefersGrabberVisible = true
            
            let reviewId = UISheetPresentationController.Detent.Identifier("story")
            let reviewDetent = UISheetPresentationController.Detent.custom(identifier: reviewId) { context in
                return context.maximumDetentValue * 1
            }
            sheet.detents = [reviewDetent]
            sheet.selectedDetentIdentifier = reviewId
        }
        navigationController.present(vc, animated: true)
    }
}
