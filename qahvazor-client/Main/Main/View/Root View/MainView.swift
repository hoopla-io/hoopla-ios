//
//  MainView.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

final class MainView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: CompanyCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier)
        }
    }
    
    lazy var notificationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 24, weight: .bold),
            forImageIn: .normal
        )
        return button
    }()
}
