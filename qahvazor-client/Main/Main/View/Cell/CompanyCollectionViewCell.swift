//
//  CompanyCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit

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
    
    //MARK: - Attributes
    var item: Company? {
        didSet {
            guard let item else { return }
            if let imageUrl = item.logoUrl {
                imageView.setImage(with: imageUrl)
            }
            nameLabel.text = item.name
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
