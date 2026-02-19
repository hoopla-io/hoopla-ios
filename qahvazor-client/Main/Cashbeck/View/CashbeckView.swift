//
//  CashbeckView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//

import UIKit

final class CashbeckView: CustomView {
    //MARK: Outlets
    @IBOutlet weak var availablePriceLabel: UILabel!
    @IBOutlet weak var usedPriceLabel: UILabel!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
}
