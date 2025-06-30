//
//  OrderHistoryTableViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 12/01/25.
//

import UIKit
import SkeletonView

enum OrderStatus: String {
    case pending
    case created
    case preparing
    case canceled
    case completed
}

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
    @IBOutlet weak var orderStatusLabel: UILabel!
    
    //MARK: - Attributes
    var item: OrderHistory? {
        didSet {
            guard let item else { return }
            titleLabel.text = "#\(item.id ?? 0), \(item.drinkName ?? "")"
            subTitleLabel.text = item.shopName
            timeLabel.text = DateFormatter.string(timestamp: item.purchasedAtUnix, formatter: .fullDate)
            orderStatusLabel.text = item.orderStatus?.localized
            setStatusColor(item.orderStatus)
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
    
    func setStatusColor(_ type: String?) {
        guard let type = type, let colorType = OrderStatus(rawValue: type) else {
            orderStatusLabel.backgroundColor = .appColor(.green)
            return
        }
        switch colorType {
        case .pending, .preparing:
            orderStatusLabel.backgroundColor = .appColor(.orange)
        case .canceled:
            orderStatusLabel.backgroundColor = .appColor(.red)
        case .created:
            orderStatusLabel.backgroundColor = .lightGray
        case .completed:
            orderStatusLabel.backgroundColor = .appColor(.green)
        }
    }
}
