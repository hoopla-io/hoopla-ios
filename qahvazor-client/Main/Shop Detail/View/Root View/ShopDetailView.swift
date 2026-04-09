//
//  ShopDetailView.swift
//  qahvazor-client
//
//  Created by Alphazet on 09/01/25.
//

import UIKit

class ShopDetailView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    @IBOutlet weak var topContainerView: UIView! {
        didSet {
            topContainerView.layer.cornerRadius = 30
            topContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    @IBOutlet weak var gradientView: GradientView! {
        didSet {
            gradientView.startPointX = 0.5
            gradientView.startPointY = 1.0  // bottom
            gradientView.endPointX   = 0.5
            gradientView.endPointY   = 0.0  // top
            gradientView.topColor = .black.withAlphaComponent(0.9)
            gradientView.bottomColor = .clear
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var workingHoursButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: PhotoCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton! {
        didSet {
            phoneNumberButton.isHidden = true
        }
    }
    @IBOutlet weak var coffeeListCollectionView: UICollectionView! {
        didSet {
            coffeeListCollectionView.register(UINib(nibName: CoffeeCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CoffeeCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var coffeeCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var socialListCollectionView: UICollectionView! {
        didSet {
            socialListCollectionView.register(UINib(nibName: SocialCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: SocialCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var closedLabel: UILabel! {
        didSet {
            closedLabel.isHidden = true
        }
    }
}
