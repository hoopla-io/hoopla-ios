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
    @IBOutlet weak var reloadButton: UIButton! {
        didSet {
            reloadButton.isHidden = true
        }
    }
    @IBOutlet weak var timerLabel: UILabel!
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
