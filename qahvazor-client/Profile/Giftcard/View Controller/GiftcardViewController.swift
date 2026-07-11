//
//  GiftcardViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 11/07/26.
//

import UIKit

protocol GiftcardViewControllerDelegate: AnyObject {
    func giftcardViewController(_ viewController: GiftcardViewController, didRedeem data: GiftcardRedemption)
}

final class GiftcardViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    typealias RootView = GiftcardView

    weak var delegate: GiftcardViewControllerDelegate?
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    private let viewModel = GiftcardViewModel()

    override func loadView() {
        view = GiftcardView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        view().textField.delegate = self
        view().textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view().activateButton.addTarget(self, action: #selector(activateTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.view().textField.becomeFirstResponder()
        }
    }
}

private extension GiftcardViewController {
    @objc func textFieldDidChange() {
        let code = view().textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        view().setActivateButtonEnabled(!code.isEmpty)
    }

    @objc func activateTapped() {
        let code = view().textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased() ?? ""
        guard !code.isEmpty else { return }

        Task { @MainActor in
            await viewModel.redeem(code: code)
        }
    }
}

extension GiftcardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activateTapped()
        return false
    }
}

extension GiftcardViewController: GiftcardViewModelProtocol {
    func didFinishRedeem(data: GiftcardRedemption) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.giftcardViewController(self, didRedeem: data)
        }
    }
}
