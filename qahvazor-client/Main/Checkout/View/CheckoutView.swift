//
//  CheckoutView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//

import UIKit

final class CheckoutView: CustomView {
    // MARK: - UI Elements
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    let shopLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let drinkTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
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
        stackView.spacing = 18
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

    let promocodeDiscountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.isHidden = true
        return stackView
    }()

    let promocodeDiscountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .appColor(.green)
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
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

    let promoCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.contentHorizontalAlignment = .leading
        button.tintColor = .appColor(.mainColor)

        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus")
        configuration.imagePadding = 14
        configuration.title = "addPromocode".localized
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 48)
        configuration.baseForegroundColor = .appColor(.mainColor)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .regular)
            outgoing.foregroundColor = .label
            return outgoing
        }
        button.configuration = configuration

        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.tintColor = .tertiaryLabel
        button.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -18)
        ])

        return button
    }()

    let appliedPromocodeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.isHidden = true
        return view
    }()

    let appliedPromocodeCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let appliedPromocodeDiscountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .appColor(.green)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let removePromocodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .tertiaryLabel
        return button
    }()

    let cashbackSwitch: UISwitch = {
        let cashbackSwitch = UISwitch()
        cashbackSwitch.setContentHuggingPriority(.required, for: .horizontal)
        cashbackSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
        return cashbackSwitch
    }()

    let cashbackSelectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.accessibilityLabel = "cashbeck".localized
        return button
    }()

    let cashbackPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let cashbackContainerView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topColor = .systemBackground
        view.bottomColor = .systemBackground
        view.layer.cornerRadius = 14
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
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
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

    func showAppliedPromocode(code: String, discountAmount: Double) {
        promoCodeButton.isHidden = true
        appliedPromocodeView.isHidden = false
        promocodeDiscountStackView.isHidden = false
        appliedPromocodeCodeLabel.text = code
        appliedPromocodeDiscountLabel.text = "-\(discountAmount.formattedWithCurrency)"
        promocodeDiscountLabel.text = "-\(discountAmount.formattedWithCurrency)"
    }

    func resetPromocode() {
        promoCodeButton.isHidden = false
        appliedPromocodeView.isHidden = true
        promocodeDiscountStackView.isHidden = true
        appliedPromocodeCodeLabel.text = nil
        appliedPromocodeDiscountLabel.text = nil
        promocodeDiscountLabel.text = nil
    }
}

private extension CheckoutView {
    func setupUI() {
        backgroundColor = .appColor(.mainBackground)

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 28
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 24, left: 14, bottom: 24, right: 14)

        let titleStackView = UIStackView(arrangedSubviews: [drinkTitleLabel, shopLabel])
        titleStackView.axis = .vertical
        titleStackView.spacing = 6

        let headerStackView = UIStackView(arrangedSubviews: [imageView, titleStackView])
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = 20

        let commentTitleLabel = makeLabel(text: "comment".localized, font: .systemFont(ofSize: 16), color: .secondaryLabel)
        let promocodeDiscountTitleLabel = makeLabel(text: "promocodeDiscount".localized, font: .systemFont(ofSize: 16), color: .secondaryLabel)
        let totalTitleLabel = makeLabel(text: "total".localized, font: .systemFont(ofSize: 16), color: .label)

        let productStackView = makeRowStack(leftView: drinkLabel, rightView: drinkPriceLabel)

        commentStackView.addArrangedSubview(commentTitleLabel)
        commentStackView.addArrangedSubview(commentLabel)

        promocodeDiscountStackView.addArrangedSubview(promocodeDiscountTitleLabel)
        promocodeDiscountStackView.addArrangedSubview(promocodeDiscountLabel)

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
        modifierStackView.addArrangedSubview(promocodeDiscountStackView)
        modifierStackView.addArrangedSubview(totalStackView)
        modifierStackView.addArrangedSubview(cashbackPercentStackView)
        configureModifierCollectionView()

        let bottomContainerView = UIView()
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.backgroundColor = .appColor(.mainBackground)
        bottomContainerView.layer.cornerRadius = 24
        bottomContainerView.layer.cornerCurve = .continuous
        bottomContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomContainerView.layer.shadowColor = UIColor.black.cgColor
        bottomContainerView.layer.shadowOpacity = 0.05
        bottomContainerView.layer.shadowRadius = 12
        bottomContainerView.layer.shadowOffset = CGSize(width: 0, height: -4)

        let appliedPromocodeTextStackView = UIStackView(arrangedSubviews: [appliedPromocodeCodeLabel, appliedPromocodeDiscountLabel])
        appliedPromocodeTextStackView.axis = .vertical
        appliedPromocodeTextStackView.spacing = 2
        appliedPromocodeTextStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.tintColor = .appColor(.green)
        checkmarkImageView.contentMode = .scaleAspectFit

        let appliedPromocodeStackView = UIStackView(arrangedSubviews: [checkmarkImageView, appliedPromocodeTextStackView, removePromocodeButton])
        appliedPromocodeStackView.axis = .horizontal
        appliedPromocodeStackView.alignment = .center
        appliedPromocodeStackView.spacing = 14
        appliedPromocodeStackView.translatesAutoresizingMaskIntoConstraints = false
        appliedPromocodeView.addSubview(appliedPromocodeStackView)

        let cashbackTitleLabel = makeLabel(text: "cashbeck".localized, font: .systemFont(ofSize: 16, weight: .medium), color: .label)
        let cashbackTextStackView = UIStackView(arrangedSubviews: [cashbackTitleLabel, cashbackPriceLabel])
        cashbackTextStackView.axis = .vertical
        cashbackTextStackView.spacing = 2
        cashbackTextStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let cashbackIconView = makeCashbackIconView()
        let cashbackRowStackView = UIStackView(arrangedSubviews: [cashbackIconView, cashbackTextStackView, cashbackSwitch])
        cashbackRowStackView.axis = .horizontal
        cashbackRowStackView.alignment = .center
        cashbackRowStackView.spacing = 12
        cashbackRowStackView.translatesAutoresizingMaskIntoConstraints = false
        cashbackContainerView.addSubview(cashbackRowStackView)
        cashbackContainerView.addSubview(cashbackSelectButton)

        let bottomStackView = UIStackView(arrangedSubviews: [promoCodeButton, appliedPromocodeView, cashbackContainerView, nextButton])
        bottomStackView.axis = .vertical
        bottomStackView.spacing = 16
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        addSubview(bottomContainerView)
        scrollView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(modifierStackView)
        bottomContainerView.addSubview(bottomStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),

            bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            bottomStackView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 12),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -12),
            bottomStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),

            promoCodeButton.heightAnchor.constraint(equalToConstant: 60),
            appliedPromocodeView.heightAnchor.constraint(equalToConstant: 60),
            cashbackContainerView.heightAnchor.constraint(equalToConstant: 70),
            nextButton.heightAnchor.constraint(equalToConstant: 60),

            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),

            removePromocodeButton.widthAnchor.constraint(equalToConstant: 44),
            removePromocodeButton.heightAnchor.constraint(equalToConstant: 44),

            appliedPromocodeStackView.topAnchor.constraint(equalTo: appliedPromocodeView.topAnchor, constant: 8),
            appliedPromocodeStackView.leadingAnchor.constraint(equalTo: appliedPromocodeView.leadingAnchor, constant: 22),
            appliedPromocodeStackView.trailingAnchor.constraint(equalTo: appliedPromocodeView.trailingAnchor, constant: -12),
            appliedPromocodeStackView.bottomAnchor.constraint(equalTo: appliedPromocodeView.bottomAnchor, constant: -8),

            cashbackIconView.widthAnchor.constraint(equalToConstant: 34),
            cashbackIconView.heightAnchor.constraint(equalToConstant: 34),

            cashbackRowStackView.topAnchor.constraint(equalTo: cashbackContainerView.topAnchor, constant: 12),
            cashbackRowStackView.leadingAnchor.constraint(equalTo: cashbackContainerView.leadingAnchor, constant: 16),
            cashbackRowStackView.trailingAnchor.constraint(equalTo: cashbackContainerView.trailingAnchor, constant: -16),
            cashbackRowStackView.bottomAnchor.constraint(equalTo: cashbackContainerView.bottomAnchor, constant: -12),

            cashbackSelectButton.topAnchor.constraint(equalTo: cashbackContainerView.topAnchor),
            cashbackSelectButton.leadingAnchor.constraint(equalTo: cashbackContainerView.leadingAnchor),
            cashbackSelectButton.trailingAnchor.constraint(equalTo: cashbackSwitch.leadingAnchor, constant: -8),
            cashbackSelectButton.bottomAnchor.constraint(equalTo: cashbackContainerView.bottomAnchor)
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

    func makeCashbackIconView() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.appColor(.white).withAlphaComponent(0.7)
        containerView.layer.cornerRadius = 17
        containerView.layer.cornerCurve = .continuous

        let imageView = UIImageView(image: UIImage(systemName: "c.circle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.appColor(.secondBackground)
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22)
        ])

        return containerView
    }

    func configureModifierCollectionView() {
        guard !modifierStackView.arrangedSubviews.contains(modifierCollectionView) else { return }

        modifierCollectionViewHeightConstraint = modifierCollectionView.heightAnchor.constraint(equalToConstant: 0)
        modifierCollectionViewHeightConstraint.isActive = true

        let index = min(1, modifierStackView.arrangedSubviews.count)
        modifierStackView.insertArrangedSubview(modifierCollectionView, at: index)
    }
}
