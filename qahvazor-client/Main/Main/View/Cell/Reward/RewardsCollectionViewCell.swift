//
//  RewardsCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 02/11/25.
//

import UIKit

class RewardsCollectionViewCell: UICollectionViewCell {
    //MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cupLabel: UILabel!
    
    var item: Loyalty? {
        didSet {
            cupLabel.text = "\("Cup".localized) \(item?.drinkIndex ?? 0)"
            
            if item?.isFree ?? false {
                cupLabel.text = "free".localized
                containerView.backgroundColor = .appColor(.green)
            } else {
                containerView.backgroundColor = item?.isFilled ?? false ? .appColor(.mainColor) : .systemGray3
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
    }

}
