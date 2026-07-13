//
//  ProfileViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import UIKit
import Haptica

class ProfileViewController: TextFieldViewController, ViewSpecificController, @MainActor AlertViewController {
    // MARK: - Root View
    typealias RootView = ProfileView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: ProfileCoordinator?
    let viewModel = ProfileViewModel()
    let accountViewModel = AccountViewModel()
    
    // MARK: - Attributes
    var account: Account?
    var editAccount: Account?
    
    // MARK: - Actions
    @IBAction func loginAction(_ sender: UIButton) {
        next()
    }
    
    @IBAction func mainButtonActions(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            coordinator?.pushToSubscriptionVC()
        case 1:
            coordinator?.pushToLanguageVC(viewController: self)
        case 2:
            openURL(urlString: MainConstants.termsOfUse.rawValue)
        case 3:
            openURL(urlString: MainConstants.privacyPolicy.rawValue)
        case 4:
            openURL(urlString: MainConstants.support.rawValue)
        case 5:
            coordinator?.pushToAccountVC(account: account)
        default: break
        }
    }
    
    @objc func paymentTapped() {
        coordinator?.pushToPaymentVC()
    }

    @objc private func activateGiftcardTapped() {
        coordinator?.presentGiftcardVC(viewController: self)
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        showLogoutAlert()
    }

    @objc private func logoutBarButtonTapped() {
        showLogoutAlert()
    }

    private func showLogoutAlert() {
        showAlertDestructive(message: "logoutAlert".localized, buttonTitle: "logout".localized) {
            self.viewModel.logOut()
        }
    }

    @IBAction func editAction(_ sender: UIButton) {
        coordinator?.pushToChangeInfoVC(name: editAccount?.name, gender: editAccount?.gender, dateOfBirth: editAccount?.dateOfBirthUnx)
    }
    
    // MARK: - Life cycle
    override func loadView() {
        view = ProfileView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        if UserDefaults.standard.isAuthed() {
            viewModel.getMe()
            accountViewModel.editMe()
        }
    }
}
// MARK: - Networking
extension ProfileViewController: ProfileViewModelProtocol {
    func didFinishFetch(data: Auth) {
        coordinator?.pushToCodeConfirmVC(data: data)
    }
    
    func didFinishFetch(data: Account) {
        view().nameLabel.text = data.name
        view().accounNumberLabel.text = data.phoneNumber?.displayPhone()
        view().balanceLabel.text = data.balanceInfo
        UserDefaults.standard.saveBalance(data.balance ?? 0)
        self.account = data
    }
    
    func didFinishFetchLogout() {
        UserDefaults.standard.removeAccount()
        resetTabBar()
        checkAuth()
    }
}
// MARK: - Networking
extension ProfileViewController: AccountViewModelProtocol {
    func didFinishFetchAcc(data: Account) {
        editAccount = data
    }
}
// MARK: - Other funcs
extension ProfileViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        accountViewModel.delegate = self
        view().loginButton.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)
        view().mainButtons.forEach {
            $0.addTarget(self, action: #selector(mainButtonActions(_:)), for: .touchUpInside)
        }
        view().editButton.addTarget(self, action: #selector(editAction(_:)), for: .touchUpInside)
        view().topUpButton.addTarget(self, action: #selector(paymentTapped), for: .touchUpInside)
        view().activateButton.addTarget(self, action: #selector(activateGiftcardTapped), for: .touchUpInside)
        
        if let releaseVersionNumber = Bundle.main.releaseVersionNumber {
            view().versionLabel.text = "version".localized + Symbols.space.rawValue + releaseVersionNumber
        }
        checkAuth()

        setupApiDebugger()
    }

    private func configureNavigationBar() {
        navigationItem.title = "profile".localized
        
        guard UserDefaults.standard.isAuthed() else { return }
        let logoutImage = UIImage(systemName: "rectangle.portrait.and.arrow.right") ?? UIImage(systemName: "arrow.uturn.backward.circle")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: logoutImage,
            style: .plain,
            target: self,
            action: #selector(logoutBarButtonTapped)
        )
    }
    
    private func checkAuth() {
        if UserDefaults.standard.isAuthed() {
            view().loginStack.isHidden = true
            view().profileStack.isHidden = false
        } else {
            view().loginStack.isHidden = false
            view().profileStack.isHidden = true
            setupTextFields(textFields: [view().textField], button: view().loginButton)
        }
    }
    
    //Authorization
    override func textFieldDidChange(_ textField: UITextField?) {
        guard let textField = textField, let text = textField.text else { return }
        textField.text = text.displayPhone()
    }
    
    override func next() {
        switch status() {
        case .active:
            guard let text = view().textField.text, text.originPhone().count == 12 else { return showWarningAlert(message: "fillField".localized) }
            viewModel.numberSignIn(number: text.originPhone())
        case .passive:
            showWarningAlert(message: "fillField".localized)
        }
    }
}

// MARK: - SettingsViewControllerDelegate
extension ProfileViewController: LanguageViewControllerDelegate {
    func didSelectLanguage() {
        resetTabBar()
    }
}

extension ProfileViewController: GiftcardViewControllerDelegate {
    func giftcardViewController(_ viewController: GiftcardViewController, didRedeem data: GiftcardRedemption) {
        view().balanceLabel.text = "\(data.balance.formattedWithSeparator) \(data.currency)"
        UserDefaults.standard.saveBalance(data.balance)

        let message = String(
            format: "giftcardCredited".localized,
            data.credited.formattedWithSeparator
        )
        showSuccessAlert(message: message)
    }
}

//MARK: - Scroll to up
extension ProfileViewController: TabBarReselectHandling {
    func handleReselect() {
        view().scrollView.setContentOffset(CGPoint(x: 0, y: -90), animated: true)
    }
}

//MARK: - Set Wormholy
extension ProfileViewController {
    func setupApiDebugger() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
            longPress.minimumPressDuration = 3.0
        view().versionLabel.addGestureRecognizer(longPress)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // 2 sekund bosib turganda shu joy ishga tushadi
            didTapAlert()
        }
    }
    
    func didTapAlert() {
        // 1. Alert yaratamiz
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .alert
        )
        
        let option1 = UIAlertAction(title: "Turn ON", style: .default) { _ in
            self.handleAlertSelection(option: 1)
        }
        
        let option2 = UIAlertAction(title: "Turn OFF", style: .default) { _ in
            self.handleAlertSelection(option: 2)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(option1)
        alert.addAction(option2)
        alert.addAction(cancel)
        
        // 4. Alertni ko‘rsatamiz
        present(alert, animated: true, completion: nil)
    }
    
    func handleAlertSelection(option: Int) {
        switch option {
        case 1:
            Wormholy.shakeEnabled = true
            UserDefaults.standard.set(true,
                                      forKey: "is_log_enabled")
        case 2:
            Wormholy.shakeEnabled = false
            UserDefaults.standard.set(false,
                                      forKey: "is_log_enabled")
            UserDefaults.standard.synchronize()
        default:
            break
        }
    }
}
