//
//  HistoryCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit

final class HistoryCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = HistoryViewController()
        let tabIcon = UIImage(named: AssetsImage.tabOrders.rawValue)
        vc.tabBarItem = UITabBarItem(
            title: "",
            image: tabIcon,
            selectedImage: tabIcon
        )
        vc.tabBarItem.tag = AppTab.orders.rawValue
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushToHistoryDetailVC(item: OrderHistory) {
        let vc = HistoryDetailViewController()
        vc.coordinator = self
        vc.data = item
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func presentGetOrderVC(orderId: Int) {
        let vc = GetOrderViewController()
        vc.orderId = orderId
        if let sheet = vc.sheetPresentationController {
            sheet.preferredCornerRadius = 16
            sheet.prefersGrabberVisible = true
            
            let reviewId = UISheetPresentationController.Detent.Identifier("GetOrders")
            let reviewDetent = UISheetPresentationController.Detent.custom(identifier: reviewId) { context in
                return context.maximumDetentValue * 0.9
            }
            sheet.detents = [reviewDetent]
            sheet.selectedDetentIdentifier = reviewId
        }
        navigationController.present(vc, animated: true)
    }

    func presentReviewVC(data: OrderHistory) {
        let viewController = ReviewViewController()
        viewController.data = data
        if let sheet = viewController.sheetPresentationController {
            sheet.preferredCornerRadius = 16
            sheet.prefersGrabberVisible = true

            let reviewIdentifier = UISheetPresentationController.Detent.Identifier("historyReview")
            let reviewDetent = UISheetPresentationController.Detent.custom(identifier: reviewIdentifier) { context in
                context.maximumDetentValue * 0.75
            }
            sheet.detents = [reviewDetent, .large()]
            sheet.selectedDetentIdentifier = reviewIdentifier
        }
        navigationController.present(viewController, animated: true)
    }
}
