//
//  CheckoutView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//


import UIKit

final class CheckoutView: CustomView {
    //MARK: - Outlets
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var drinkTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var drinkLabel: UILabel!
    @IBOutlet weak var drinkPriceLabel: UILabel!

    @IBOutlet weak var modifierStackView: UIStackView! {
        didSet {
            configureModifierCollectionView()
        }
    }
    private(set) var modifierCollectionViewHeightConstraint: NSLayoutConstraint!
    let modifierCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            CheckoutModifierCollectionViewCell.self,
            forCellWithReuseIdentifier: CheckoutModifierCollectionViewCell.defaultReuseIdentifier
        )
        return collectionView
    }()
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentStackView: UIStackView! {
        didSet {
            commentStackView.isHidden = true
        }
    }
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var oldPriceLabel: UILabel! {
        didSet {
            oldPriceLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var cashbackSwitch: UISwitch!
    @IBOutlet weak var cashbackPriceLabel: UILabel!
    @IBOutlet weak var cashbackContainerView: GradientView! {
            didSet {
                cashbackContainerView.topColor = UIColor(hex: "#BC4C59") ?? .red
                cashbackContainerView.bottomColor = UIColor(hex: "#E45E6D") ?? .red
            }
        }
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            if #available(iOS 26.0, *) {
                var config: UIButton.Configuration
                config = .clearGlass()
                config.baseForegroundColor = .appColor(.white)
                config.cornerStyle = .large
                nextButton.configuration = config
            }
        }
    }
}

private extension CheckoutView {
    func configureModifierCollectionView() {
        guard !modifierStackView.arrangedSubviews.contains(modifierCollectionView) else { return }

        modifierCollectionViewHeightConstraint = modifierCollectionView.heightAnchor.constraint(equalToConstant: 0)
        modifierCollectionViewHeightConstraint.isActive = true

        let index = min(1, modifierStackView.arrangedSubviews.count)
        modifierStackView.insertArrangedSubview(modifierCollectionView, at: index)
    }
}
