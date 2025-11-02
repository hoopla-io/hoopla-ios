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
    @IBOutlet weak var module1Label: UILabel! {
        didSet {
            module1Label.isHidden = true
        }
    }
    @IBOutlet weak var module2Label: UILabel! {
        didSet {
            module2Label.isHidden = true
        }
    }
    @IBOutlet weak var module3Label: UILabel! {
        didSet {
            module3Label.isHidden = true
        }
    }
    
    //MARK: - Attributes
    var item: Shop? {
        didSet {
            guard let item else { return }
            if let imageUrl = item.pictureUrl {
                imageView.setImage(with: imageUrl, placeholder: .appImage(.placeholder))
            }
            nameLabel.text = item.name
            distanceLabel.text = item.distance?.formatDistance()
            guard let modules = item.modules else { return }
            for i in modules.enumerated() {
                setupModules(index: i.offset)
            }
        }
    }
    
    func setupModules(index: Int) {
        switch index {
        case 0:
            module1Label.isHidden = false
            module1Label.text = item?.modules?.first?.name
            module1Label.backgroundColor = UIColor(hex: "\(item?.modules?.first?.colour ?? "000000")") ?? .appColor(.orange)
        case 1:
            module2Label.isHidden = false
            module2Label.text = item?.modules?[safe: 1]?.name
            module2Label.backgroundColor = UIColor(hex: "\(item?.modules?[safe: 1]?.colour ?? "000000")") ?? .appColor(.orange)
        case 2:
            module3Label.isHidden = false
            module3Label.text = item?.modules?[safe: 2]?.name
            module3Label.backgroundColor = UIColor(hex: "\(item?.modules?[safe: 2]?.colour ?? "000000")") ?? .appColor(.orange)
        default:
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        module1Label.isHidden = true
        module2Label.isHidden = true
        module3Label.isHidden = true
        super.prepareForReuse()
    }

}
