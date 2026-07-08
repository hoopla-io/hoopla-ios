//
//  PromocodeViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 08/07/26.
//

import UIKit

protocol PromocodeViewControllerDelegate: AnyObject {
    func promocodeViewController(_ viewController: PromocodeViewController, didApply code: String)
}

final class PromocodeViewController: UIViewController, ViewSpecificController {
    typealias RootView = PromocodeView

    weak var delegate: PromocodeViewControllerDelegate?

    override func loadView() {
        view = PromocodeView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.view().textField.becomeFirstResponder()
        }
    }
}

private extension PromocodeViewController {
    func appearanceSettings() {
        view().textField.delegate = self
        view().textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view().applyButton.addTarget(self, action: #selector(applyAction), for: .touchUpInside)
    }

    @objc func textFieldDidChange() {
        let text = view().textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        view().setApplyButtonEnabled(!text.isEmpty)
    }

    @objc func applyAction() {
        let code = view().textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else { return }

        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.promocodeViewController(self, didApply: code)
        }
    }
}

extension PromocodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        applyAction()
        return false
    }
}
