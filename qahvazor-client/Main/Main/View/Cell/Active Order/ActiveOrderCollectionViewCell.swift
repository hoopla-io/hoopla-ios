//
//  ActiveOrderCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 13/07/26.
//

import UIKit

final class ActiveOrderCollectionViewCell: UICollectionViewCell {
    static let preferredHeight: CGFloat = 153

    private enum Constants {
        static let cornerRadius: CGFloat = 20
        static let horizontalInset: CGFloat = 20
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "currentOrder".localized
        label.textColor = .appColor(.white)
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()

    private let statusLabel: UILabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appColor(.white)
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = UIColor.appColor(.white).withAlphaComponent(0.14)
        label.layer.cornerRadius = 12
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        return label
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appColor(.white).withAlphaComponent(0.14)
        return view
    }()

    private let shopImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .appColor(.white)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.cornerCurve = .continuous
        imageView.clipsToBounds = true
        return imageView
    }()

    private let drinkNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appColor(.white)
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let orderDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appColor(.white).withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let arrowContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appColor(.white).cgColor
        view.layer.cornerRadius = 19
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .appColor(.white)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appColor(.white).withAlphaComponent(0.25)
        view.layer.cornerRadius = 4
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let progressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appColor(.white)
        view.layer.cornerRadius = 4
        view.layer.cornerCurve = .continuous
        return view
    }()

    private var progressWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(with item: OrderHistory) {
        drinkNameLabel.text = item.drinkName
        statusLabel.text = item.orderStatus?.localized
        shopImageView.setImage(with: item.shopIconUrl, placeholder: .appImage(.placeholder))

        let detailParts: [String] = [
            item.shopName,
            item.productPrice.map { $0.formattedWithCurrency }
        ].compactMap { value in
            guard let value, !value.isEmpty else { return nil }
            return value
        }
        orderDetailLabel.text = detailParts.joined(separator: " • ")
        setProgress(progress(for: item.orderStatus))

        accessibilityLabel = [
            "currentOrder".localized,
            item.drinkName,
            item.shopName,
            item.orderStatus?.localized
        ].compactMap { $0 }.joined(separator: ", ")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        drinkNameLabel.text = nil
        statusLabel.text = nil
        orderDetailLabel.text = nil
        shopImageView.setImage(with: nil, placeholder: .appImage(.placeholder))
        setProgress(0)
    }
}

private extension ActiveOrderCollectionViewCell {
    func setupUI() {
        contentView.backgroundColor = .appColor(.mainColor)
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(dividerView)
        contentView.addSubview(shopImageView)
        contentView.addSubview(drinkNameLabel)
        contentView.addSubview(orderDetailLabel)
        contentView.addSubview(arrowContainerView)
        contentView.addSubview(progressTrackView)
        arrowContainerView.addSubview(arrowImageView)
        progressTrackView.addSubview(progressView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),

            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),

            dividerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            dividerView.heightAnchor.constraint(equalToConstant: 1),

            shopImageView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 14),
            shopImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            shopImageView.widthAnchor.constraint(equalToConstant: 48),
            shopImageView.heightAnchor.constraint(equalToConstant: 48),

            drinkNameLabel.topAnchor.constraint(equalTo: shopImageView.topAnchor, constant: 2),
            drinkNameLabel.leadingAnchor.constraint(equalTo: shopImageView.trailingAnchor, constant: 14),
            drinkNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowContainerView.leadingAnchor, constant: -12),

            orderDetailLabel.topAnchor.constraint(equalTo: drinkNameLabel.bottomAnchor, constant: 2),
            orderDetailLabel.leadingAnchor.constraint(equalTo: drinkNameLabel.leadingAnchor),
            orderDetailLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowContainerView.leadingAnchor, constant: -12),

            arrowContainerView.centerYAnchor.constraint(equalTo: shopImageView.centerYAnchor),
            arrowContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            arrowContainerView.widthAnchor.constraint(equalToConstant: 38),
            arrowContainerView.heightAnchor.constraint(equalToConstant: 38),

            arrowImageView.centerXAnchor.constraint(equalTo: arrowContainerView.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: arrowContainerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16),

            progressTrackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressTrackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressTrackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
            progressTrackView.heightAnchor.constraint(equalToConstant: 8),

            progressView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor)
        ])

        setProgress(0)
    }

    func setProgress(_ progress: CGFloat) {
        progressWidthConstraint?.isActive = false
        let progress = min(max(progress, 0), 1)
        if progress == 0 {
            progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        } else {
            progressWidthConstraint = progressView.widthAnchor.constraint(
                equalTo: progressTrackView.widthAnchor,
                multiplier: progress
            )
        }
        progressWidthConstraint?.isActive = true
    }

    func progress(for status: String?) -> CGFloat {
        guard let status, let orderStatus = OrderStatus(rawValue: status) else { return 0.1 }
        switch orderStatus {
        case .pending_payment:
            return 0.15
        case .pending, .created:
            return 0.3
        case .paid:
            return 0.45
        case .preparing:
            return 0.72
        case .completed:
            return 1
        case .cancelled, .error, .payment_expired, .payment_failed:
            return 1
        }
    }
}

