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
            tableView.register(OrderHistoryTableViewCell.self, forCellReuseIdentifier: OrderHistoryTableViewCell.defaultReuseIdentifier)
            tableView.separatorStyle = .none
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 184
            tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 24, right: 0)
            tableView.backgroundColor = .appColor(.mainBackground)
        }
    }
    // MARK: - Life cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
