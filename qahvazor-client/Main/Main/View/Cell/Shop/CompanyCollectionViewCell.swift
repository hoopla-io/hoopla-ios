//
//  CompanyCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit
import ColorKit

class CompanyCollectionViewCell: CustomCollectionViewCell {
    //MARK: - Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.dropShadow()
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.lastLineFillPercent = 100
            nameLabel.linesCornerRadius = 5
        }
    }
    @IBOutlet weak var distanceLabel: UILabel!
    
    //MARK: - Attributes
    var item: Shop? {
        didSet {
            guard let item else { return }
            if let imageUrl = item.pictureUrl {
                imageView.setImage(with: imageUrl, placeholder: .appImage(.placeholder))
            }
            nameLabel.text = item.name
            distanceLabel.text = item.distance?.formatDistance()
            distanceLabel.isHidden = item.distance == 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
