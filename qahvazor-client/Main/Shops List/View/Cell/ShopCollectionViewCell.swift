//
//  ShopCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 07/01/25.
//

import UIKit

class ShopCollectionViewCell: CustomCollectionViewCell {
    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.skeletonTextNumberOfLines = 1
            titleLabel.lastLineFillPercent = 100
            titleLabel.linesCornerRadius = 5
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    //MARK: - Attributes
    weak var viewController: UIViewController?
    var item: Shop? {
        didSet {
            guard let item else { return }
            titleLabel.text = item.name
            
            if let imageUrl = item.pictureUrl {
                imageView.setImage(with: imageUrl, placeholder: .appImage(.placeholder))
            }
        }
    }
    
    //MARK: - Life cycles
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
