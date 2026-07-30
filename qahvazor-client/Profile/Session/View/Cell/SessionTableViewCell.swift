//
//  SessionTableViewCell.swift
//  qahvazor-client
//

import UIKit

final class SessionTableViewCell: UITableViewCell {
    static let reuseIdentifier = String(describing: SessionTableViewCell.self)

    var onLogoutTapped: (() -> Void)?

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appColor(.secondBackground)
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let deviceImageView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        let image = UIImage(systemName: "macbook.and.iphone", withConfiguration: configuration)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()

    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()

    private let activeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.numberOfLines = 1
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.contentHorizontalAlignment = .trailing
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

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
        onLogoutTapped = nil
    }

    func configure(with session: UserDeviceSession, isCurrent: Bool) {
        nameLabel.text = session.deviceName?.nilIfBlank ?? "unknownDevice".localized

        let details = [
            session.platform?.nilIfBlank?.lowercased(),
            session.appVersion?.nilIfBlank.map { "v\($0)" },
            session.ip?.nilIfBlank
        ].compactMap { $0 }
        detailsLabel.text = details.joined(separator: " · ")
        detailsLabel.isHidden = details.isEmpty

        let date = Date(timeIntervalSince1970: TimeInterval(session.lastActiveAt))
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationManager.shared.getLocale())
        formatter.dateFormat = "d MMMM, yyyy HH:mm"
        activeLabel.text = String(format: "sessionActive".localized, formatter.string(from: date))

        actionButton.setTitle(isCurrent ? "currentDevice".localized : "logout".localized, for: .normal)
        actionButton.setTitleColor(
            isCurrent ? UIColor.appColor(.green) : UIColor.appColor(.red),
            for: .normal
        )
        actionButton.isUserInteractionEnabled = !isCurrent
        actionButton.accessibilityHint = isCurrent ? nil : "sessionLogoutHint".localized
    }

    @objc private func logoutTapped() {
        onLogoutTapped?()
    }
}

private extension SessionTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let detailsStack = UIStackView(arrangedSubviews: [nameLabel, detailsLabel, activeLabel])
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        detailsStack.axis = .vertical
        detailsStack.spacing = 3

        contentView.addSubview(cardView)
        cardView.addSubview(deviceImageView)
        cardView.addSubview(detailsStack)
        cardView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            deviceImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            deviceImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            deviceImageView.widthAnchor.constraint(equalToConstant: 40),
            deviceImageView.heightAnchor.constraint(equalToConstant: 40),

            detailsStack.leadingAnchor.constraint(equalTo: deviceImageView.trailingAnchor, constant: 18),
            detailsStack.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: 10),
            detailsStack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -10),
            detailsStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: detailsStack.trailingAnchor, constant: 10),
            actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            actionButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            actionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
}
