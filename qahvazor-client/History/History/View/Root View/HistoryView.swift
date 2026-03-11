//
//  HistoryView.swift
//  qahvazor-client
//
//  Created by Alphazet on 10/01/25.
//

import UIKit
import SkeletonView

final class HistoryView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var authContainerView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: OrderHistoryTableViewCell.defaultReuseIdentifier, bundle: nil), forCellReuseIdentifier: OrderHistoryTableViewCell.defaultReuseIdentifier)
        }
    }
    // MARK: - Life cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
