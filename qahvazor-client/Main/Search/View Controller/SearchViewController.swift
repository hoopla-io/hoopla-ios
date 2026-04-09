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
        static let minimumSearchLength = 2
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
    private var totalItems = 0
    private var totalPages = 1
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Deinitializer
    deinit {
        searchTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc private func search(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespaces),
              !query.isEmpty,
              query.count >= Constants.minimumSearchLength else { 
            return 
        }
        
        currentPage = 1
        viewModel.getList(name: query)
    }
    
    @objc private func clear(_ searchBar: UISearchBar) {
        dataProvider?.items.removeAll()
        navigationItem.searchController?.isActive = false
    }
    
    @objc private func keyboardWillDisappear() {
        guard let items = dataProvider?.items, items.isEmpty else { return }
        navigationItem.searchController?.isActive = false
    }
    
    // MARK: - Life cycle
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
}

// MARK: - Networking
extension SearchViewController: SearchViewModelProtocol {
    func didFinishFetch(data: [Shop]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let data = data {
                self.dataProvider?.items = data
                self.totalItems = data.count
            } else {
                self.dataProvider?.items.removeAll()
                self.totalItems = 0
            }
            
            self.view().collectionView.checkEmpty(
                items: self.dataProvider?.items, 
                type: .search
            )
        }
    }
}

// MARK: - Setup Methods
extension SearchViewController {
    private func setupViewController() {
        setupUI()
        setupDataProvider()
        setupSearchBar()
        setupClearAction()
        setupViewModel()
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
    
    private func setupClearAction() {
        setupClearButton()
        setupKeyboardNotifications()
    }
    
    private func setupClearButton() {
        guard let searchTextField = view().searchController.searchBar.value(forKey: "searchField") as? UITextField,
              let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton else {
            return
        }
        
        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
}

// MARK: - Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: searchBar)
        perform(#selector(search), with: searchBar, afterDelay: 0.5)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

