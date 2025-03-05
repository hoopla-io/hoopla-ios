//
//  PaymentView.swift
//  qahvazor-client
//
//  Created by Alphazet on 05/03/25.
//

import UIKit

final class PaymentView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: PaymentCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PaymentCollectionViewCell.defaultReuseIdentifier)
        }
    }
}
