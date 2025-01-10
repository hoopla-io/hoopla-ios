//
//  QRView.swift
//  qahvazor-client
//
//  Created by Alphazet on 10/01/25.
//

import UIKit
import SkeletonView

final class QRView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var reloadButton: UIButton! {
        didSet {
//            reloadButton.isHidden = true
        }
    }
    @IBOutlet weak var timerLabel: UILabel! {
        didSet {
            timerLabel.isHidden = true
        }
    }
    
    // MARK: - Life cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.showAnimatedSkeleton()
    }
}
