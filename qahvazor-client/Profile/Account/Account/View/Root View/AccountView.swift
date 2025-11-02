//
//  AccountView.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import UIKit

final class AccountView: CustomView {
    // MARK: - Outlets
    @IBOutlet var backViews: [UIView]! {
        didSet {
            backViews.forEach {
                $0.layer.cornerCurve = .continuous
                $0.layer.cornerRadius = 12
            }
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var changeInfoButton: UIButton!
    @IBOutlet weak var removeAccountButton: UIButton!
}
