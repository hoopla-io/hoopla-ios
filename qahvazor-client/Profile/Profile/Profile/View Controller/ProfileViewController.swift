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
    var wasAuthed = false
    private var alphaStatusBar: CGFloat?
    
    // MARK: - Actions
    @IBAction func loginAction(_ sender: UIButton) {
        next()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        checkForVpn()
        wasAuthed = UserDefaults.standard.isAuthed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.clear()
        
        if UserDefaults.standard.isAuthed() {
//            viewModel.getMe()
        } else if wasAuthed {
//            didFinishFetchLogOut()
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
    func didFinishFetch(data: SignIn) {
        coordinator?.pushToCodeConfirmVC(data: data)
    }
}

// MARK: - Other funcs
extension ProfileViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        
        checkAuth()
    }
    
    private func checkAuth() {
        if UserDefaults.standard.isAuthed() {
            
        } else {
            setupTextFields(textFields: [view().textField], button: view().loginButton)
        }
    }
    
    private func checkForVpn() {
//        guard UserDefaults.standard.isVpn() else { return }
//        view().balanceLabel.isHidden = true
//        view().balanceTitleLabel.isHidden = true
//        view().mainButtons.filter { $0.tag == 9 }.first?.isHidden = true
//        view().mainButtons.filter { $0.tag == 6 }.first?.isHidden = true
//        view().mainButtons.filter { $0.tag == 4 }.first?.isHidden = true
//        view().mainButtons.filter { $0.tag == 5 }.first?.isHidden = true
//        view().mainButtons.filter { $0.tag == 10 }.first?.isHidden = true
    }
    
    //Authorization
    override func textFieldDidChange(_ textField: UITextField?) {
        guard let textField = textField, let text = textField.text else { return }
        textField.text = text.displayPhone()
    }
    
    override func next() {
        switch status() {
        case .active:
            coordinator?.pushToCodeConfirmVC()
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
//        alphaStatusBar = handleStatusBar(scrollView: scrollView, topSpace: view().imageHeightConstraint.constant)
    }
}

// MARK: - SettingsViewControllerDelegate
//extension ProfileViewController: SettingsViewControllerDelegate {
//    func didSelectLanguage() {
//        resetTabBar()
//    }
//}

//MARK: - Scroll to up
extension ProfileViewController: TabBarReselectHandling {
    func handleReselect() {
//        view().scrollView.setContentOffset(CGPoint(x: 0, y: -90), animated: true)
    }
}

