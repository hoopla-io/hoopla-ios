//
//  SearchViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit
import SkeletonView

final class SearchViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = SearchView
    
    // MARK: - Constants
    private enum Constants {
        static let minimumSearchLength = 1
        static let searchDelay: TimeInterval = 0.5
        static let keyboardActivationDelay: TimeInterval = 0.3
    }
    
    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    weak var coordinator: MainCoordinator?
    private let viewModel = SearchViewModel()
    
    // MARK: - Data Providers
    private var dataProvider: SearchDataProvider?
    
    // MARK: - Attributes
    private var shouldActivateKeyboard = true
    private var partners: [Company] = []
    
    // MARK: - Deinitializer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc private func search(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespaces),
              !query.isEmpty,
              query.count >= Constants.minimumSearchLength else { 
            return 
        }
        
        showPartners(matching: query)
    }
    
    @objc private func keyboardWillDisappear() {
        guard dataProvider?.isEmpty == true else { return }
        navigationItem.searchController?.isActive = false
    }
    
    // MARK: - Life cycle
    override func loadView() {
        view = SearchView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view().collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldActivateKeyboard {
            activateSearchWithDelay()
            shouldActivateKeyboard = false
        }
    }
    
    // MARK: - Private Methods
    private func activateSearchWithDelay() {
        // Use a proper delay to avoid keyboard device property errors
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.keyboardActivationDelay) { [weak self] in
            guard let self = self else { return }
            
            // Ensure the view is properly loaded and visible
            guard self.isViewLoaded && self.view.window != nil else { return }
            
            self.view().searchController.isActive = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.view().searchController.searchBar.becomeFirstResponder()
            }
        }
    }

    private func showPartners(matching query: String) {
        let filteredPartners = partners.filter {
            $0.name?.range(
                of: query,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) != nil
        }
        dataProvider?.showPartners(filteredPartners)
        view().collectionView.checkEmpty(items: filteredPartners, type: .search)
    }
}

// MARK: - Networking
extension SearchViewController: SearchViewModelProtocol {
    func didFinishFetch(partners: [Company]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.partners = partners
            let query = self.view().searchController.searchBar.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if query.isEmpty {
                self.dataProvider?.showPartners(partners)
                self.view().collectionView.checkEmpty(items: partners, type: .search)
            } else if query.count >= Constants.minimumSearchLength {
                self.showPartners(matching: query)
            }
        }
    }
}

// MARK: - Setup Methods
extension SearchViewController {
    private func setupViewController() {
        setupUI()
        setupDataProvider()
        setupSearchBar()
        setupViewModel()
        viewModel.getPartners()
    }
    
    private func setupUI() {
        navigationItem.title = "coffeeShops".localized
    }
    
    private func setupDataProvider() {
        let dataProvider = SearchDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
    }
    
    private func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Set the search controller to navigation item
        navigationItem.searchController = view().searchController
        
        // Configure delegate after setting up the controller
        view().searchController.searchBar.delegate = self
        
        // Prevent the search controller from defining presentation context
        view().searchController.definesPresentationContext = false
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }

    func didSelectPartner(_ partner: Company) {
        guard partner.id != nil else { return }
        view().searchController.searchBar.resignFirstResponder()
        coordinator?.pushToSearchShop(partner: partner)
    }
}

// MARK: - Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: searchBar)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            dataProvider?.showPartners(partners)
            view().collectionView.checkEmpty(items: partners, type: .search)
        } else if query.count < Constants.minimumSearchLength {
            dataProvider?.showPartners([])
            view().collectionView.restore()
        } else {
            perform(#selector(search), with: searchBar, afterDelay: Constants.searchDelay)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
