//
//  CodeConfirmViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import UIKit

protocol CodeConfirmViewControllerDelegate: NSObject {
    func didFinishFetchConfirm()
}

class CodeConfirmViewController: TextFieldViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = CodeConfirmView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: ProfileCoordinator?
    private let viewModel = CodeConfirmViewModel()
    weak var delegate: CodeConfirmViewControllerDelegate?
    
    // MARK: - Attributes
    private var progressTimer: Timer?
    private var duration: Double = 20.0 {
        didSet {
            guard duration >= 0.0 else {
                duration = 0.0
                progressTimer?.invalidate()
                view().resendButton.setTitle("resendCode".localized, for: .normal)
                view().resendButton.isUserInteractionEnabled = true
                view().resendButton.setTitleColor(.label, for: .normal)
                return
            }
            view().resendButton.setTitle("resendCode".localized + " " + duration.convertToTime(calendarType: [.minute, .second]), for: .normal)
        }
    }
    private var timeInterval: Double = 1
    var sessionId: String?
    var data: SignIn? {
        didSet {
            guard let data = data else { return }
            view().phoneNumber = data.phoneNumber ?? ""
            sessionId = data.sessionId
            guard let expireTime = data.sessionExpiresAt else { return }
            duration = Double(expireTime - Int(Date().timeIntervalSince1970))
        }
    }
    
    // MARK: - Actions
    @IBAction func resendAction(_ sender: UIButton) {
        guard let sessionId = sessionId else { return }
        viewModel.resendSms(sessionId: sessionId)
    }
    
    @IBAction func secondaryButtonsAction(_ sender: UIButton) {
//        switch sender.tag {
//        case 0:
//            coordinator?.pushWebViewVC(link: MainConstants.itvTermsOfUse.rawValue)
//        case 1:
//            coordinator?.pushWebViewVC(link: MainConstants.privacyPolicy.rawValue)
//        default:
//            break
//        }
    }
    
    @objc func progressAction() {
        duration -= timeInterval
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        setupProgressTimer()
        setLabelUnderline()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view().codeTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        progressTimer?.invalidate()
    }
    
}

// MARK: - Networking
extension CodeConfirmViewController: CodeConfirmViewModelProtocol {
    func didFinishFetch(data: Tokens) {
        if let _ = data.accessToken {
            UserDefaults.standard.saveTokens(data: data)
            resetTabBar()
        }
    }
    
    func didFinishFetchResend(data: SignIn) {
        duration = 90
        setupProgressTimer()
    }
}

// MARK: - Other funcs
extension CodeConfirmViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        view().codeTextField.updateProperties { [weak self] pro in
            pro.delegate = self
        }
        
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            view().labelBottomConstraint.constant -= keyboardHeight - 40
            UIView.animate(withDuration: 0.5) {
                self.view().layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            view().labelBottomConstraint.constant = keyboardHeight - 30
            UIView.animate(withDuration: 0.5) {
                self.view().layoutIfNeeded()
            }
        }
    }
    
    private func setupProgressTimer() {
        view().resendButton.isUserInteractionEnabled = false
        view().resendButton.setTitleColor(.secondaryLabel, for: .normal)
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(progressAction), userInfo: nil, repeats: true)
    }
    
    func setLabelUnderline() {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "StringWithUnderLine", attributes: underlineAttribute)
        view().privacyPolicyButton.titleLabel?.attributedText = underlineAttributedString
        view().termOfServicesButton.titleLabel?.attributedText = underlineAttributedString
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func nextSms(code: String) {
        guard let sessionId = sessionId else { return }
        viewModel.smsConfirm(sessionId: sessionId, code: code)
    }
}
// MARK: - Text field Delegate
extension CodeConfirmViewController: KAPinFieldDelegate {
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        nextSms(code: code)
    }
}

