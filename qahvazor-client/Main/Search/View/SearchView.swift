//
//  SearchView.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit

final class SearchView: CustomView {
    
    // MARK: - Constants
    private enum Constants {
        static let searchBarHeight: CGFloat = 44
        static let cancelButtonVerticalOffset: CGFloat = 5
    }
    
    // MARK: - UI Components
    @IBOutlet private(set) weak var collectionView: UICollectionView! {
        didSet {
            setupCollectionView()
        }
    }
    
    private(set) lazy var searchController: UISearchController = makeSearchController()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        
        // Force searchController initialization early
        _ = searchController
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupAccessibility()
    }
    
    private func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        
        // Register cell
        let cellNib = UINib(
            nibName: CompanyCollectionViewCell.defaultReuseIdentifier, 
            bundle: nil
        )
        collectionView.register(
            cellNib, 
            forCellWithReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier
        )
        
        // Additional collection view setup
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    private func setupAccessibility() {
        accessibilityLabel = "Search coffee shops view"
        collectionView?.accessibilityLabel = "Search results collection"
    }
    
    // MARK: - Search Controller Factory
    private func makeSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        
        // Configure search controller
        configureSearchController(searchController)
        
        // Configure search bar
        configureSearchBar(searchController.searchBar)
        
        // Configure appearance
        configureSearchBarAppearance()
        
        return searchController
    }
    
    private func configureSearchController(_ searchController: UISearchController) {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = nil
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.searchBarStyle = .minimal
    }
    
    private func configureSearchBar(_ searchBar: UISearchBar) {
        // Basic configuration
        searchBar.placeholder = "placeholderSearch".localized
        searchBar.setShowsCancelButton(true, animated: false)
        searchBar.updateHeight(height: Constants.searchBarHeight)
        searchBar.searchBarStyle = .minimal
        searchBar.isTranslucent = false
        
        // Styling
        configureSearchTextField(searchBar.searchTextField)
    }
    
    private func configureSearchTextField(_ textField: UITextField) {
        textField.backgroundColor = UIColor.appColor(.secondBackground)
        textField.textColor = .label
        textField.tintColor = .label
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        
        // Configure search icon
        configureSearchIcon(textField)
    }
    
    private func configureSearchIcon(_ textField: UITextField) {
        guard let glassIconView = textField.leftView as? UIImageView else { return }
        
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = .label
    }
    
    private func configureSearchBarAppearance() {
        let cancelButton = UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [UISearchBar.self]
        )
        cancelButton.setTitlePositionAdjustment(
            UIOffset(horizontal: 0, vertical: Constants.cancelButtonVerticalOffset), 
            for: .default
        )
    }
    
    // MARK: - Public Methods
    func activateSearch() {
        // Ensure search controller is properly configured before activation
        _ = searchController // This triggers lazy initialization
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.searchController.isActive = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.searchController.searchBar.becomeFirstResponder()
            }
        }
    }
    
    func deactivateSearch() {
        searchController.isActive = false
        searchController.searchBar.resignFirstResponder()
    }
}

