//
//  PromocodeView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 08/07/26.
//

import UIKit

final class PromocodeView: CustomView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "promocode".localized
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.textColor = .label
        return label
    }()

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemBackground
        textField.placeholder = "enterPromocode".localized
        textField.font = .systemFont(ofSize: 18)
        textField.textColor = .label
        textField.tintColor = .appColor(.mainColor)
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 12
        textField.layer.cornerCurve = .continuous
        textField.setLeftPaddingPoints(20)
        textField.setRightPaddingPoints(20)
        return textField
    }()

    let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("apply".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        button.isEnabled = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setApplyButtonEnabled(_ isEnabled: Bool) {
        applyButton.isEnabled = isEnabled
        applyButton.backgroundColor = isEnabled ? .appColor(.mainColor) : .appColor(.mainColor).withAlphaComponent(0.28)
        applyButton.setTitleColor(.appColor(.white), for: .normal)
        applyButton.setTitleColor(.appColor(.white).withAlphaComponent(0.75), for: .disabled)
    }
}

private extension PromocodeView {
    func setupUI() {
        backgroundColor = .appColor(.mainBackground)
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(applyButton)

        setApplyButtonEnabled(false)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 62),

            applyButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 34),
            applyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            applyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
