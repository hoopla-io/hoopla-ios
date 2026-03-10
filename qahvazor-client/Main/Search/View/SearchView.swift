//
//  SearchView.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit

final class SearchView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: CompanyCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier)
        }
    }
    
    lazy var searchController: UISearchController = makeSearchController()
    
    private func makeSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        let searchBar = searchController.searchBar
        searchBar.searchTextField.backgroundColor = UIColor.appColor(.secondBackground)
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.updateHeight(height: 44)
        searchBar.placeholder = "placeholderSearch".localized
        
        let cancelButton = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        cancelButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 5), for: .default)
        
        let searchTextField = searchBar.searchTextField
        searchTextField.textColor = .label
        
        let glassIconView = searchTextField.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = .label
        
        return searchController
    }
    
}

