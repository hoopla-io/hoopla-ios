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
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            buttons.forEach { $0.setRightImage(image: UIImage(systemName: "chevron.right") ?? UIImage())}
        }
    }
}
