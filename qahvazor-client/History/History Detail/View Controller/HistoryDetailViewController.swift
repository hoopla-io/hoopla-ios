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
    var totalPrice: Double = 0.0 {
        didSet {
            view().totalPriceLabel.text = totalPrice.formattedWithCurrency
        }
    }
    var cashbackUsed: Double? {
        didSet {
            view().cashbackUsedLabel.text = ("- " + (cashbackUsed?.formattedWithCurrency ?? "0"))
        }
    }
    var cashbackEarned: Double? {
        didSet {
            view().cashbackEarnedLabel.text = ("+ " + (cashbackEarned?.formattedWithCurrency ?? "0"))
        }
    }
    var data: OrderHistory? {
        didSet {
            view().shopLabel.text = data?.shopName
            view().drinkTitleLabel.text = data?.drinkName
            view().idLabel.text = String(data?.id ?? 0)
            totalPrice = data?.productPrice ?? 0.0
            cashbackEarned = data?.cashbackEarned
            cashbackUsed = data?.cashbackUsed
            navigationItem.title = DateFormatter.string(timestamp: data?.purchasedAtUnix, formatter: .fullDate)
            view().statusLabel.text = data?.orderStatus?.localized
            setStatusColor(data?.orderStatus)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
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
        self.data = data
        if let drinkImageUrl = data?.drinkImageUrl {
            view().imageView.setImage(with: drinkImageUrl)
        }
        view().getButton.isHidden = data?.fiscalLink == nil
        
        let orderStatus = OrderStatus(rawValue: data?.orderStatus ?? OrderStatus.cancelled.rawValue)
        view().completedButtonInfo.isHidden = !(orderStatus == .completed)
        view().cancelledButtonInfo.isHidden = !(orderStatus == .cancelled)
        view().cancelledButton.isHidden = !(orderStatus == .pending_payment)
        view().continuePaymentButton.isHidden = !(orderStatus == .pending_payment)
        view().getOrderButton.isHidden = (orderStatus == .cancelled)
        
        guard let items = data?.items else { return }
        for i in items.enumerated() {
            view().stackViews[i.offset].isHidden = false
            view().titles[i.offset].text = i.element.name
            view().prices[i.offset].text = ("+" + (i.element.price?.formattedWithCurrency ?? "0"))
        }
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
    
    func setStatusColor(_ type: String?) {
        guard let type = type, let colorType = OrderStatus(rawValue: type) else {
            view().statusLabel.textColor = .appColor(.green)
            return
        }
        switch colorType {
        case .pending, .preparing, .pending_payment:
            view().statusLabel.textColor = .appColor(.orange)
        case .cancelled:
            view().statusLabel.textColor = .appColor(.red)
        case .created:
            view().statusLabel.textColor = .lightGray
        case .completed:
            view().statusLabel.textColor = .appColor(.green)
        default:
            view().statusLabel.textColor = .lightGray
        }
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
