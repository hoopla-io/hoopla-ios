//
//  OrderHistoryTableViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 12/01/25.
//

import UIKit
import SkeletonView

final class OrderHistoryTableViewCell: UITableViewCell {
    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let cardRadius: CGFloat = 28
        static let previewWidth: CGFloat = 122
    }

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Layout.cardRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let drinkPreviewView = HistoryDrinkPreviewView()

    private let drinksLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.isSkeletonable = true
        label.linesCornerRadius = 5
        return label
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.separator.withAlphaComponent(0.45)
        return view
    }()

    private let shopNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isSkeletonable = true
        label.linesCornerRadius = 5
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.isSkeletonable = true
        label.linesCornerRadius = 5
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        label.numberOfLines = 1
        label.isSkeletonable = true
        label.linesCornerRadius = 5
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    var item: OrderHistory? {
        didSet {
            guard let item else { return }
            configure(with: item)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        shopNameLabel.text = nil
        dateLabel.text = nil
        priceLabel.text = nil
        statusLabel.text = nil
        drinksLabel.attributedText = nil
        drinkPreviewView.configure(imageURLs: [])
    }
}

private extension OrderHistoryTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        isSkeletonable = true
        contentView.isSkeletonable = true
        cardView.isSkeletonable = true

        let productRow = UIView()
        productRow.translatesAutoresizingMaskIntoConstraints = false
        productRow.addSubview(drinkPreviewView)
        productRow.addSubview(drinksLabel)

        let shopStack = UIStackView(arrangedSubviews: [shopNameLabel, dateLabel])
        shopStack.axis = .vertical
        shopStack.alignment = .leading
        shopStack.spacing = 3

        let amountStack = UIStackView(arrangedSubviews: [priceLabel, statusLabel])
        amountStack.axis = .vertical
        amountStack.alignment = .trailing
        amountStack.spacing = 3

        let footerStack = UIStackView(arrangedSubviews: [shopStack, amountStack])
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        footerStack.axis = .horizontal
        footerStack.alignment = .center
        footerStack.spacing = 12
        shopStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        amountStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(cardView)
        cardView.addSubview(productRow)
        cardView.addSubview(dividerView)
        cardView.addSubview(footerStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            productRow.topAnchor.constraint(equalTo: cardView.topAnchor),
            productRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            productRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            productRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 108),

            drinkPreviewView.leadingAnchor.constraint(equalTo: productRow.leadingAnchor, constant: 0),
            drinkPreviewView.centerYAnchor.constraint(equalTo: productRow.centerYAnchor),
            drinkPreviewView.widthAnchor.constraint(equalToConstant: Layout.previewWidth),
            drinkPreviewView.heightAnchor.constraint(equalToConstant: 78),

            drinksLabel.leadingAnchor.constraint(equalTo: drinkPreviewView.trailingAnchor, constant: 8),
            drinksLabel.trailingAnchor.constraint(equalTo: productRow.trailingAnchor, constant: -16),
            drinksLabel.centerYAnchor.constraint(equalTo: productRow.centerYAnchor),

            dividerView.topAnchor.constraint(equalTo: productRow.bottomAnchor),
            dividerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            footerStack.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 13),
            footerStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            footerStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            footerStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -13)
        ])
    }

    func configure(with item: OrderHistory) {
        let groups = groupedDrinks(for: item)
        shopNameLabel.text = item.shopName ?? item.partnerName
        dateLabel.text = formattedPurchaseDate(for: item)
        priceLabel.text = totalPrice(for: item).formattedWithCurrency
        drinksLabel.attributedText = drinksDescription(groups: groups)

        let imageURLs = groups.map(\.imageURL)
        drinkPreviewView.configure(imageURLs: imageURLs, itemCount: max(groups.reduce(0) { $0 + $1.quantity }, 1))

        configureStatus(for: item)
        accessibilityLabel = [
            shopNameLabel.text,
            drinksLabel.text,
            dateLabel.text,
            priceLabel.text,
            statusLabel.text
        ].compactMap { $0 }.joined(separator: ", ")
    }

    struct DrinkGroup {
        let name: String
        let imageURL: String?
        var quantity: Int
        var totalPrice: Double
    }

    func groupedDrinks(for item: OrderHistory) -> [DrinkGroup] {
        guard let drinks = item.drinks, !drinks.isEmpty else {
            return [DrinkGroup(
                name: item.drinkName ?? "drink".localized,
                imageURL: item.drinkImageUrl,
                quantity: 1,
                totalPrice: item.productPrice ?? 0
            )]
        }

        var groups: [DrinkGroup] = []
        drinks.forEach { drink in
            let name = drink.drinkName?.trimmingCharacters(in: .whitespacesAndNewlines)
            let displayName = (name?.isEmpty == false ? name : nil) ?? "drink".localized
            if let index = groups.firstIndex(where: { $0.name.caseInsensitiveCompare(displayName) == .orderedSame }) {
                groups[index].quantity += 1
                groups[index].totalPrice += drink.drinkPrice ?? 0
            } else {
                groups.append(DrinkGroup(
                    name: displayName,
                    imageURL: drink.drinkImageUrl,
                    quantity: 1,
                    totalPrice: drink.drinkPrice ?? 0
                ))
            }
        }
        return groups
    }

    func drinksDescription(groups: [DrinkGroup]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let visibleGroups = groups.prefix(3)
        for (index, group) in visibleGroups.enumerated() {
            if index > 0 { result.append(NSAttributedString(string: "\n")) }
            result.append(NSAttributedString(
                string: group.name,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                    .foregroundColor: UIColor.label
                ]
            ))
            if group.quantity > 1 {
                result.append(NSAttributedString(
                    string: " x\(group.quantity)",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                        .foregroundColor: UIColor.appColor(.mainColor)
                    ]
                ))
            }
        }
        if groups.count > visibleGroups.count {
            result.append(NSAttributedString(
                string: "  +\(groups.count - visibleGroups.count)",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            ))
        }
        return result
    }

    func totalPrice(for item: OrderHistory) -> Double {
        guard let drinks = item.drinks, !drinks.isEmpty else {
            return item.productPrice ?? 0
        }
        let drinksTotal = drinks.reduce(0) { $0 + ($1.drinkPrice ?? 0) }
        return drinksTotal > 0 ? drinksTotal : (item.productPrice ?? 0)
    }

    func configureStatus(for item: OrderHistory) {
        let status = normalizedStatus(item.orderStatus ?? item.drinks?.compactMap(\.status).first ?? "")
        let cashback = item.cashbackEarned ?? 0

        switch status {
        case .cancelled:
            statusLabel.text = "historyCancelled".localized
            statusLabel.textColor = .appColor(.red)
        case .completed where cashback > 0:
            statusLabel.text = "+ \(cashback.formattedWithSeparator) UZS"
            statusLabel.textColor = .appColor(.green)
        case .completed:
            statusLabel.text = "completed".localized
            statusLabel.textColor = .appColor(.green)
        case .other(let value):
            statusLabel.text = value.isEmpty ? nil : value.localized
            statusLabel.textColor = .appColor(.orange)
        }
    }

    enum DisplayStatus {
        case completed
        case cancelled
        case other(String)
    }

    func normalizedStatus(_ status: String) -> DisplayStatus {
        switch status.lowercased() {
        case "ordered", OrderStatus.completed.rawValue:
            return .completed
        case "canceled", OrderStatus.cancelled.rawValue:
            return .cancelled
        default:
            return .other(status.lowercased())
        }
    }

    func formattedPurchaseDate(for item: OrderHistory) -> String {
        let date: Date?
        if let timestamp = item.purchasedAtUnix {
            date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else if let purchasedAt = item.purchasedAt {
            let fractionalFormatter = ISO8601DateFormatter()
            fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            date = fractionalFormatter.date(from: purchasedAt) ?? ISO8601DateFormatter().date(from: purchasedAt)
        } else {
            date = nil
        }

        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationManager.shared.getLocale())
        formatter.dateFormat = "dd.MM.yyyy   HH:mm"
        return formatter.string(from: date)
    }
}

private final class HistoryDrinkPreviewView: UIView {
    private var imageViews: [UIImageView] = []
    private let countLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .appColor(.mainColor)
        label.textColor = .white
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isSkeletonable = true
        addSubview(countLabel)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        isSkeletonable = true
        addSubview(countLabel)
    }

    func configure(imageURLs: [String?], itemCount: Int = 0) {
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()

        let urls: [String?] = imageURLs.isEmpty ? [nil] : Array(imageURLs.prefix(3))
        urls.forEach { url in
            let imageView = UIImageView()
            imageView.backgroundColor = .systemBackground
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12
            imageView.layer.cornerCurve = .continuous
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.systemGray4.cgColor
            imageView.setImage(with: url, placeholder: .appImage(.drinkPlaceholder))
            insertSubview(imageView, belowSubview: countLabel)
            imageViews.append(imageView)
        }

        countLabel.text = "\(itemCount)"
        countLabel.isHidden = itemCount <= 1
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = min(bounds.height, 72)
        let count = imageViews.count
        let overlap: CGFloat = count > 1 ? 24 : 0
        let totalWidth = imageSize + CGFloat(max(count - 1, 0)) * overlap
        let startX = max((bounds.width - totalWidth) / 2, 0)

        for (index, imageView) in imageViews.enumerated() {
            imageView.frame = CGRect(
                x: startX + CGFloat(index) * overlap,
                y: (bounds.height - imageSize) / 2,
                width: imageSize,
                height: imageSize
            )
        }

        let badgeSize: CGFloat = 22
        let lastFrame = imageViews.last?.frame ?? .zero
        countLabel.frame = CGRect(
            x: min(lastFrame.maxX - badgeSize / 2, bounds.width - badgeSize),
            y: max(lastFrame.minY - 7, 0),
            width: badgeSize,
            height: badgeSize
        )
        countLabel.layer.cornerRadius = badgeSize / 2
    }
}
