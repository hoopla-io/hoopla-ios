//
//  ShopsListView.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit

final class ShopsListView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: ShopCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ShopCollectionViewCell.defaultReuseIdentifier)
        }
    }
}

