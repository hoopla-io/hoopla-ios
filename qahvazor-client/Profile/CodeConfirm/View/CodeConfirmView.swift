//
//  CodeConfirmView.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import UIKit
import DeviceKit

final class CodeConfirmView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var codeTextField: KAPinField! {
        didSet {
            codeTextField.textContentType = .oneTimeCode
            codeTextField.keyboardType = .numberPad
            codeTextField.updateProperties { properties in
                properties.numberOfCharacters = 5
            }
            codeTextField.updateAppearence { appearance in
                appearance.tokenColor = UIColor.clear
                appearance.tokenFocusColor = .label
                appearance.font = .menloBold(24)
                appearance.kerning = 40
                appearance.backOffset = 8
                appearance.backBorderWidth = 0
                appearance.backCornerRadius = 6
                appearance.textColor = UIColor.label
                appearance.backFocusColor = UIColor.systemGray4
                appearance.backColor = UIColor.secondarySystemBackground
                appearance.backActiveColor = UIColor.secondarySystemBackground
            }
        }
    }
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var termOfServicesButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var privaceStackView: UIStackView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    
    // MARK: - Attribute
    var phoneNumber = String() {
        didSet {
            infoLabel.text! += "\n\(phoneNumber.displayPhone())"
        }
    }
}


