//
//  SubscriptionView.swift
//  qahvazor-client
//
//  Created by Alphazet on 11/01/25.
//

import UIKit

final class SubscriptionView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: SubscriptionCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: SubscriptionCollectionViewCell.defaultReuseIdentifier)
        }
    }
}
