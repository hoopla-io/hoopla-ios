//
//  ProfileView.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import UIKit

final class ProfileView: CustomView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginStack: UIStackView!
    @IBOutlet weak var profileStack: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accounNumberLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var subscriptionTitleLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var subscriptionButton: UILabel!
    @IBOutlet weak var paymentView: UIView! {
        didSet {
            paymentView.layer.cornerCurve = .continuous
            paymentView.layer.borderWidth = 1.5
            paymentView.layer.borderColor = UIColor.systemGray.cgColor
        }
    }
    @IBOutlet weak var tariffContainerView: UIView! {
        didSet {
            tariffContainerView.layer.cornerCurve = .continuous
            tariffContainerView.layer.borderWidth = 1.5
        }
    }
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            buttons.forEach { $0.setRightImage(image: UIImage(systemName: "chevron.right") ?? UIImage())}
        }
    }
    
    //MARK: - Attributes
    var subscription: Subscription? {
        didSet {
            guard let subscription else {
                tariffContainerView.layer.borderColor = UIColor.clear.cgColor
                subscriptionButton.isHidden = false
                return
            }
            subscriptionButton.isHidden = true
//            showSubscriptionInfo()
            subscriptionTitleLabel.text = subscription.name
            let date = DateFormatter.string(timestamp: subscription.endDateUnix ?? 0, formatter: .birthDate)
            endDateLabel.text = date
            tariffContainerView.layer.borderColor = UIColor.systemGray.cgColor
        }
    }
    
//    func showSubscriptionInfo() {
//        guard subscriptionInfoStackView.isHidden else { return }
//        subscriptionInfoStackView.alpha = 0
//        UIView.transition(with: subscriptionInfoStackView, duration: 0.3) {
//            self.subscriptionInfoStackView.isHidden = false
//        }
//        UIView.animate(withDuration: 0.5) { [weak self] in
//            guard let self else { return }
//            subscriptionInfoStackView.alpha = 1
//        }
//    }
}
