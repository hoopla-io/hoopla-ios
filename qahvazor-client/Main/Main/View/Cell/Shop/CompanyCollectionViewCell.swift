//
//  CompanyCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit
import SkeletonView

final class CompanyCollectionViewCell: CustomCollectionViewCell {
    private enum Constants {
        static let contentInset: CGFloat = 1
        static let imageCornerRadius: CGFloat = 20
        static let stackSpacing: CGFloat = 10
        static let badgeHeight: CGFloat = 28
        static let badgeHorizontalInset: CGFloat = 12
        static let badgeTopInset: CGFloat = 10
    }

    // MARK: - UI Elements
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isSkeletonable = true
        view.dropShadow()
        return view
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.layer.cornerCurve = .continuous
        imageView.isSkeletonable = true
        imageView.skeletonCornerRadius = Float(Constants.imageCornerRadius)
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = .boldSystemFont(ofSize: 24)
        label.lineBreakMode = .byTruncatingTail
        label.isSkeletonable = true
        label.skeletonCornerRadius = 5
        label.lastLineFillPercent = 100
        label.linesCornerRadius = 5
        label.setContentHuggingPriority(.init(252), for: .vertical)
        label.setContentCompressionResistancePriority(.init(751), for: .vertical)
        return label
    }()

    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let distanceBadgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.88)
        view.layer.cornerRadius = Constants.badgeHeight / 2
        view.layer.cornerCurve = .continuous
        view.isHidden = true
        return view
    }()

    private let locationImageView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let imageView = UIImageView(
            image: UIImage(systemName: "mappin", withConfiguration: configuration)
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appColor(.mainColor)
        return imageView
    }()

    private let statusBadgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.78)
        view.layer.cornerRadius = Constants.badgeHeight / 2
        view.layer.cornerCurve = .continuous
        view.isHidden = true
        return view
    }()

    private let statusDotView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        return label
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        stackView.isSkeletonable = true
        return stackView
    }()

    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.isSkeletonable = true
        return stackView
    }()
    
    // MARK: - Attributes
    var item: Shop? {
        didSet {
            guard let item else { return }
            imageView.setImage(with: item.pictureUrl, placeholder: .appImage(.placeholder))
            nameLabel.text = item.name
            configureDistance(item.distance)
            configureStatus(isOpen: item.open)
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
        imageView.setImage(with: nil, placeholder: .appImage(.placeholder))
        nameLabel.text = " "
        distanceLabel.text = " "
        distanceBadgeView.isHidden = true
        statusBadgeView.isHidden = true
    }
}

private extension CompanyCollectionViewCell {
    func setupUI() {
        isSkeletonable = true
        clipsToBounds = true
        contentView.clipsToBounds = true

        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(containerView)
        contentStackView.addArrangedSubview(detailsStackView)
        containerView.addSubview(imageView)
        containerView.addSubview(distanceBadgeView)
        containerView.addSubview(statusBadgeView)
        distanceBadgeView.addSubview(locationImageView)
        distanceBadgeView.addSubview(distanceLabel)
        statusBadgeView.addSubview(statusDotView)
        statusBadgeView.addSubview(statusLabel)
        detailsStackView.addArrangedSubview(nameLabel)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.contentInset
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.contentInset
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.contentInset
            ),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 2),

            distanceBadgeView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.badgeTopInset
            ),
            distanceBadgeView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.badgeHorizontalInset
            ),
            distanceBadgeView.heightAnchor.constraint(equalToConstant: Constants.badgeHeight),

            locationImageView.leadingAnchor.constraint(
                equalTo: distanceBadgeView.leadingAnchor,
                constant: 10
            ),
            locationImageView.centerYAnchor.constraint(equalTo: distanceBadgeView.centerYAnchor),
            locationImageView.widthAnchor.constraint(equalToConstant: 12),
            locationImageView.heightAnchor.constraint(equalToConstant: 14),

            distanceLabel.leadingAnchor.constraint(
                equalTo: locationImageView.trailingAnchor,
                constant: 4
            ),
            distanceLabel.trailingAnchor.constraint(
                equalTo: distanceBadgeView.trailingAnchor,
                constant: -10
            ),
            distanceLabel.centerYAnchor.constraint(equalTo: distanceBadgeView.centerYAnchor),

            statusBadgeView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.badgeTopInset
            ),
            statusBadgeView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.badgeHorizontalInset
            ),
            statusBadgeView.heightAnchor.constraint(equalToConstant: Constants.badgeHeight),

            statusDotView.leadingAnchor.constraint(
                equalTo: statusBadgeView.leadingAnchor,
                constant: 11
            ),
            statusDotView.centerYAnchor.constraint(equalTo: statusBadgeView.centerYAnchor),
            statusDotView.widthAnchor.constraint(equalToConstant: 8),
            statusDotView.heightAnchor.constraint(equalToConstant: 8),

            statusLabel.leadingAnchor.constraint(equalTo: statusDotView.trailingAnchor, constant: 5),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadgeView.trailingAnchor, constant: -11),
            statusLabel.centerYAnchor.constraint(equalTo: statusBadgeView.centerYAnchor)
        ])
    }

    func configureDistance(_ distance: Double?) {
        guard let distance, distance > 0 else {
            distanceBadgeView.isHidden = true
            return
        }

        distanceLabel.text = distance.formatDistance()
        distanceBadgeView.isHidden = false
    }

    func configureStatus(isOpen: Bool?) {
        guard let isOpen else {
            statusBadgeView.isHidden = true
            return
        }

        let color: UIColor = isOpen ? .appColor(.green) : .appColor(.red)
        statusDotView.backgroundColor = color
        statusLabel.textColor = color
        statusLabel.text = (isOpen ? "shopOpen" : "shopClosed").localized.uppercased()
        statusBadgeView.isHidden = false
    }
}
