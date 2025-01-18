//
//  OrderHistoryTableViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 12/01/25.
//

import UIKit
import SkeletonView

class OrderHistoryTableViewCell: UITableViewCell {
    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.lastLineFillPercent = 100
            titleLabel.linesCornerRadius = 5
        }
    }
    @IBOutlet weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.lastLineFillPercent = 100
            subTitleLabel.linesCornerRadius = 5
        }
    }
    @IBOutlet weak var timeLabel: UILabel!
    //MARK: - Attributes
    var item: OrderHistory? {
        didSet {
            guard let item else { return }
            titleLabel.text = item.partnerName
            subTitleLabel.text = item.shopName
            timeLabel.text = DateFormatter.string(timestamp: item.purchasedAtUnix, formatter: .fullDate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
}
