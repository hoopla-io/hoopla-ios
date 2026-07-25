//
//  ConfirmOrderView.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/06/25.
//

import UIKit

final class ConfirmOrderView: CustomView {
    var onConfirmOrder: (() -> Void)?
    var onDecreaseQuantity: (() -> Void)?
    var onIncreaseQuantity: (() -> Void)?

    let shopLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let drinkLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
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

    let orderButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .appColor(.mainColor)
        button.setTitleColor(.appColor(.white), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        return button
    }()

    private(set) var collectionViewHeightConstraint: NSLayoutConstraint!

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            UINib(nibName: ItemsCollectionViewCell.defaultReuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: ItemsCollectionViewCell.defaultReuseIdentifier
        )
        collectionView.register(
            ModifierGroupHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ModifierGroupHeaderView.defaultReuseIdentifier
        )
        return collectionView
    }()

    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(named: "dynamicWhite") ?? .systemBackground
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .label
        textView.autocapitalizationType = .sentences
        textView.layer.cornerRadius = 10
        textView.layer.cornerCurve = .continuous
        return textView
    }()

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let quantityContainer = UIView()
    private let decreaseButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let increaseButton = UIButton(type: .system)

    private enum TextViewLayout {
        static let inset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

    private let textViewPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "addComment".localized
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 15)
        label.isUserInteractionEnabled = false
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

    func setQuantity(_ quantity: Int) {
        quantityLabel.text = String(quantity)
        decreaseButton.isEnabled = quantity > 1
        decreaseButton.alpha = quantity > 1 ? 1 : 0.4
    }

    func setOrderButtonTitle(_ title: String) {
        if var configuration = orderButton.configuration {
            configuration.title = title
            orderButton.configuration = configuration
        } else {
            orderButton.setTitle(title, for: .normal)
        }
        orderButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
    }
}

extension ConfirmOrderView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewPlaceholderVisibility()
    }
}

private extension ConfirmOrderView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous

        configureScrollContent()
        configureQuantityControl()
        configureOrderButton()
        configureTextView()

        [scrollView, quantityContainer, orderButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: orderButton.topAnchor),

            contentStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 20
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: 20
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -20
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -10
            ),

            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            collectionViewHeightConstraint,
            textView.heightAnchor.constraint(equalToConstant: 100),

            quantityContainer.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            quantityContainer.centerYAnchor.constraint(equalTo: orderButton.centerYAnchor),
            quantityContainer.widthAnchor.constraint(equalToConstant: 118),
            quantityContainer.heightAnchor.constraint(equalTo: orderButton.heightAnchor),

            orderButton.leadingAnchor.constraint(
                equalTo: quantityContainer.trailingAnchor,
                constant: 14
            ),
            orderButton.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            orderButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -10
            ),
            orderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func configureScrollContent() {
        scrollView.showsVerticalScrollIndicator = false

        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        let labelsStackView = UIStackView(arrangedSubviews: [drinkLabel, shopLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 5

        let productStackView = UIStackView(arrangedSubviews: [imageView, labelsStackView])
        productStackView.axis = .horizontal
        productStackView.alignment = .center
        productStackView.spacing = 16

        [productStackView, collectionView, textView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        scrollView.addSubview(contentStackView)
    }

    func configureQuantityControl() {
        quantityContainer.backgroundColor = .secondarySystemBackground
        quantityContainer.layer.cornerRadius = 25
        quantityContainer.layer.cornerCurve = .continuous

        decreaseButton.setImage(UIImage(systemName: "minus"), for: .normal)
        increaseButton.setImage(UIImage(systemName: "plus"), for: .normal)
        [decreaseButton, increaseButton].forEach {
            $0.tintColor = .appColor(.mainColor)
            $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        }

        quantityLabel.font = .systemFont(ofSize: 17, weight: .bold)
        quantityLabel.textAlignment = .center

        let stackView = UIStackView(
            arrangedSubviews: [decreaseButton, quantityLabel, increaseButton]
        )
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        quantityContainer.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: quantityContainer.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: quantityContainer.trailingAnchor, constant: -4),
            stackView.topAnchor.constraint(equalTo: quantityContainer.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: quantityContainer.bottomAnchor)
        ])

        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        setQuantity(1)
    }

    func configureOrderButton() {
        if #available(iOS 26.0, *) {
            var configuration = UIButton.Configuration.clearGlass()
            configuration.baseForegroundColor = .appColor(.white)
            configuration.cornerStyle = .large
            orderButton.configuration = configuration
        }
        orderButton.addTarget(self, action: #selector(confirmOrderTapped), for: .touchUpInside)
    }

    func configureTextView() {
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.separator.withAlphaComponent(0.24).cgColor
        textView.delegate = self
        textView.textContainerInset = TextViewLayout.inset
        textView.textContainer.lineFragmentPadding = 0
        textView.addSubview(textViewPlaceholderLabel)

        NSLayoutConstraint.activate([
            textViewPlaceholderLabel.topAnchor.constraint(
                equalTo: textView.topAnchor,
                constant: TextViewLayout.inset.top
            ),
            textViewPlaceholderLabel.leadingAnchor.constraint(
                equalTo: textView.leadingAnchor,
                constant: TextViewLayout.inset.left
            ),
            textViewPlaceholderLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: textView.trailingAnchor,
                constant: -TextViewLayout.inset.right
            )
        ])

        updateTextViewPlaceholderVisibility()
    }

    func updateTextViewPlaceholderVisibility() {
        textViewPlaceholderLabel.isHidden = !textView.text.isEmpty
    }

    @objc func confirmOrderTapped() {
        onConfirmOrder?()
    }

    @objc func decreaseTapped() {
        onDecreaseQuantity?()
    }

    @objc func increaseTapped() {
        onIncreaseQuantity?()
    }
}
