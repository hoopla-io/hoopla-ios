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
            totalPrice = data?.productPrice ?? 0.0
            cashbackEarned = data?.cashbackEarned
            cashbackUsed = data?.cashbackUsed
            navigationItem.title = DateFormatter.string(timestamp: data?.purchasedAtUnix, formatter: .fullDate)
        }
    }
    
    //MARK: - Actions
    @IBAction func getCheckAction(_ sender: Any) {
        guard let fiscalLink = data?.fiscalLink else { return }
        openViaSafariVC(fiscalLink, from: self)
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        guard let id = data?.id else { return }
        viewModel.getOrderHistoryDetail(id: id)
    }
    
}
// MARK: - Networking
extension HistoryDetailViewController: HistoryViewModelProtocol {
    func didFinishFetch(data: OrderHistory?) {
        if let drinkImageUrl = data?.drinkImageUrl {
            view().imageView.setImage(with: drinkImageUrl)
        }
        view().getButton.isHidden = data?.fiscalLink == nil
        guard let items = data?.items else { return }
        for i in items.enumerated() {
            view().stackViews[i.offset].isHidden = false
            view().titles[i.offset].text = i.element.name
            view().prices[i.offset].text = ("+" + (i.element.price?.formattedWithCurrency ?? "0"))
        }
    }
}
// MARK: - Other funcs
extension HistoryDetailViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}
