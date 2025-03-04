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
    @IBOutlet weak var subscriptionInfoStackView: UIStackView! {
        didSet {
            subscriptionInfoStackView.isHidden = true
        }
    }
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            buttons.forEach { $0.setRightImage(image: UIImage(systemName: "chevron.right") ?? UIImage())}
        }
    }
    
    //MARK: - Attributes
    var subscription: Subscription? {
        didSet {
            guard let subscription else { return subscriptionInfoStackView.isHidden = true }
            showSubscriptionInfo()
            subscriptionLabel.text = subscription.name
            let date = DateFormatter.string(timestamp: subscription.endDateUnix ?? 0, formatter: .birthDate)
            endDateLabel.text = date
        }
    }
    
    func showSubscriptionInfo() {
        guard subscriptionInfoStackView.isHidden else { return }
        subscriptionInfoStackView.alpha = 0
        UIView.transition(with: subscriptionInfoStackView, duration: 0.3) {
            self.subscriptionInfoStackView.isHidden = false
        }
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            subscriptionInfoStackView.alpha = 1
        }
    }
}
