//
//  ShopDetailView.swift
//  qahvazor-client
//
//  Created by Alphazet on 09/01/25.
//

import UIKit

class ShopDetailView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: PhotoCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var showMoreButton: UIButton!
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
}
