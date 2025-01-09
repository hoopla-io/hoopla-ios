//
//  PartnerDetailView.swift
//  qahvazor-client
//
//  Created by Alphazet on 27/12/24.
//

import UIKit

final class PartnerDetailView: CustomView {
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var coffeeListCollectionView: UICollectionView! {
        didSet {
            coffeeListCollectionView.register(UINib(nibName: CoffeeCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CoffeeCollectionViewCell.defaultReuseIdentifier)
        }
    }
    
    @IBOutlet weak var filialsListCollectionView: UICollectionView! {
        didSet {
            filialsListCollectionView.register(UINib(nibName: ShopCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ShopCollectionViewCell.defaultReuseIdentifier)
        }
    }
    
    @IBOutlet weak var socialListCollectionView: UICollectionView! {
        didSet {
            socialListCollectionView.register(UINib(nibName: SocialCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: SocialCollectionViewCell.defaultReuseIdentifier)
        }
    }
}
