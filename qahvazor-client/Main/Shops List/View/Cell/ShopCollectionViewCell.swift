//
//  ShopCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 07/01/25.
//

import UIKit

class ShopCollectionViewCell: UICollectionViewCell {
    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.skeletonTextNumberOfLines = 1
            titleLabel.lastLineFillPercent = 100
            titleLabel.linesCornerRadius = 5
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonsStackView: UIStackView! {
        didSet {
            buttonsStackView.isHidden = true
        }
    }
    
    //MARK: - Attributes
    weak var viewController: UIViewController?
    var item: Shop? {
        didSet {
            guard let item else { return }
            titleLabel.text = item.name
            
            if let imageUrl = item.pictureUrl {
                imageView.setImage(with: imageUrl)
            }
        }
    }
    //MARK: - Actions
    @IBAction func addressButtonAction(_ sender: Any) {
        guard let vc = viewController as? ShopsListViewController else { return }
        guard let lat = item?.location?.lat, let lng = item?.location?.lng else { return }
        vc.openMaps(latitude: lat, longitude: lng, title: "maps".localized)
    }

    @IBAction func callButtonAction(_ sender: Any) {
        guard let vc = viewController as? ShopsListViewController else { return }
        guard let phoneNumbers = item?.phoneNumbers else { return }
        if phoneNumbers.count == 1 {
            self.callAction(phoneNumber: phoneNumbers.first?.phoneNumber)
        } else {
            vc.showCallPhoneActionSheet(items: phoneNumbers) { phoneNumber in
                self.callAction(phoneNumber: phoneNumber)
            }
        }
    }
    
    func callAction(phoneNumber: String?) {
        guard let phoneNumber else { return }
        if let url = URL(string: "tel://+\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Phone call not supported on this device")
            }
        }
    }
    
    
    //MARK: - Life cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
