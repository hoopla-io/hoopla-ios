//
//  CoffeeCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 06/01/25.
//

import UIKit

class CoffeeCollectionViewCell: CustomCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 26
        }
    }
    @IBOutlet weak var orderView: UIView! {
        didSet {
            orderView.layer.cornerRadius = 20
            orderView.layer.masksToBounds = false
            orderView.layer.shadowColor    = UIColor.black.cgColor
            orderView.layer.shadowOpacity  = 0.2
            orderView.layer.shadowOffset   = CGSize(width: 6, height: 0)
            orderView.layer.shadowRadius   = 4

            orderView.layer.shadowPath = UIBezierPath(
              roundedRect: orderView.bounds,
              cornerRadius: 20
            ).cgPath
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
