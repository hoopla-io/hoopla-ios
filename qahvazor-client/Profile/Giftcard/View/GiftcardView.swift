//
//  GiftcardView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 11/07/26.
//

import UIKit

final class GiftcardView: CustomView {
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .secondarySystemBackground
        textField.placeholder = "enterGiftcardCode".localized
        textField.font = .systemFont(ofSize: 18)
        textField.textColor = .label
        textField.tintColor = .appColor(.mainColor)
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 14
        textField.layer.cornerCurve = .continuous
        textField.setLeftPaddingPoints(20)
        textField.setRightPaddingPoints(20)
        return textField
    }()

    let activateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("activate".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.isEnabled = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "giftCard".localized
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setActivateButtonEnabled(_ isEnabled: Bool) {
        activateButton.isEnabled = isEnabled
        activateButton.backgroundColor = isEnabled
            ? .appColor(.mainColor)
            : .appColor(.mainColor).withAlphaComponent(0.28)
        activateButton.setTitleColor(.appColor(.white), for: .normal)
        activateButton.setTitleColor(.appColor(.white).withAlphaComponent(0.75), for: .disabled)
    }
}

private extension GiftcardView {
    func setupUI() {
        backgroundColor = .appColor(.mainBackground)

        addSubview(titleLabel)
        addSubview(textField)
        addSubview(activateButton)

        setActivateButtonEnabled(false)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            textField.heightAnchor.constraint(equalToConstant: 62),

            activateButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 34),
            activateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            activateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            activateButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}
