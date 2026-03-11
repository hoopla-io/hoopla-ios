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

    // MARK: - Attributes
    var totalPrice: Double = 0.0 {
        didSet {
            view().totalPriceLabel.text = totalPrice.formattedWithCurrency
        }
    }
    var selectedSugar: Modification? {
        didSet {
            guard let selectedSugar else  { return }
            view().sugarTitleLabel.text = selectedSugar.modificationName
            view().sugarPriceLabel.text = ("+" + (selectedSugar.modificationPrice?.formattedWithCurrency ?? "0"))
            view().sugarStackView.isHidden = false
        }
    }
    var selectedSize: Modification? {
        didSet {
            guard let selectedSize else  { return }
            view().sizePriceLabel.text = ("+" + (selectedSize.modificationPrice?.formattedWithCurrency ?? "0"))
            view().sizeTitleLabel.text = selectedSize.modificationName
            view().sizeStackView.isHidden = false
        }
    }
    var selectedMilk: Modification? {
        didSet {
            guard let selectedMilk else  { return }
            view().milkPriceLabel.text = ("+" + (selectedMilk.modificationPrice?.formattedWithCurrency ?? "0"))
            view().milkTitleLabel.text = selectedMilk.modificationName
            view().milkStackView.isHidden = false
        }
    }
    var selectedSyrop: Modification? {
        didSet {
            guard let selectedSyrop else  { return }
            view().syropPriceLabel.text = ("+" + (selectedSyrop.modificationPrice?.formattedWithCurrency ?? "0"))
            view().syropTitleLabel.text = selectedSyrop.modificationName
            view().syropStackView.isHidden = false
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
    @IBAction func confirmOrderAction(_ sender: Any) {
        
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
}

// MARK: - Other funcs
extension HistoryDetailViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}
