//
//  CheckoutView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//

import UIKit

final class CheckoutView: CustomView {
    // MARK: - UI Elements
    let shopLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let drinkTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()

    let drinkLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let drinkPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    let modifierStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private(set) var modifierCollectionViewHeightConstraint: NSLayoutConstraint!

    let modifierCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            CheckoutModifierCollectionViewCell.self,
            forCellWithReuseIdentifier: CheckoutModifierCollectionViewCell.defaultReuseIdentifier
        )
        return collectionView
    }()

    let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    let commentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.isHidden = true
        return stackView
    }()

    let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()

    let oldPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()

    let cashbackPercentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.isHidden = true
        return stackView
    }()

    let cashbackPercentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "youGet".localized
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .appColor(.green)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let cashbackPercentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .appColor(.green)
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    let cashbackSwitch: UISwitch = {
        let cashbackSwitch = UISwitch()
        cashbackSwitch.setContentHuggingPriority(.required, for: .horizontal)
        cashbackSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
        return cashbackSwitch
    }()

    let cashbackPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .appColor(.white)
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    let cashbackContainerView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topColor = UIColor(hex: "#BC4C59") ?? .red
        view.bottomColor = UIColor(hex: "#E45E6D") ?? .red
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appColor(.mainColor)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        button.setTitle("confirm".localized, for: .normal)
        button.setTitleColor(.appColor(.white), for: .normal)

        if #available(iOS 26.0, *) {
            var config: UIButton.Configuration
            config = .clearGlass()
            config.baseForegroundColor = .appColor(.white)
            config.cornerStyle = .large
            config.title = "confirm".localized
            button.configuration = config
        }
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
}

private extension CheckoutView {
    func setupUI() {
        backgroundColor = .systemBackground

        let titleStackView = UIStackView(arrangedSubviews: [drinkTitleLabel, shopLabel])
        titleStackView.axis = .vertical
        titleStackView.spacing = 5

        let headerStackView = UIStackView(arrangedSubviews: [imageView, titleStackView])
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = 16
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        let commentTitleLabel = makeLabel(text: "comment".localized, font: .systemFont(ofSize: 16), color: .secondaryLabel)
        let totalTitleLabel = makeLabel(text: "total".localized, font: .systemFont(ofSize: 16), color: .label)

        let productStackView = makeRowStack(leftView: drinkLabel, rightView: drinkPriceLabel)

        commentStackView.addArrangedSubview(commentTitleLabel)
        commentStackView.addArrangedSubview(commentLabel)

        let priceStackView = UIStackView(arrangedSubviews: [oldPriceLabel, totalPriceLabel])
        priceStackView.axis = .vertical
        priceStackView.alignment = .trailing
        priceStackView.spacing = 4
        priceStackView.setContentHuggingPriority(.required, for: .horizontal)
        priceStackView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let totalStackView = makeRowStack(leftView: totalTitleLabel, rightView: priceStackView, alignment: .top)

        cashbackPercentStackView.addArrangedSubview(cashbackPercentTitleLabel)
        cashbackPercentStackView.addArrangedSubview(cashbackPercentLabel)

        modifierStackView.addArrangedSubview(productStackView)
        modifierStackView.addArrangedSubview(commentStackView)
        modifierStackView.addArrangedSubview(totalStackView)
        modifierStackView.addArrangedSubview(cashbackPercentStackView)
        configureModifierCollectionView()

        let cashbackTitleLabel = makeLabel(text: "cashbeck".localized, font: .systemFont(ofSize: 16), color: .appColor(.white))
        cashbackTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let cashbackAmountStackView = makeRowStack(leftView: cashbackTitleLabel, rightView: cashbackPriceLabel)
        cashbackAmountStackView.translatesAutoresizingMaskIntoConstraints = false
        cashbackContainerView.addSubview(cashbackAmountStackView)

        let useCashbackLabel = makeLabel(text: "useCashbeck".localized, font: .systemFont(ofSize: 16), color: .label)
        useCashbackLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let switchStackView = makeRowStack(leftView: useCashbackLabel, rightView: cashbackSwitch, spacing: 16)

        let cashbackStackView = UIStackView(arrangedSubviews: [cashbackContainerView, switchStackView])
        cashbackStackView.axis = .vertical
        cashbackStackView.spacing = 10
        cashbackStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(headerStackView)
        addSubview(modifierStackView)
        addSubview(cashbackStackView)
        addSubview(nextButton)

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            headerStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            headerStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),

            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            modifierStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 30),
            modifierStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            modifierStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),

            cashbackStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cashbackStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),

            cashbackContainerView.heightAnchor.constraint(equalToConstant: 40),
            cashbackAmountStackView.topAnchor.constraint(equalTo: cashbackContainerView.topAnchor),
            cashbackAmountStackView.leadingAnchor.constraint(equalTo: cashbackContainerView.leadingAnchor, constant: 16),
            cashbackAmountStackView.trailingAnchor.constraint(equalTo: cashbackContainerView.trailingAnchor, constant: -16),
            cashbackAmountStackView.bottomAnchor.constraint(equalTo: cashbackContainerView.bottomAnchor),

            nextButton.topAnchor.constraint(equalTo: cashbackStackView.bottomAnchor, constant: 25),
            nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func makeLabel(text: String? = nil, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    func makeRowStack(
        leftView: UIView,
        rightView: UIView,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 16
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [leftView, rightView])
        stackView.axis = .horizontal
        stackView.alignment = alignment
        stackView.distribution = .fill
        stackView.spacing = spacing

        leftView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightView.setContentHuggingPriority(.required, for: .horizontal)
        rightView.setContentCompressionResistancePriority(.required, for: .horizontal)

        return stackView
    }

    func configureModifierCollectionView() {
        guard !modifierStackView.arrangedSubviews.contains(modifierCollectionView) else { return }

        modifierCollectionViewHeightConstraint = modifierCollectionView.heightAnchor.constraint(equalToConstant: 0)
        modifierCollectionViewHeightConstraint.isActive = true

        let index = min(1, modifierStackView.arrangedSubviews.count)
        modifierStackView.insertArrangedSubview(modifierCollectionView, at: index)
    }
}
