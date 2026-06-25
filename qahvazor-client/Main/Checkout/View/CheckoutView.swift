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
    
    @IBOutlet weak var sizeTitleLabel: UILabel!
    @IBOutlet weak var sizePriceLabel: UILabel!
    @IBOutlet weak var sizeStackView: UIStackView! {
        didSet {
            sizeStackView.isHidden = true
        }
    }
    
    @IBOutlet weak var sugarTitleLabel: UILabel!
    @IBOutlet weak var sugarPriceLabel: UILabel!
    @IBOutlet weak var sugarStackView: UIStackView! {
        didSet {
            sugarStackView.isHidden = true
        }
    }
    
    @IBOutlet weak var milkTitleLabel: UILabel!
    @IBOutlet weak var milkPriceLabel: UILabel!
    @IBOutlet weak var milkStackView: UIStackView! {
        didSet {
            milkStackView.isHidden = true
        }
    }
    
    @IBOutlet weak var syropTitleLabel: UILabel!
    @IBOutlet weak var syropPriceLabel: UILabel!
    @IBOutlet weak var syropStackView: UIStackView! {
        didSet {
            syropStackView.isHidden = true
        }
    }
    
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
