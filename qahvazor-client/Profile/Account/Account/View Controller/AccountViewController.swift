//
//  AccountViewController.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import UIKit

class AccountViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = AccountView

    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: ProfileCoordinator?
    internal let viewModel = AccountViewModel()

    // MARK: - Attributes
    internal var name: String? {
        didSet {
            view().nameLabel.text = name
        }
    }
    internal var phoneNumber: String? {
        didSet {
            if let phoneNumber {
                view().phoneNumberLabel.text = phoneNumber
            }
        }
    }
    internal var gender: String? {
        didSet {
            switch gender {
            case Gender.female.rawValue:
                view().genderLabel.text = "female".localized
            case Gender.male.rawValue:
                view().genderLabel.text = "male".localized
            default:
                view().genderLabel.text = "notSelected".localized
            }
        }
    }
    internal var dateOfBirth: Int? {
        didSet {
            if let dateOfBirth = dateOfBirth {
                view().dateOfBirthLabel.text = DateFormatter.string(timestamp: dateOfBirth, formatter: .birthDate)
            } else {
                view().dateOfBirthLabel.text = "notSelected".localized
            }
        }
    }
    var account: Account?
    // MARK: - Actions
    @IBAction func changeInfoAction(_ sender: UIButton) {
        coordinator?.pushToChangeInfoVC(name: name, gender: gender, dateOfBirth: dateOfBirth)
    }
    @IBAction func removeAccountAction(_ sender: UIButton) {
//        coordinator?.pushToDeleteAccountVC()
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.editMe()
    }
}

// MARK: - Networking
extension AccountViewController: AccountViewModelProtocol {
    func didFinishFetchAcc(data: Account) {
        name = data.name
        gender = data.gender
        dateOfBirth = data.dateOfBirthUnx
    }
    
}

// MARK: - Other funcs
extension AccountViewController {
    private func appearanceSettings() {
        navigationItem.title = "account".localized
        viewModel.delegate = self
        
        name = account?.name
        phoneNumber = account?.phoneNumber?.displayPhone()
    }
}
