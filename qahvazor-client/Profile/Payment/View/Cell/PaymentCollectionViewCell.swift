//
//  PaymentCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 05/03/25.
//

import UIKit

class PaymentCollectionViewCell: CustomCollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerCurve = .continuous
        layer.cornerRadius = 16
    }
    
}
