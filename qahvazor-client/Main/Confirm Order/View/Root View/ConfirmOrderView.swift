//
//  ConfirmOrderView.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/06/25.
//

import UIKit

final class ConfirmOrderView: CustomView {
    //MARK: - Outlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var drinkSizeStackView: UIStackView! {
        didSet {
            drinkSizeStackView.isHidden = true
        }
    }
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var drinkLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sugarStackView: UIStackView! {
        didSet {
            sugarStackView.isHidden = true
        }
    }
    @IBOutlet weak var sugarSegmentControl: UISegmentedControl!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var milkCollectionView: UICollectionView! {
        didSet {
            milkCollectionView.register(UINib(nibName: ItemsCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ItemsCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var syrupCollectionView: UICollectionView! {
        didSet {
            syrupCollectionView.register(UINib(nibName: ItemsCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ItemsCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var milkCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var syrupCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var milkStackView: UIStackView! {
        didSet {
            milkStackView.isHidden = true
        }
    }
    @IBOutlet weak var syrupStackView: UIStackView! {
        didSet {
            syrupStackView.isHidden = true
        }
    }
    @IBOutlet weak var priceButton: UIButton! {
        didSet {
            if #available(iOS 26.0, *) {
                var config: UIButton.Configuration
                config = .clearGlass()
                config.baseForegroundColor = .appColor(.white)
                config.cornerStyle = .large
                priceButton.configuration = config
            }
        }
    }
}

