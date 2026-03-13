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
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.lastLineFillPercent = 100
            titleLabel.linesCornerRadius = 5
        }
    }
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            priceLabel.lastLineFillPercent = 100
            priceLabel.linesCornerRadius = 5
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    
    //MARK: - Attributes
    weak var viewController: UIViewController?
    var item: OrderHistory? {
        didSet {
            guard let item else { return }
            titleLabel.text = "\(item.shopName ?? ""), \(item.drinkName ?? "")"
            priceLabel.text = "- \(item.productPrice?.formattedWithCurrency ?? "0")"
            dateLabel.text = DateFormatter.string(timestamp: item.purchasedAtUnix, formatter: .fullDate)
            orderStatusLabel.text = item.orderStatus?.localized
            setStatusColor(item.orderStatus)
            if let icon = item.shopIconUrl {
                imgView.setImage(with: icon)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    func setStatusColor(_ type: String?) {
        guard let type = type, let colorType = OrderStatus(rawValue: type) else {
            orderStatusLabel.textColor = .appColor(.green)
            return
        }
        switch colorType {
        case .pending, .preparing, .pending_payment:
            orderStatusLabel.textColor = .appColor(.orange)
        case .cancelled:
            orderStatusLabel.textColor = .appColor(.red)
        case .created:
            orderStatusLabel.textColor = .gray
        case .completed:
            let cashback = item?.cashbackEarned ?? 0
            orderStatusLabel.textColor = cashback == 0 ? .gray : .appColor(.green)
            orderStatusLabel.text = "+ \(cashback.formattedWithCurrency)"
        default:
            orderStatusLabel.textColor = .gray
        }
    }
}
