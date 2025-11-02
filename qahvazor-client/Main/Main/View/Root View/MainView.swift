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
    @IBOutlet weak var rewardsStackView: UIStackView!
    @IBOutlet weak var rewardsCollectionView: UICollectionView! {
        didSet {
            rewardsCollectionView.register(UINib(nibName: RewardsCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: RewardsCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var shopCollectionView: UICollectionView! {
        didSet {
            shopCollectionView.register(UINib(nibName: CompanyCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
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
