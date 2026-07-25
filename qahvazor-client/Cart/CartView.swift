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
        textField.backgroundColor = .systemBackground
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        textField.layer.cornerRadius = 12
        textField.layer.cornerCurve = .continuous
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.setLeftPaddingPoints(14)
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

    let cashbackSwitch = UISwitch()
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
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 12
        textView.layer.cornerCurve = .continuous
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        return textView
    }()

    let commentPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "cartNotePlaceholder".localized
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    let subtotalValueLabel = UILabel()
    let discountValueLabel = UILabel()
    let cashbackValueLabel = UILabel()
    let totalValueLabel = UILabel()
    private let discountRow = UIStackView()
    private let cashbackRow = UIStackView()

    let checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .appColor(.mainColor)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 28
        button.layer.cornerCurve = .continuous
        return button
    }()

    private let bottomContainer = UIView()
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

        let promoIsApplied = cart.promoCode?.isEmpty == false
        if promoIsApplied {
            promoTextField.text = cart.promoCode
        } else if !promoTextField.isFirstResponder {
            promoTextField.text = nil
        }
        promoTextField.isEnabled = !promoIsApplied
        promoButton.setTitle(promoIsApplied ? "remove".localized : "apply".localized, for: .normal)
        promoButton.backgroundColor = promoIsApplied ? .systemRed : .appColor(.mainColor)

        if !commentTextView.isFirstResponder {
            commentTextView.text = cart.comment ?? ""
            updateCommentPlaceholder()
        }

        cashbackBalanceLabel.text = "balance".localized + " " + self.balance.formattedWithCurrency
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

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        itemStackView.axis = .vertical
        itemStackView.spacing = 14

        let promoCard = makeCard()
        let promoTitle = makeTitle("promocode".localized)
        let promoRow = UIStackView(arrangedSubviews: [promoTextField, promoButton])
        promoRow.axis = .horizontal
        promoRow.spacing = 10
        promoButton.widthAnchor.constraint(equalToConstant: 92).isActive = true
        promoTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        promoCard.addArrangedSubview(promoTitle)
        promoCard.addArrangedSubview(promoRow)

        let cashbackCard = makeCard()
        let cashbackTitle = makeTitle("useCashbeck".localized)
        cashbackBalanceLabel.font = .systemFont(ofSize: 14)
        cashbackBalanceLabel.textColor = .secondaryLabel
        let cashbackLabels = UIStackView(arrangedSubviews: [cashbackTitle, cashbackBalanceLabel])
        cashbackLabels.axis = .vertical
        cashbackLabels.spacing = 3
        let cashbackHeader = UIStackView(arrangedSubviews: [cashbackLabels, cashbackSwitch])
        cashbackHeader.axis = .horizontal
        cashbackHeader.alignment = .center
        cashbackCard.addArrangedSubview(cashbackHeader)
        cashbackSelectButton.translatesAutoresizingMaskIntoConstraints = false
        cashbackCard.addSubview(cashbackSelectButton)
        NSLayoutConstraint.activate([
            cashbackSelectButton.topAnchor.constraint(equalTo: cashbackCard.topAnchor),
            cashbackSelectButton.leadingAnchor.constraint(equalTo: cashbackCard.leadingAnchor),
            cashbackSelectButton.trailingAnchor.constraint(
                equalTo: cashbackSwitch.leadingAnchor,
                constant: -8
            ),
            cashbackSelectButton.bottomAnchor.constraint(equalTo: cashbackCard.bottomAnchor)
        ])

        let noteCard = makeCard()
        noteCard.addArrangedSubview(makeTitle("cartNoteTitle".localized))
        let textContainer = UIView()
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        commentPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(commentTextView)
        textContainer.addSubview(commentPlaceholderLabel)
        NSLayoutConstraint.activate([
            commentTextView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            commentTextView.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            commentTextView.topAnchor.constraint(equalTo: textContainer.topAnchor),
            commentTextView.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),
            commentTextView.heightAnchor.constraint(equalToConstant: 92),
            commentPlaceholderLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 15),
            commentPlaceholderLabel.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 12),
            commentPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: commentTextView.trailingAnchor, constant: -12)
        ])
        noteCard.addArrangedSubview(textContainer)

        let totalsCard = makeCard()
        totalsCard.spacing = 10
        configureValueLabel(subtotalValueLabel)
        configureValueLabel(discountValueLabel)
        configureValueLabel(cashbackValueLabel)
        configureValueLabel(totalValueLabel, bold: true)
        totalsCard.addArrangedSubview(makeTotalRow(title: "price".localized, value: subtotalValueLabel))
        discountRow.addArrangedSubview(makeLabel("cartDiscount".localized))
        discountRow.addArrangedSubview(discountValueLabel)
        cashbackRow.addArrangedSubview(makeLabel("cartCashback".localized))
        cashbackRow.addArrangedSubview(cashbackValueLabel)
        [discountRow, cashbackRow].forEach {
            $0.axis = .horizontal
            $0.distribution = .fill
            totalsCard.addArrangedSubview($0)
        }
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        totalsCard.addArrangedSubview(divider)
        totalsCard.addArrangedSubview(makeTotalRow(title: "total".localized, value: totalValueLabel, bold: true))

        [itemStackView, promoCard, cashbackCard, noteCard, totalsCard].forEach {
            contentStackView.addArrangedSubview($0)
        }

        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.backgroundColor = .systemBackground
        bottomContainer.layer.shadowColor = UIColor.black.cgColor
        bottomContainer.layer.shadowOpacity = 0.08
        bottomContainer.layer.shadowOffset = CGSize(width: 0, height: -4)
        bottomContainer.layer.shadowRadius = 12
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(checkoutButton)

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
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            checkoutButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 12),
            checkoutButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            checkoutButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            checkoutButton.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -12),
            checkoutButton.heightAnchor.constraint(equalToConstant: 56),

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

    func setupEmptyState() {
        let imageView = UIImageView(image: UIImage(systemName: "bag"))
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

        subtotalValueLabel.text = subtotal.formattedWithCurrency
        discountValueLabel.text = "-\(discount.formattedWithCurrency)"
        cashbackValueLabel.text = "-\(cashback.formattedWithCurrency)"
        totalValueLabel.text = finalTotal.formattedWithCurrency
        discountRow.isHidden = discount == 0
        cashbackRow.isHidden = cashback == 0
        checkoutButton.setTitle(
            "cartCheckout".localized + " · " + finalTotal.formattedWithCurrency,
            for: .normal
        )
    }

    func updateCommentPlaceholder() {
        commentPlaceholderLabel.isHidden = !commentTextView.text.isEmpty
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

    func makeCard() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
        stackView.backgroundColor = .systemBackground
        stackView.layer.cornerRadius = 16
        stackView.layer.cornerCurve = .continuous
        stackView.layer.shadowColor = UIColor.black.cgColor
        stackView.layer.shadowOpacity = 0.04
        stackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        stackView.layer.shadowRadius = 5
        return stackView
    }

    func makeTitle(_ text: String) -> UILabel {
        makeLabel(text, font: .systemFont(ofSize: 17, weight: .semibold))
    }

    func makeLabel(_ text: String, font: UIFont = .systemFont(ofSize: 15)) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        return label
    }

    func configureValueLabel(_ label: UILabel, bold: Bool = false) {
        label.font = .systemFont(ofSize: bold ? 17 : 15, weight: bold ? .bold : .regular)
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
    }

    func makeTotalRow(title: String, value: UILabel, bold: Bool = false) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [
            makeLabel(title, font: .systemFont(ofSize: bold ? 17 : 15, weight: bold ? .bold : .regular)),
            value
        ])
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

final class CartItemCardView: UIView {
    var onDecrease: (() -> Void)?
    var onIncrease: (() -> Void)?
    var onRemove: (() -> Void)?

    private let decreaseButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let increaseButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
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
        decreaseButton.setImage(
            UIImage(systemName: "minus"),
            for: .normal
        )
        decreaseButton.tintColor = .secondaryLabel

        let titleLabel = viewWithTag(101) as? UILabel
        let modifierLabel = viewWithTag(102) as? UILabel
        let unitPriceLabel = viewWithTag(103) as? UILabel
        let lineTotalLabel = viewWithTag(104) as? UILabel

        titleLabel?.text = item.name
        let modifierNames = item.modifiers?
            .compactMap(\.name)
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        modifierLabel?.text = modifierNames
        modifierLabel?.isHidden = modifierNames?.isEmpty != false
        unitPriceLabel?.text = (item.unitPrice ?? 0).formattedWithCurrency + " " + "cartEach".localized
        lineTotalLabel?.text = (item.lineTotal ?? 0).formattedWithCurrency
    }

    func setLoading(_ loading: Bool) {
        decreaseButton.isEnabled = !loading
        increaseButton.isEnabled = !loading
        activityIndicator.isHidden = !loading
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

private extension CartItemCardView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5

        let titleLabel = makeLabel(font: .systemFont(ofSize: 18, weight: .semibold), tag: 101)
        titleLabel.numberOfLines = 3
        let modifierLabel = makeLabel(font: .systemFont(ofSize: 14), color: .secondaryLabel, tag: 102)
        modifierLabel.numberOfLines = 0
        let unitPriceLabel = makeLabel(font: .systemFont(ofSize: 15), color: .secondaryLabel, tag: 103)
        let lineTotalLabel = makeLabel(font: .systemFont(ofSize: 18, weight: .bold), tag: 104)
        lineTotalLabel.textAlignment = .right
        lineTotalLabel.setContentHuggingPriority(.required, for: .horizontal)

        let topRow = UIStackView(arrangedSubviews: [titleLabel, lineTotalLabel])
        topRow.axis = .horizontal
        topRow.alignment = .top
        topRow.spacing = 12

        let labels = UIStackView(arrangedSubviews: [topRow, modifierLabel, unitPriceLabel])
        labels.axis = .vertical
        labels.spacing = 5

        [decreaseButton, increaseButton].forEach {
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 22
            $0.widthAnchor.constraint(equalToConstant: 44).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        increaseButton.setImage(UIImage(systemName: "plus"), for: .normal)
        increaseButton.tintColor = .secondaryLabel
        quantityLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        quantityLabel.textAlignment = .center
        quantityLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true
        activityIndicator.isHidden = true

        let spacer = UIView()
        let controls = UIStackView(arrangedSubviews: [spacer, activityIndicator, decreaseButton, quantityLabel, increaseButton])
        controls.axis = .horizontal
        controls.alignment = .center
        controls.spacing = 6

        let stack = UIStackView(arrangedSubviews: [labels, controls])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])

        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
    }

    func makeLabel(font: UIFont, color: UIColor = .label, tag: Int) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.tag = tag
        return label
    }

    @objc func decreaseTapped() {
        quantity == 1 ? onRemove?() : onDecrease?()
    }

    @objc func increaseTapped() {
        onIncrease?()
    }
}

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
