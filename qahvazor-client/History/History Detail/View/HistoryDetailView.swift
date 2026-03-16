//
//  HistoryDetailView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//


import UIKit

final class HistoryDetailView: CustomView {
    //MARK: - Outlets
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var drinkTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var drinkLabel: UILabel!
    @IBOutlet weak var drinkPriceLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet var titles: [UILabel]!
    @IBOutlet var prices: [UILabel]!
    @IBOutlet var stackViews: [UIStackView]! {
        didSet {
            stackViews.forEach { $0.isHidden = true }
        }
    }
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var cashbackUsedLabel: UILabel!
    @IBOutlet weak var cashbackEarnedLabel: UILabel!
    
    @IBOutlet weak var getButton: UIButton! {
        didSet {
            if #available(iOS 26.0, *) {
                var config: UIButton.Configuration
                config = .clearGlass()
                config.baseForegroundColor = .main
                config.cornerStyle = .large
                config.imagePadding = 10
                getButton.configuration = config
            }
            getButton.isHidden = true
        }
    }
    @IBOutlet weak var cancelledButton: UIButton! {
        didSet {
            if #available(iOS 26.0, *) {
                var config: UIButton.Configuration
                config = .clearGlass()
                config.baseForegroundColor = .main
                config.cornerStyle = .large
                config.imagePadding = 10
                cancelledButton.configuration = config
            }
            cancelledButton.isHidden = true
        }
    }
    @IBOutlet weak var continuePaymentButton: UIButton! {
        didSet {
            if #available(iOS 26.0, *) {
                var config: UIButton.Configuration
                config = .clearGlass()
                config.baseForegroundColor = .appColor(.orange)
                config.cornerStyle = .large
                config.imagePadding = 10
                continuePaymentButton.configuration = config
            }
            continuePaymentButton.isHidden = true
        }
    }
    @IBOutlet weak var completedButtonInfo: UIButton! {
        didSet {
            completedButtonInfo.isHidden = true
        }
    }
    @IBOutlet weak var cancelledButtonInfo: UIButton! {
        didSet {
            cancelledButtonInfo.isHidden = true
        }
    }
}
