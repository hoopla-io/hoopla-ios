//
//  FilterGenresCollectionViewCell.swift
//  itv-new
//
//  Created Admin NBU on 03/12/21.

import UIKit

class FilterGenresCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.setImage(UIImage(systemName: "circle") ?? UIImage(), animated: false)
        }
    }
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.setImage((isSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")) ?? UIImage(), animated: true)
        }
    }
}
