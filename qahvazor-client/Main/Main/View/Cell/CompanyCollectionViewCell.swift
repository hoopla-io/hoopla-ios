//
//  CompanyCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit

class CompanyCollectionViewCell: CustomCollectionViewCell {
    //MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK: - Attributes
    var item: Company? {
        didSet {
            guard let item else { return }
            if let imageUrl = item.imageUrl {
                imageView.setImage(with: imageUrl)
            }
            nameLabel.text = item.name
            descriptionLabel.text = item.description
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
