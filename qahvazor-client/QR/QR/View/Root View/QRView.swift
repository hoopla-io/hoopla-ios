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
    @IBOutlet weak var authContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var limitButton: UIButton!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var usedLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: OrderHistoryTableViewCell.defaultReuseIdentifier, bundle: nil), forCellReuseIdentifier: OrderHistoryTableViewCell.defaultReuseIdentifier)
        }
    }
    // MARK: - Life cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.showAnimatedSkeleton()
    }
}
