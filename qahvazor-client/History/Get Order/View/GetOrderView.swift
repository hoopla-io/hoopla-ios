//
//  GetOrderView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 14/05/26.
//

import UIKit

final class GetOrderView: CustomView {
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "pickupQRTitle".localized
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "pickupQRSubtitle".localized
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let codeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }()

    private let qrContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appColor(.white)
        view.layer.cornerRadius = 28
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()

    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appColor(.mainColor)
        button.setTitle("close".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.appColor(.white), for: .normal)
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Configure
    func configure(order: GetOrder?) {
        configure(token: order?.token, code: order?.orderId.map { String($0) }, expiresAt: order?.expiresAt)
    }

    func configure(token: String?, code: String?, expiresAt: Int?) {
        let qrValue = token
        guard let qrValue, !qrValue.isEmpty else {
            qrImageView.image = nil
            codeLabel.text = nil
            return
        }

        qrImageView.image = UIImage.generateQRCode(key: qrValue)
        codeLabel.text = code
    }

    // MARK: - Setup
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(codeLabel)
        addSubview(qrContainerView)
        addSubview(doneButton)

        qrContainerView.addSubview(qrImageView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 42),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),

            codeLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            codeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            codeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            qrContainerView.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 20),
            qrContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            qrContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.72),
            qrContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 350),
            qrContainerView.heightAnchor.constraint(equalTo: qrContainerView.widthAnchor),

            qrImageView.topAnchor.constraint(equalTo: qrContainerView.topAnchor, constant: 30),
            qrImageView.leadingAnchor.constraint(equalTo: qrContainerView.leadingAnchor, constant: 30),
            qrImageView.trailingAnchor.constraint(equalTo: qrContainerView.trailingAnchor, constant: -30),
            qrImageView.bottomAnchor.constraint(equalTo: qrContainerView.bottomAnchor, constant: -30),

            doneButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            doneButton.heightAnchor.constraint(equalToConstant: 51)
        ])
    }

}
