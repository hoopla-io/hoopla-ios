//
//  MainView.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

final class MainView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoryCollectionView: UICollectionView! {
        didSet {
            categoryCollectionView.register(MainCategoryCollectionViewCell.self, forCellWithReuseIdentifier: MainCategoryCollectionViewCell.defaultReuseIdentifier)
            categoryCollectionView.contentInset.left = 16
            categoryCollectionView.contentInset.right = 16
            categoryCollectionView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var shopCollectionView: UICollectionView! {
        didSet {
            shopCollectionView.register(UINib(nibName: CompanyCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cameraButton: UIButton! {
        didSet {
            if #available(iOS 26.0, *) {
                var config: UIButton.Configuration
                config = .clearGlass()
                config.baseForegroundColor = .appColor(.white)
                config.cornerStyle = .capsule
                config.imagePadding = 8
                cameraButton.configuration = config
            }
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
