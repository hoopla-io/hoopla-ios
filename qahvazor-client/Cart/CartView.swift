//
//  CartView.swift
//  qahvazor-client
//

import UIKit

final class CartView: CustomView {
    var onPromoAction: ((String, Bool) -> Void)?
    var onCommentFinished: ((String?) -> Void)?
    var onCheckout: (() -> Void)?

    private(set) var cart: Cart?
    private(set) var balance: Double = 0
    private(set) var itemViews = [Int: CartItemCardView]()
    private var cashbackAmount: Double = 0

    let scrollView = UIScrollView()
    let contentStackView = UIStackView()
    let itemStackView = UIStackView()

    let promoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "cartPromoPlaceholder".localized
        textField.font = .systemFont(ofSize: 16)
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.layer.cornerCurve = .continuous
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.setLeftPaddingPoints(14)
        textField.setRightPaddingPoints(10)
        return textField
    }()

    let promoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("apply".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .appColor(.mainColor)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        return button
    }()

    let cashbackSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .appColor(.mainColor)
        return toggle
    }()
    let cashbackBalanceLabel = UILabel()
    let cashbackSelectButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.accessibilityLabel = "cashbeck".localized
        return button
    }()

    let commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 20
        textView.layer.cornerCurve = .continuous
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        return textView
    }()

    let commentPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "addComment".localized
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    let subtotalValueLabel = UILabel()
    let discountValueLabel = UILabel()
    let cashbackValueLabel = UILabel()
    let totalValueLabel = UILabel()

    let checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .appColor(.mainColor)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.setTitle("cartCheckout".localized, for: .normal)
        return button
    }()

    private let shopNameLabel = UILabel()
    private let promoTitleLabel = UILabel()
    private let promoAccessoryImageView = UIImageView()
    private let promoEntryRow = UIStackView()
    private let bottomContainer = UIView()
    private let discountRow = UIStackView()
    private let cashbackRow = UIStackView()
    private let emptyStackView = UIStackView()
    private let emptyTitleLabel = UILabel()
    private let emptySubtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(
        cart: Cart?,
        balance: Double,
        useCashback: Bool? = nil,
        cashbackAmount: Double? = nil
    ) {
        self.cart = cart
        self.balance = max(balance, 0)

        guard let cart, cart.items?.isEmpty == false else {
            showEmptyState(isAuthenticated: true)
            return
        }

        scrollView.isHidden = false
        bottomContainer.isHidden = false
        emptyStackView.isHidden = true
        rebuildItems(cart.items ?? [])

        shopNameLabel.text = cart.shopDisplayName
        shopNameLabel.isHidden = cart.shopDisplayName == nil

        let promoIsApplied = cart.promoCode?.isEmpty == false
        if promoIsApplied {
            promoTextField.text = cart.promoCode
            promoTitleLabel.text = ["promocode".localized, cart.promoCode]
                .compactMap { $0 }
                .joined(separator: " · ")
            promoAccessoryImageView.image = UIImage(systemName: "xmark.circle.fill")
            promoAccessoryImageView.tintColor = .systemRed
            promoEntryRow.isHidden = true
        } else {
            if !promoTextField.isFirstResponder {
                promoTextField.text = nil
                promoEntryRow.isHidden = true
            }
            promoTitleLabel.text = "promocode".localized
            promoAccessoryImageView.image = UIImage(systemName: "chevron.right")
            promoAccessoryImageView.tintColor = .secondaryLabel
        }
        promoTextField.isEnabled = !promoIsApplied

        if !commentTextView.isFirstResponder {
            commentTextView.text = cart.comment ?? ""
            updateCommentPlaceholder()
        }

        cashbackBalanceLabel.text = "available".localized + ": " + self.balance.formattedWithSeparator
        if self.balance == 0 {
            cashbackSwitch.isOn = false
        }
        if let useCashback {
            cashbackSwitch.isOn = useCashback && self.balance > 0
        }

        let maxAmount = maximumCashback
        self.cashbackAmount = min(max(cashbackAmount ?? self.cashbackAmount, 0), maxAmount)
        cashbackSwitch.isEnabled = self.balance > 0 && maxAmount > 0
        cashbackSwitch.isOn = cashbackSwitch.isOn && self.cashbackAmount > 0
        cashbackSelectButton.isEnabled = self.balance > 0 && maxAmount > 0

        updateTotals()
    }

    func setCashback(amount: Double, enabled: Bool) {
        cashbackAmount = min(max(amount, 0), maximumCashback)
        cashbackSwitch.isOn = enabled && cashbackAmount > 0
        updateTotals()
    }

    func showEmptyState(isAuthenticated: Bool) {
        cart = nil
        scrollView.isHidden = true
        bottomContainer.isHidden = true
        emptyStackView.isHidden = false
        emptyTitleLabel.text = isAuthenticated ? "cartEmptyTitle".localized : "cartSignInTitle".localized
        emptySubtitleLabel.text = isAuthenticated ? "cartEmptySubtitle".localized : "cartSignInSubtitle".localized
    }

    func setItem(_ itemId: Int, loading: Bool) {
        itemViews[itemId]?.setLoading(loading)
    }

    var comment: String? {
        let value = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : String(value.prefix(500))
    }

    var currentCashbackAmount: Double {
        min(cashbackAmount, maximumCashback)
    }

    private var maximumCashback: Double {
        let subtotal = cart?.subtotal ?? 0
        let promoDiscount = cart?.promoDiscount ?? 0
        return min(balance, max(subtotal - promoDiscount, 0))
    }
}

private extension CartView {
    func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        shopNameLabel.font = .systemFont(ofSize: 18)
        shopNameLabel.textColor = .secondaryLabel
        shopNameLabel.numberOfLines = 2

        itemStackView.axis = .vertical
        itemStackView.spacing = 12

        let promoCard = makePromoCard()
        let cashbackCard = makeCashbackCard()
        let noteCard = makeNoteCard()

        [shopNameLabel, itemStackView, promoCard, cashbackCard, noteCard].forEach {
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.setCustomSpacing(22, after: shopNameLabel)
        contentStackView.setCustomSpacing(20, after: itemStackView)

        setupBottomContainer()
        setupEmptyState()
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        addSubview(bottomContainer)
        addSubview(emptyStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 18),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -18),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),

            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            emptyStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            emptyStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            emptyStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32)
        ])

        promoButton.addTarget(self, action: #selector(promoTapped), for: .touchUpInside)
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        commentTextView.delegate = self
        promoTextField.delegate = self
    }

    func makePromoCard() -> UIStackView {
        let card = makeCard(padding: .zero)
        card.spacing = 0

        let icon = UIImageView(image: UIImage(systemName: "ticket"))
        icon.tintColor = .secondaryLabel
        icon.contentMode = .scaleAspectFit
        icon.widthAnchor.constraint(equalToConstant: 24).isActive = true

        promoTitleLabel.text = "promocode".localized
        promoTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        promoTitleLabel.textColor = .secondaryLabel

        promoAccessoryImageView.image = UIImage(systemName: "chevron.right")
        promoAccessoryImageView.tintColor = .secondaryLabel
        promoAccessoryImageView.contentMode = .scaleAspectFit
        promoAccessoryImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true

        let headerStack = UIStackView(arrangedSubviews: [icon, promoTitleLabel, promoAccessoryImageView])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let header = UIView()
        header.addSubview(headerStack)
        NSLayoutConstraint.activate([
            header.heightAnchor.constraint(equalToConstant: 64),
            headerStack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            headerStack.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])

        let headerButton = UIButton(type: .system)
        headerButton.translatesAutoresizingMaskIntoConstraints = false
        headerButton.accessibilityLabel = "promocode".localized
        headerButton.addTarget(self, action: #selector(promoHeaderTapped), for: .touchUpInside)
        header.addSubview(headerButton)
        NSLayoutConstraint.activate([
            headerButton.topAnchor.constraint(equalTo: header.topAnchor),
            headerButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            headerButton.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            headerButton.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        ])

        promoEntryRow.axis = .horizontal
        promoEntryRow.spacing = 10
        promoEntryRow.isLayoutMarginsRelativeArrangement = true
        promoEntryRow.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12)
        promoEntryRow.addArrangedSubview(promoTextField)
        promoEntryRow.addArrangedSubview(promoButton)
        promoEntryRow.isHidden = true
        promoTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        promoButton.widthAnchor.constraint(equalToConstant: 88).isActive = true

        card.addArrangedSubview(header)
        card.addArrangedSubview(promoEntryRow)
        return card
    }

    func makeCashbackCard() -> UIStackView {
        let card = makeCard()

        let icon = UIImageView(image: UIImage(systemName: "banknote"))
        icon.tintColor = .secondaryLabel
        icon.contentMode = .scaleAspectFit
        icon.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let titleLabel = makeLabel(
            "cashbeck".localized,
            font: .systemFont(ofSize: 17, weight: .medium)
        )
        cashbackBalanceLabel.font = .systemFont(ofSize: 15)
        cashbackBalanceLabel.textColor = .secondaryLabel
        let labels = UIStackView(arrangedSubviews: [titleLabel, cashbackBalanceLabel])
        labels.axis = .vertical
        labels.spacing = 2

        let row = UIStackView(arrangedSubviews: [icon, labels, cashbackSwitch])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        card.addArrangedSubview(row)

        cashbackSelectButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cashbackSelectButton)
        NSLayoutConstraint.activate([
            cashbackSelectButton.topAnchor.constraint(equalTo: card.topAnchor),
            cashbackSelectButton.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cashbackSelectButton.trailingAnchor.constraint(equalTo: cashbackSwitch.leadingAnchor, constant: -8),
            cashbackSelectButton.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return card
    }

    func makeNoteCard() -> UIView {
        let container = UIView()
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        commentPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(commentTextView)
        container.addSubview(commentPlaceholderLabel)
        NSLayoutConstraint.activate([
            commentTextView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            commentTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            commentTextView.topAnchor.constraint(equalTo: container.topAnchor),
            commentTextView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            commentTextView.heightAnchor.constraint(equalToConstant: 104),
            commentPlaceholderLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 16),
            commentPlaceholderLabel.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 16),
            commentPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: commentTextView.trailingAnchor, constant: -16)
        ])
        return container
    }

    func setupBottomContainer() {
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.backgroundColor = .systemBackground
        bottomContainer.layer.borderWidth = 0.5
        bottomContainer.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        bottomContainer.layer.shadowColor = UIColor.black.cgColor
        bottomContainer.layer.shadowOpacity = 0.04
        bottomContainer.layer.shadowOffset = CGSize(width: 0, height: -4)
        bottomContainer.layer.shadowRadius = 12

        configureValueLabel(subtotalValueLabel)
        configureValueLabel(discountValueLabel)
        configureValueLabel(cashbackValueLabel)
        configureValueLabel(totalValueLabel, bold: true)

        let totals = UIStackView()
        totals.axis = .vertical
        totals.spacing = 7
        totals.addArrangedSubview(makeTotalRow(title: "cartDrinks".localized, value: subtotalValueLabel, muted: true))

        discountRow.addArrangedSubview(makeLabel("cartDiscount".localized + ":", color: .secondaryLabel))
        discountRow.addArrangedSubview(discountValueLabel)
        discountRow.axis = .horizontal
        discountRow.isHidden = true
        totals.addArrangedSubview(discountRow)

        cashbackRow.addArrangedSubview(makeLabel("cartCashback".localized + ":", color: .secondaryLabel))
        cashbackRow.addArrangedSubview(cashbackValueLabel)
        cashbackRow.axis = .horizontal
        totals.addArrangedSubview(cashbackRow)

        totals.addArrangedSubview(makeTotalRow(title: "total".localized, value: totalValueLabel, bold: true))

        checkoutButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        let stack = UIStackView(arrangedSubviews: [totals, checkoutButton])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -16)
        ])
    }

    func setupEmptyState() {
        let imageView = UIImageView(image: UIImage(systemName: "cart"))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 72).isActive = true

        emptyTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.numberOfLines = 0
        emptySubtitleLabel.font = .systemFont(ofSize: 15)
        emptySubtitleLabel.textColor = .secondaryLabel
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 0

        emptyStackView.axis = .vertical
        emptyStackView.alignment = .center
        emptyStackView.spacing = 12
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        [imageView, emptyTitleLabel, emptySubtitleLabel].forEach { emptyStackView.addArrangedSubview($0) }
    }

    func rebuildItems(_ items: [CartItem]) {
        itemStackView.arrangedSubviews.forEach {
            itemStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        itemViews.removeAll()

        items.forEach { item in
            let itemView = CartItemCardView()
            itemView.configure(with: item)
            if let id = item.id {
                itemViews[id] = itemView
            }
            itemStackView.addArrangedSubview(itemView)
        }
    }

    func updateTotals() {
        guard let cart else { return }
        let subtotal = max(cart.subtotal ?? 0, 0)
        let discount = max(cart.promoDiscount ?? 0, 0)
        let cashback = cashbackSwitch.isOn ? currentCashbackAmount : 0
        let finalTotal = max(subtotal - discount - cashback, 0)
        let hasDeduction = discount + cashback > 0

        if hasDeduction {
            subtotalValueLabel.attributedText = NSAttributedString(
                string: subtotal.formattedWithCurrency,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
        } else {
            subtotalValueLabel.attributedText = nil
            subtotalValueLabel.text = subtotal.formattedWithCurrency
        }
        discountValueLabel.text = "-\(discount.formattedWithCurrency)"
        cashbackValueLabel.text = "-\(cashback.formattedWithCurrency)"
        totalValueLabel.text = "+\(finalTotal.formattedWithCurrency)"
        discountRow.isHidden = discount == 0
    }

    func updateCommentPlaceholder() {
        commentPlaceholderLabel.isHidden = !commentTextView.text.isEmpty
    }

    @objc func promoHeaderTapped() {
        if cart?.promoCode?.isEmpty == false {
            promoTapped()
            return
        }

        promoEntryRow.isHidden.toggle()
        promoAccessoryImageView.image = UIImage(
            systemName: promoEntryRow.isHidden ? "chevron.right" : "chevron.up"
        )
        if !promoEntryRow.isHidden {
            promoTextField.becomeFirstResponder()
        }
    }

    @objc func promoTapped() {
        let isRemoving = cart?.promoCode?.isEmpty == false
        let code = promoTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard isRemoving || !code.isEmpty else { return }
        onPromoAction?(code, isRemoving)
    }

    @objc func checkoutTapped() {
        onCheckout?()
    }

    func makeCard(padding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = padding
        stackView.backgroundColor = .systemBackground
        stackView.layer.cornerRadius = 20
        stackView.layer.cornerCurve = .continuous
        return stackView
    }

    func makeLabel(
        _ text: String,
        font: UIFont = .systemFont(ofSize: 15),
        color: UIColor = .label
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        return label
    }

    func configureValueLabel(_ label: UILabel, bold: Bool = false) {
        label.font = .systemFont(ofSize: bold ? 19 : 15, weight: bold ? .bold : .regular)
        label.textColor = bold ? .label : .secondaryLabel
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
    }

    func makeTotalRow(
        title: String,
        value: UILabel,
        bold: Bool = false,
        muted: Bool = false
    ) -> UIStackView {
        let titleLabel = makeLabel(
            title + ":",
            font: .systemFont(ofSize: bold ? 19 : 15, weight: bold ? .medium : .regular),
            color: muted ? .tertiaryLabel : (bold ? .label : .secondaryLabel)
        )
        let row = UIStackView(arrangedSubviews: [titleLabel, value])
        row.axis = .horizontal
        return row
    }
}

extension CartView: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 500 {
            textView.text = String(textView.text.prefix(500))
        }
        updateCommentPlaceholder()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        onCommentFinished?(comment)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField === promoTextField {
            promoTapped()
        }
        return true
    }
}
