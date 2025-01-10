//
//  PartnerDetailViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 27/12/24.
//

import UIKit

class PartnerDetailViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = PartnerDetailView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: MainCoordinator?
    let viewModel = PartnerDetailViewModel()
    
    // MARK: - Attributes
    private var alphaStatusBar: CGFloat?
    var coffeeDataProvider: CoffeeListDataProvider?
    var shopsDataProvider: ShopsDataProvider?
    var socialDataProvider: SocialDataProvider?
    var partnerId: Int?
    
    // MARK: - Actions
    @IBAction func filialsAction(_ sender: Any) {
        coordinator?.pushToShopsListVC(id: partnerId)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        guard let partnerId else { return }
        viewModel.getPartnerInfo(id: partnerId)
        viewModel.getFilialsList(partnerId: partnerId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.clear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleStatusBar(alpha: alphaStatusBar)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        handleStatusBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.reset()
    }
    
}
// MARK: - Networking
extension PartnerDetailViewController: PartnerDetailViewModelProtocol {
    func didFinishFetch(data: [Shop]) {
        shopsDataProvider?.items = data
    }
    
    func didFinishFetch(data: Company) {
        var socialsData: [SocialMedia] = []
        if let imageUrl = data.logoUrl {
            view().titleImage.setImage(with: imageUrl)
        }
        view().titleLabel.text = data.name
        view().descriptionLabel.text = data.description
        
        if let drinks = data.drinks {
            coffeeDataProvider?.items = drinks
        }
        if let phone = data.phoneNumbers?.first {
            let item = SocialMedia(url: phone.phoneNumber, urlType: SocialUrlType.phone.rawValue)
            socialsData.append(item)
        }
        if let socials = data.urls {
            socialsData += socials
        }
        socialDataProvider?.items = socialsData
    }
}

// MARK: - Other funcs
extension PartnerDetailViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        view().scrollView.delegate = self
        
        let coffeeDataProvider = CoffeeListDataProvider()
        coffeeDataProvider.collectionView = view().coffeeListCollectionView
        self.coffeeDataProvider = coffeeDataProvider
        
        let shopsListdataProvider = ShopsDataProvider(viewController: self)
        shopsListdataProvider.collectionView = view().filialsListCollectionView
        self.shopsDataProvider = shopsListdataProvider
        
        let socialDataProvider = SocialDataProvider(viewController: self)
        socialDataProvider.collectionView = view().socialListCollectionView
        self.socialDataProvider = socialDataProvider
    }
    
    func callAction(phoneNumber: String?) {
        guard let phoneNumber else { return }
        if let url = URL(string: "tel://+\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PartnerDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        alphaStatusBar = handleStatusBar(scrollView: scrollView, topSpace: view().topConstraint.constant)
    }
}
