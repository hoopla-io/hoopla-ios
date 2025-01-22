//
//  SearchViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit
import SkeletonView

class SearchViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = SearchView
    
    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: MainCoordinator?
    let viewModel = SearchViewModel()
    
    // MARK: - Data Providers
    private var dataProvider: SearchDataProvider?
    
    // MARK: - Attributes
    private var isKeyboadOpen = true
    var totalItems = 0
    var totalPages = 1
    var currentPage = 1
    
    // MARK: - Actions
    @objc func search(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        guard query.trimmingCharacters(in: .whitespaces) != "" else { return }
        guard query.count >= 2 else { return }
        currentPage = 1
        viewModel.getList(name: query)
    }
    
    @objc func clear(_ searchBar: UISearchBar) {
        navigationItem.searchController?.isActive = false
    }
    
    @objc func keyboardWillDisappear() {
        guard let items = dataProvider?.items else { return }
        guard items.isEmpty else { return }
        navigationItem.searchController?.isActive = false
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view().collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isKeyboadOpen {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.view().searchController.searchBar.becomeFirstResponder()
            }
            isKeyboadOpen = false
        }
    }
}

// MARK: - Networking
extension SearchViewController: SearchViewModelProtocol {
    func didFinishFetch(data: [Shop]?) {
        if let data {
            dataProvider?.items = data
        } else {
            dataProvider?.items.removeAll()
        }
        view().collectionView.checkEmpty(items: self.dataProvider?.items, type: .search)
    }
}

// MARK: - Other funcs
extension SearchViewController {
    private func appearanceSettings() {
        navigationItem.title = "coffeeShops".localized
        
        let dataProvider = SearchDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
        
        setupSearchBar()
        setupClearAction()
        viewModel.delegate = self
    }
    
    private func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = view().searchController
        view().searchController.searchBar.delegate = self
    }
    
    private func setupClearAction() {
        if let searchTextField = view().searchController.searchBar.value(forKey: "searchField") as? UITextField , let clearButton = searchTextField.value(forKey: "_clearButton")as? UIButton {
            clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    func nextPage() {
//        currentPage += 1
//        guard let text = view().searchController.searchBar.text, !text.isEmpty else { return }
//        viewModel.searchAll(text: text, page: currentPage)
//    }
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

