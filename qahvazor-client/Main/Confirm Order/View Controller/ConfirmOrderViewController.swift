//
//  ConfirmOrderViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/06/25.
//

import UIKit

class ConfirmOrderViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = ConfirmOrderView
    
    // MARK: - Services
    var coordinator: MainCoordinator?
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    let viewModel = ConfirmOrderViewModel()
    
    // MARK: - Data Provider
    var milkDataProvider: MilkDataProvider?
    var syrupDataProvider: SyrupDataProvider?
    
    // MARK: - Attributes
    var drinkData: Drinks? {
        didSet {
            view().drinkLabel.text = "\(drinkData?.name ?? "")"
            if let imageUrl = drinkData?.pictureUrl {
                view().imageView.setImage(with: imageUrl)
            }
            productPrice = drinkData?.productPrice ?? 0.0
        }
    }
    var productPrice: Double = 0.0 {
        didSet {
            view().orderButton.setTitle(productPrice.formattedWithCurrency, for: .normal)
        }
    }
    var shopData: Shop? {
        didSet {
            view().shopLabel.text = shopData?.name
            guard let shopId = shopData?.id, let drinkId = drinkData?.id else { return }
            viewModel.validateOrder(drinkId: drinkId, shopId: shopId)
        }
    }
    var selectedSugar: Modification?
    var selectedSize: Modification?
    var selectedMilk: Modification?
    var selectedSyrop: Modification?
    var size: [Modification]?
    var sugar: [Modification]?
    
    //MARK: - Actions
    @IBAction func sizeAction(_ sender: UISegmentedControl) {
        guard let size else { return }
        let selectedIndex = sender.selectedSegmentIndex
        selectedSize = size[selectedIndex]
        changePricingAction()
    }
    
    @IBAction func sugarAction(_ sender: UISegmentedControl) {
        guard let sugar else { return }
        let selectedIndex = sender.selectedSegmentIndex
        selectedSugar = sugar[selectedIndex]
        changePricingAction()
    }
    
    @IBAction func confirmOrderAction(_ sender: Any) {
        coordinator?.pushToCheckoutVC(sugar: selectedSugar, size: selectedSize, milk: selectedMilk, syrop: selectedSyrop, shopData: shopData, drinkData: drinkData, totalPrice: productPrice)
    }
    
    func changePricingAction() {
        let sizePrice = selectedSize?.modificationPrice ?? 0.0
        let sugarPrice = selectedSugar?.modificationPrice ?? 0.0
        let milkPrice = selectedMilk?.modificationPrice ?? 0.0
        let syropPrice = selectedSyrop?.modificationPrice ?? 0.0
        productPrice = (drinkData?.productPrice ?? 0.0) + sizePrice + sugarPrice + milkPrice + syropPrice
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
}

// MARK: - Networking
extension ConfirmOrderViewController: ConfirmOrderViewModelProtocol {
    func didFinishFetch(data: Modifications?) {
        guard let data else { return }
        if let sugar = data.sugar {
            view().sugarSegmentControl.removeAllSegments()
            sugar.enumerated().forEach { index, item in
                let title: String = (item.modificationName ?? "") + "\n+" + (item.modificationPrice?.formattedWithCurrency ?? "0")
                view().sugarSegmentControl.insertSegment(withTitle: title, at: index, animated: false)
            }
            view().sugarSegmentControl.selectedSegmentIndex = 0
            view().sugarStackView.isHidden = sugar.isEmpty
            selectedSugar = sugar.first
            self.sugar = sugar
        }
        if let size = data.size {
            view().segmentControl.removeAllSegments()
            size.enumerated().forEach { index, item in
                let title: String = (item.modificationName ?? "") + "\n+" + (item.modificationPrice?.formattedWithCurrency ?? "0")
                view().segmentControl.insertSegment(withTitle: title, at: index, animated: false)
            }
            view().segmentControl.selectedSegmentIndex = 0
            self.size = size
            selectedSize = size.first
            view().drinkSizeStackView.isHidden = size.isEmpty
        }
        if let milk = data.milk {
            milkDataProvider?.items = milk
            view().milkCollectionHeight.constant = milkDataProvider?.collectionView.collectionViewLayout.collectionViewContentSize.height ?? 0
            milkDataProvider?.collectionView.layoutIfNeeded()
            view().milkStackView.isHidden = milk.isEmpty
        }
        if let syrup = data.syrup {
            syrupDataProvider?.items = syrup
            view().syrupCollectionHeight.constant = syrupDataProvider?.collectionView.collectionViewLayout.collectionViewContentSize.height ?? 0
            syrupDataProvider?.collectionView.layoutIfNeeded()
            view().syrupStackView.isHidden = syrup.isEmpty
        }
    }
}
// MARK: - Other funcs
extension ConfirmOrderViewController {
    private func appearanceSettings() {
        navigationItem.largeTitleDisplayMode = .never
        viewModel.delegate = self
        navigationItem.title = "orderSummary".localized
        
        let milkDataProvider = MilkDataProvider(viewController: self)
        milkDataProvider.collectionView = view().milkCollectionView
        self.milkDataProvider = milkDataProvider
        
        let syrupDataProvider = SyrupDataProvider(viewController: self)
        syrupDataProvider.collectionView = view().syrupCollectionView
        self.syrupDataProvider = syrupDataProvider
        
        view().segmentControl.selectedSegmentTintColor = .main
        view().segmentControl.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.white
        ], for: .selected)
        view().sugarSegmentControl.selectedSegmentTintColor = .main
        view().sugarSegmentControl.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.white
        ], for: .selected)
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

    }
}

