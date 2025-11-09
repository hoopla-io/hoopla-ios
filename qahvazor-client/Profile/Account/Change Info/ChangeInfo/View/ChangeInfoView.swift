//
//  ChangeInfoView.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import UIKit

final class ChangeInfoView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: CustomTextField!
    @IBOutlet weak var genderButton: UIButton! {
        didSet {
            genderButton.setRightImage(image: UIImage(systemName: "chevron.down") ?? UIImage(), height: 20, inset: 24)
        }
    }
    @IBOutlet weak var dateOfBirthButton: UIButton! {
        didSet {
            dateOfBirthButton.setRightImage(image: UIImage(systemName: "calendar") ?? UIImage(), height: 20, inset: 24)
        }
    }
}
