//
//  PromocodeViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 08/07/26.
//

import UIKit

protocol PromocodeViewControllerDelegate: AnyObject {
    func promocodeViewController(_ viewController: PromocodeViewController, didApply promocode: PromocodePreview)
}

final class PromocodeViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    typealias RootView = PromocodeView

    weak var delegate: PromocodeViewControllerDelegate?
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    let viewModel = PromocodeViewModel()
    var shopId: Int?
    var drinkId: Int?
    var modifiers = [Modification]()

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
        viewModel.delegate = self
        view().textField.delegate = self
        view().textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view().applyButton.addTarget(self, action: #selector(applyAction), for: .touchUpInside)
    }

    @objc func textFieldDidChange() {
        let text = view().textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        view().setApplyButtonEnabled(!text.isEmpty)
    }

    @objc func applyAction() {
        let code = view().textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
        guard !code.isEmpty else { return }
        guard let shopId, let drinkId else { return }

        Task { @MainActor in
            await viewModel.checkPromocode(code: code, shopId: shopId, drinkId: drinkId, modifiers: modifiers)
        }
    }
}

extension PromocodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        applyAction()
        return false
    }
}

extension PromocodeViewController: PromocodeViewModelProtocol {
    func didFinishCheckPromocode(data: PromocodePreview) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.promocodeViewController(self, didApply: data)
        }
    }
}
