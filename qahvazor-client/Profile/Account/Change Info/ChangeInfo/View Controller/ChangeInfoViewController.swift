//
//  ChangeInfoViewController.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import UIKit
import IQKeyboardManagerSwift

enum Gender: String {
    case male
    case female
}

class ChangeInfoViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = ChangeInfoView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: ProfileCoordinator?
    private let viewModel = ChangeInfoViewModel()
    var isNewUser = false
    
    // MARK: - Attributes
    var name: String? {
        didSet {
            view().nameTextField.text = name
        }
    }
    var gender: String? {
        didSet {
            view().genderButton.setTitle(gender, for: .normal)
            switch gender {
            case Gender.female.rawValue:
                view().genderButton.setTitle("female".localized, for: .normal)
            case Gender.male.rawValue:
                view().genderButton.setTitle("male".localized, for: .normal)
            default:
                view().genderButton.setTitle("selectGender".localized, for: .normal)
            }
        }
    }
    
    var dateOfBirth: Int? {
        didSet {
            if let dateOfBirth = dateOfBirth {
                view().dateOfBirthButton.setTitle(DateFormatter.string(timestamp: dateOfBirth, formatter: .birthDate), for: .normal)
            } else {
                view().dateOfBirthButton.setTitle("selectDateOfBirth".localized, for: .normal)
            }
        }
    }
    
    // MARK: - Actions
    @objc func nameDoneButtonClicked(_ sender: Any) {
        guard !isNewUser, let text = view().nameTextField.text, name != text else { return }
        update()
    }
    @IBAction func nextAction(_ sender: UIButton) {
        guard isNameValid else { return }
        view().endEditing(true)
        update()
    }
    @IBAction func genderAction(_ sender: UIButton) {
    }
    @IBAction func dateOfBirthAction(_ sender: UIButton) {
        coordinator?.pushToBirthVC(viewController: self, date: dateOfBirth ?? Int(Date().timeIntervalSince1970))
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.clear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view().nextButton.isHidden = !isNewUser
        updateNextButtonState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.reset()
    }
}

// MARK: - Networking
extension ChangeInfoViewController: ChangeInfoViewModelProtocol {
    func didFinishFetch() {
        guard !isNewUser else {
            return resetTabBar()
        }
        showSuccessAlert(message: "successRedactSaveAlert".localized)
    }
}

// MARK: - Other funcs
extension ChangeInfoViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        
        view().nameTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(nameDoneButtonClicked))
        view().nameTextField.addTarget(self, action: #selector(nameDoneButtonClicked), for: .editingDidEndOnExit)
        view().nameTextField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)

        setupGender()
    }
    
    func update() {
        guard let name = normalizedName, !name.isEmpty else { return }
        viewModel.updateMe(name: name, gender: gender, dateOfBirth: dateOfBirth)
    }

    @objc private func nameDidChange() {
        updateNextButtonState()
    }

    private var normalizedName: String? {
        view().nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isNameValid: Bool {
        !(normalizedName?.isEmpty ?? true)
    }

    private func updateNextButtonState() {
        view().setNextButtonEnabled(isNewUser && isNameValid)
    }
    
    private func setupGender() {
        view().genderButton.setMenuItems(items: [Gender.male, Gender.female]) { [weak self] gender in
            self?.gender = gender
            guard self?.isNewUser == false else { return }
            self?.update()
        }
    }
}

// MARK: - BirthViewControllerDelegate
extension ChangeInfoViewController: BirthViewControllerDelegate {
    func didSelect(date: Int) {
        dateOfBirth = date
        guard !isNewUser else { return }
        update()
    }
}
