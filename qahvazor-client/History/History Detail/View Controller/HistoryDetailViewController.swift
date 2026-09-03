//
//  HistoryDetailViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//

import UIKit

class HistoryDetailViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    // MARK: - Root View
    typealias RootView = HistoryDetailView
    
    // MARK: - Services
    var coordinator: Coordinator?
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    let viewModel = HistoryViewModel()
    
    // MARK: - Attributes
    var data: OrderHistory? {
        didSet {
            guard isViewLoaded, let data else { return }
            configure(with: data)
        }
    }
    
    //MARK: - Actions
    @IBAction func getOrderAction(_ sender: Any) {
        guard let id = data?.id else { return }
        guard let coordinator = coordinator as? HistoryCoordinator else { return }
        coordinator.presentGetOrderVC(orderId: id)
    }
    @IBAction func getCheckAction(_ sender: Any) {
        guard let fiscalLink = data?.fiscalLink else { return }
        openViaSafariVC(fiscalLink, from: self)
    }
    @IBAction func checkoutAction(_ sender: Any) {
        guard let url = data?.checkoutUrl else { return }
        openViaSafariVC(url, from: self)
    }
    @IBAction func cancelAction(_ sender: Any) {
        showAlertCancel { [weak self] in
            guard let self else { return }
            guard let id = data?.id else { return }
            viewModel.cancelOrder(id: id)
        }
    }
    
    // MARK: - Life cycles
    override func loadView() {
        view = HistoryDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        setupActions()
        if let data { configure(with: data) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = data?.id else { return }
        viewModel.getOrderHistoryDetail(id: id)
    }
    
}
// MARK: - Networking
extension HistoryDetailViewController: HistoryViewModelProtocol {
    func didFinishFetch(data: OrderHistory?) {
        guard let data else { return }
        self.data = data
    }
    
    func didFinishFetchCancel() {
        guard let id = data?.id else { return }
        viewModel.getOrderHistoryDetail(id: id)
    }
}
// MARK: - Other funcs
extension HistoryDetailViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupActions() {
        view().getOrderButton.addTarget(self, action: #selector(getOrderAction(_:)), for: .touchUpInside)
        view().getButton.addTarget(self, action: #selector(getCheckAction(_:)), for: .touchUpInside)
        view().continuePaymentButton.addTarget(self, action: #selector(checkoutAction(_:)), for: .touchUpInside)
        view().cancelledButton.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        view().onRate = { [weak self] in
            guard let self, let data else { return }
            (coordinator as? HistoryCoordinator)?.presentReviewVC(data: data)
        }
    }

    private func configure(with data: OrderHistory) {
        navigationItem.title = data.shopName ?? data.partnerName
        view().configure(with: data)
    }
    
    func showAlertCancel(_ buttonAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "cancelOrder".localized, message: "cancelOrderMessage".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "keep".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .destructive, handler: { _ in
            buttonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
//998900472400
