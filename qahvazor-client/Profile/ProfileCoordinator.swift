//
//  ProfileCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit
import SwiftMessages

final class ProfileCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ProfileViewController()
        vc.tabBarItem = UITabBarItem(title: "profile".localized, image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        vc.tabBarItem.tag = AppTab.profile.rawValue
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushToAccountVC(account: Account?) {
        let vc = AccountViewController()
        vc.account = account
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToChangeInfoVC(name: String? = nil, gender: String? = nil, dateOfBirth: Int? = nil, isNewUser: Bool = false) {
        let vc = ChangeInfoViewController()
        vc.coordinator = self
        vc.name = name
        vc.gender = gender
        vc.dateOfBirth = dateOfBirth
        vc.isNewUser = isNewUser
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToCodeConfirmVC(data: Auth? = nil) {
        let vc = CodeConfirmViewController()
        vc.data = data
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToLanguageVC(viewController: UIViewController) {
        let vc = LanguageViewController()
        vc.fromSettings = true
        if let viewController = viewController as? ProfileViewController {
            vc.delegate = viewController
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToSubscriptionVC() {
        let vc = SubscriptionViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToPaymentVC(amount: Double? = nil) {
        let vc = PaymentViewController()
        vc.coordinator = self
        vc.amount = amount
        navigationController.pushViewController(vc, animated: true)
    }

    func presentGiftcardVC(viewController: UIViewController) {
        let vc = GiftcardViewController()
        if let viewController = viewController as? ProfileViewController {
            vc.delegate = viewController
        }

        if let sheet = vc.sheetPresentationController {
            sheet.preferredCornerRadius = 28
            sheet.prefersGrabberVisible = false

            let giftcardId = UISheetPresentationController.Detent.Identifier("giftcard")
            let giftcardDetent = UISheetPresentationController.Detent.custom(identifier: giftcardId) { context in
                context.maximumDetentValue * 0.75
            }
            sheet.detents = [giftcardDetent]
            sheet.selectedDetentIdentifier = giftcardId
        }

        navigationController.present(vc, animated: true)
    }
    
    func pushToBirthVC(viewController: UIViewController, date: Int) {
        let vc = BirthViewController()
        vc.dateOfBirth = date
        if let viewController = viewController as? ChangeInfoViewController {
            vc.delegate = viewController
        }
        let segue = SwiftMessagesSegue(identifier: nil, source: viewController, destination: vc)
        segue.configure(layout: .bottomCard)
        segue.messageView.backgroundHeight = 352.0
        segue.perform()
    }
}
