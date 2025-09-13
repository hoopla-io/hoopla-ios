//
//  ConfirmOrderView.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/06/25.
//

import UIKit

final class ConfirmOrderView: CustomView {
    //MARK: - Outlets
//    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var drinkLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var onsStackView: UIStackView! {
        didSet {
            onsStackView.isHidden = true
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: FilterGenresCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: FilterGenresCollectionViewCell.defaultReuseIdentifier)
            collectionView.contentInset.left = -20
        }
    }
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
}

