//
//  GetOrderViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 14/05/26.
//

import UIKit

class GetOrderViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    // MARK: - Root View
    typealias RootView = GetOrderView

    // MARK: - Root View
    private let rootView = GetOrderView()

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    let viewModel = GetOrderViewModel()

    // MARK: - Attributes
    var orderId: Int?

    // MARK: - Life cycle
    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()

        guard let orderId else { return }
        viewModel.getOrder(id: orderId)
    }

}
// MARK: - Networking
extension GetOrderViewController: GetOrderViewModelProtocol {
    func didFinishFetch(data: GetOrder?) {
        view().configure(order: data)
    }

}

// MARK: - Other funcs
extension GetOrderViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        view().doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
    }

    @objc private func dismissAction() {
        dismiss(animated: true)
    }

}
