//
//  SubscriptionCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 11/01/25.
//

import UIKit

class SubscriptionCollectionViewCell: CustomCollectionViewCell {
    //MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: FeatureCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: FeatureCollectionViewCell.defaultReuseIdentifier)
        }
    }
    
    //MARK: - Attributes
    var item: Subscription? {
        didSet {
            guard let item else { return }
            nameLabel.text = item.name
            priceLabel.text = item.descriptionPrice
            if let features = item.features {
                dataProvider.items = features
            }
        }
    }
    var dataProvider = SubscriptionFeatureDataProvider()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataProvider.collectionView = collectionView
    }

}
