//
//  LanguageCollectionViewCell.swift
//  itv-new
//
//  Created by Jakhongir Nematov on 07/02/22.
//

import UIKit

class LanguageCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Attributes
    var isTicked: Bool = false {
        didSet {
            imageView.tintColor = isTicked ? UIColor.appColor(.mainColor) : UIColor.darkGray
            imageView.image = isTicked ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
            label.textColor = isTicked ? UIColor.appColor(.mainColor) : UIColor.label
        }
    }
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12.0
        layer.cornerCurve = .continuous
    }

}
