//
//  LanguageView.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/12/24.
//

import UIKit

final class LanguageView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.register(UINib(nibName: LanguageCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: LanguageCollectionViewCell.defaultReuseIdentifier)
            collectionView.allowsMultipleSelection = false
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
}
