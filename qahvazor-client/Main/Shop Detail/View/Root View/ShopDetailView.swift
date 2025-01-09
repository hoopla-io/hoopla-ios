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
}
