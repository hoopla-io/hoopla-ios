//
//  AlertViewController.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import SwiftMessages
import DeviceKit

protocol AlertViewController {
    func addErrorAlertView(error: (APIError, String?), completion: (() -> ())?)
    func showAlert(title: String, message: String, buttonAction: (()->())?)
    func showAlertWithTwoButtons(title: String, message: String, firstButtonText: String, firstButtonAction: (()->())?, secondButtonText: String, secondButtonAction: (()->())?)
}

extension AlertViewController where Self: UIViewController {
    @MainActor func addErrorAlertView(error: (APIError, String?), completion: (() -> ())? = nil) {
        switch error.0 {
        case .requestFailed:
            showWarningAlert(message: AlertViewTexts.noInternetConnection.rawValue.localized)
        case .notAuthorized:
            guard let navigationController = self.navigationController else { return }
            let vc = ProfileViewController()
            vc.coordinator = ProfileCoordinator(navigationController: navigationController)
            self.navigationController?.pushViewController(vc, animated: true)
        case .fromMessage, .serverError:
            guard let message = error.1 else { return }
            showErrorAlert(message: message)
        default:
            showErrorAlert(message: AlertViewTexts.errorMSG.rawValue.localized)
        }
    }
    
    func showAlert(title: String, message: String, buttonAction: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default, handler: { (action) in
            buttonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertWithTwoButtons(title: String, message: String, firstButtonText: String, firstButtonAction: (()->())? = nil, secondButtonText: String, secondButtonAction: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: firstButtonText, style: UIAlertAction.Style.default, handler: { (action) in
            firstButtonAction?()
        }))
        alert.addAction(UIAlertAction(title: secondButtonText, style: UIAlertAction.Style.default, handler: { (action) in
            secondButtonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertWithTextField(title: String, message: String, buttonAction: ((_ text: String?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "continue".localized, style: UIAlertAction.Style.default, handler: { (action) in
            guard let textField =  alert.textFields?.first else {
                buttonAction?(nil)
                return
            }
            buttonAction?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertDestructive(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .actionSheet, buttonTitle: String, _ buttonAction: (() -> Void)? = nil) {
        var preferredStyle = preferredStyle
        if (UIDevice.current.userInterfaceIdiom == .pad) { preferredStyle = UIAlertController.Style.alert }
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: buttonTitle, style: .destructive, handler: { _ in
            buttonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showCallPhoneActionSheet(items: [PhoneNumber], preferredStyle: UIAlertController.Style = .actionSheet, completion: @escaping ((_ text: String?) -> Void)) {
        var preferredStyle = preferredStyle
        if (UIDevice.current.userInterfaceIdiom == .pad) { preferredStyle = UIAlertController.Style.alert }
        
        let alert = UIAlertController(title: "", message: "phoneNumber".localized, preferredStyle: preferredStyle)
        items.indices.forEach { index in
            alert.addAction(UIAlertAction(title: items[index].phoneNumber?.displayPhone(), style: .default, handler: { _ in
                completion(items[index].phoneNumber)
            }))
        }
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension AlertViewController where Self: UIViewController {
    @MainActor func showErrorAlert(message: String? = nil) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: message, body: nil, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "ok".localized, buttonTapHandler: { _ in SwiftMessages.hide() })
        view.configureTheme(backgroundColor: UIColor.appColor(.alertBackground), foregroundColor: UIColor.appColor(.red), iconImage: .appImage(.error))
        view.accessibilityPrefix = "error"
        view.button?.isHidden = true
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .automatic
        SwiftMessages.show(config: config, view: view)
    }
    
    @MainActor func showWarningAlert(message: String? = nil, duration: SwiftMessages.Duration = .automatic, tapHandler : ((_ view: BaseView) -> Void)? = nil) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: message, body: nil, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "ok".localized, buttonTapHandler: { _ in SwiftMessages.hide() })
        view.configureTheme(backgroundColor: UIColor.appColor(.alertBackground), foregroundColor: UIColor.appColor(.orange), iconImage: .appImage(.warning))
        view.accessibilityPrefix = "warning"
        view.button?.isHidden = true
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        view.tapHandler = tapHandler
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = duration
        SwiftMessages.show(config: config, view: view)
    }
    
    @MainActor func showSuccessAlert(message: String? = nil) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: message, body: nil, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "ok".localized, buttonTapHandler: { _ in SwiftMessages.hide() })
        view.configureTheme(backgroundColor: UIColor.appColor(.alertBackground), foregroundColor: UIColor.appColor(.green), iconImage: .appImage(.success))
        view.accessibilityPrefix = "success"
        view.button?.isHidden = true
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .automatic
        SwiftMessages.show(config: config, view: view)
    }
    
    @MainActor func showInfoAlert(message: String? = nil) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: message, body: nil, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "ok".localized, buttonTapHandler: { _ in SwiftMessages.hide() })
        view.configureTheme(backgroundColor: UIColor.appColor(.alertBackground), foregroundColor: .systemBlue, iconImage: .appImage(.infoAlert))
        view.accessibilityPrefix = "info"
        view.button?.isHidden = true
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        var config = SwiftMessages.defaultConfig
        config.dimMode = .blur(style: .dark, alpha: 1.0, interactive: true)
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        SwiftMessages.show(config: config, view: view)
    }
}
