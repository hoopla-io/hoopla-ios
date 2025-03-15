//
//  ProfileViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import UIKit
import Haptica

class ProfileViewController: TextFieldViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = ProfileView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: ProfileCoordinator?
    let viewModel = ProfileViewModel()
    
    // MARK: - Attributes
    private var alphaStatusBar: CGFloat?
    
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
        default: break
        }
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        showAlertDestructive(message: "logoutAlert".localized, buttonTitle: "logout".localized) {
            self.viewModel.logOut()
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.clear()
        if UserDefaults.standard.isAuthed() {
            viewModel.getMe()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleStatusBar(alpha: alphaStatusBar)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        handleStatusBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.reset()
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
        view().subscription = data.subscription
    }
    
    func didFinishFetchLogout() {
        UserDefaults.standard.removeAccount()
        resetTabBar()
        checkAuth()
    }
}

// MARK: - Other funcs
extension ProfileViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        
        if let releaseVersionNumber = Bundle.main.releaseVersionNumber {
            view().versionLabel.text = "version".localized + Symbols.space.rawValue + releaseVersionNumber
        }
        checkAuth()
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

// MARK: - UIScrollViewDelegate
extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        alphaStatusBar = handleStatusBar(scrollView: scrollView, topSpace: 50)
    }
}

// MARK: - SettingsViewControllerDelegate
extension ProfileViewController: LanguageViewControllerDelegate {
    func didSelectLanguage() {
        resetTabBar()
    }
}

//MARK: - Scroll to up
extension ProfileViewController: TabBarReselectHandling {
    func handleReselect() {
        view().scrollView.setContentOffset(CGPoint(x: 0, y: -90), animated: true)
    }
}

