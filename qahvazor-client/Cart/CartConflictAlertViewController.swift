//
//  CartConflictAlertViewController.swift
//  qahvazor-client
//
//  Created by Husan on 22/08/26.
//

import UIKit

final class CartConflictAlertViewController: UIViewController {
    var onClearAndAdd: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = UIColor.black.withAlphaComponent(0.72)

        let card = UIStackView()
        card.axis = .vertical
        card.spacing = 12
        card.isLayoutMarginsRelativeArrangement = true
        card.layoutMargins = UIEdgeInsets(top: 28, left: 24, bottom: 24, right: 24)
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 18
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "cartConflictTitle".localized
        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = "cartConflictMessage".localized
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("cartClearAndAdd".localized, for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.backgroundColor = .systemRed
        clearButton.layer.cornerRadius = 12
        clearButton.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let backButton = UIButton(type: .system)
        backButton.setTitle("cartGoBack".localized, for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        backButton.setTitleColor(.label, for: .normal)
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.separator.cgColor
        backButton.layer.cornerRadius = 12
        backButton.heightAnchor.constraint(equalToConstant: 52).isActive = true

        [titleLabel, messageLabel, clearButton, backButton].forEach { card.addArrangedSubview($0) }
        card.setCustomSpacing(20, after: messageLabel)
        view.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    @objc private func clearTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onClearAndAdd?()
        }
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }
}
