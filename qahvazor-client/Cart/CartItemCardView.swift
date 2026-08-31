//
//  CartItemCardView.swift
//  qahvazor-client
//
//  Created by Husan on 22/08/26.
//

import UIKit

final class CartItemCardView: UIView {
    var onDecrease: (() -> Void)?
    var onIncrease: (() -> Void)?
    var onRemove: (() -> Void)?

    private let drinkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let modifierStackView = UIStackView()
    private let lineTotalLabel = UILabel()
    private let decreaseButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let increaseButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let controls = UIStackView()
    private var quantity = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(with item: CartItem) {
        quantity = max(item.quantity ?? 1, 1)
        quantityLabel.text = String(quantity)
        titleLabel.text = item.name
        lineTotalLabel.text = (item.lineTotal ?? 0).formattedWithCurrency

        drinkImageView.setImage(
            with: item.displayImageUrl,
            placeholder: UIImage(named: "cup") ?? UIImage(systemName: "cup.and.saucer") ?? UIImage()
        )

        modifierStackView.arrangedSubviews.forEach {
            modifierStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let modifiers = item.modifiers ?? []
        if modifiers.isEmpty {
            let eachLabel = UILabel()
            eachLabel.text = (item.unitPrice ?? 0).formattedWithCurrency + " " + "cartEach".localized
            eachLabel.font = .systemFont(ofSize: 15)
            eachLabel.textColor = .secondaryLabel
            modifierStackView.addArrangedSubview(eachLabel)
        } else {
            modifiers.forEach { modifierStackView.addArrangedSubview(makeModifierRow($0)) }
        }
    }

    func setLoading(_ loading: Bool) {
        decreaseButton.isEnabled = !loading
        increaseButton.isEnabled = !loading
        controls.alpha = loading ? 0.35 : 1
        activityIndicator.isHidden = !loading
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

private extension CartItemCardView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous

        drinkImageView.contentMode = .scaleAspectFit
        drinkImageView.clipsToBounds = true
        drinkImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        drinkImageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        drinkImageView.heightAnchor.constraint(equalToConstant: 88).isActive = true

        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 3

        modifierStackView.axis = .vertical
        modifierStackView.spacing = 5

        lineTotalLabel.font = .systemFont(ofSize: 18, weight: .bold)
        lineTotalLabel.textColor = .label
        lineTotalLabel.adjustsFontSizeToFitWidth = true
        lineTotalLabel.minimumScaleFactor = 0.75
        lineTotalLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        configureQuantityButton(decreaseButton, systemName: "minus")
        configureQuantityButton(increaseButton, systemName: "plus")
        quantityLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        quantityLabel.textColor = .label
        quantityLabel.textAlignment = .center
        quantityLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true

        controls.axis = .horizontal
        controls.alignment = .center
        controls.spacing = 3
        controls.isLayoutMarginsRelativeArrangement = true
        controls.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        controls.backgroundColor = .secondarySystemBackground
        controls.layer.cornerRadius = 22
        controls.layer.cornerCurve = .continuous
        controls.addArrangedSubview(decreaseButton)
        controls.addArrangedSubview(quantityLabel)
        controls.addArrangedSubview(increaseButton)
        controls.widthAnchor.constraint(equalToConstant: 116).isActive = true
        controls.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let bottomRow = UIStackView(arrangedSubviews: [lineTotalLabel, controls])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 8

        let details = UIStackView(arrangedSubviews: [titleLabel, modifierStackView, bottomRow])
        details.axis = .vertical
        details.spacing = 9

        let mainStack = UIStackView(arrangedSubviews: [drinkImageView, details])
        mainStack.axis = .horizontal
        mainStack.alignment = .top
        mainStack.spacing = 14
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = true
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            activityIndicator.centerXAnchor.constraint(equalTo: controls.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: controls.centerYAnchor)
        ])

        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
    }

    func configureQuantityButton(_ button: UIButton, systemName: String) {
        button.backgroundColor = .systemBackground
        button.tintColor = .label
        button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        button.layer.cornerRadius = 18
        button.layer.cornerCurve = .continuous
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

    func makeModifierRow(_ modifier: CartItemModifier) -> UIStackView {
        let nameLabel = UILabel()
        nameLabel.text = modifier.name
        nameLabel.font = .systemFont(ofSize: 15)
        nameLabel.textColor = .secondaryLabel
        nameLabel.numberOfLines = 0

        let priceLabel = UILabel()
        let price = max(modifier.price ?? 0, 0)
        priceLabel.text = price > 0 ? "+\(price.formattedWithCurrency)" : nil
        priceLabel.font = .systemFont(ofSize: 15)
        priceLabel.textColor = .secondaryLabel
        priceLabel.textAlignment = .right
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 8
        return row
    }

    @objc func decreaseTapped() {
        quantity == 1 ? onRemove?() : onDecrease?()
    }

    @objc func increaseTapped() {
        onIncrease?()
    }
}
