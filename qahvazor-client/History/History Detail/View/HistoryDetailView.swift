//
//  HistoryDetailView.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//

import UIKit

final class HistoryDetailView: CustomView {
    let getOrderButton = HistoryDetailView.makeButton(title: "getTheOrder".localized, style: .primary)
    let getButton = HistoryDetailView.makeButton(title: "getReceipt".localized, style: .secondary)
    let cancelledButton = HistoryDetailView.makeButton(title: "cancelOrder".localized, style: .destructive)
    let continuePaymentButton = HistoryDetailView.makeButton(title: "continuePayment".localized, style: .primary)

    var onRate: (() -> Void)?

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 22
        return stack
    }()

    private let orderCardView = HistoryDetailView.cardView(radius: 22)

    private let drinksStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let drinksValueLabel = HistoryDetailView.valueLabel()
    private let cashbackUsedValueLabel = HistoryDetailView.valueLabel()
    private let totalPaidValueLabel = HistoryDetailView.valueLabel(fontSize: 20, weight: .semibold)
    private let cashbackEarnedValueLabel = HistoryDetailView.valueLabel(color: .appColor(.green))

    private let cashbackUsedRow = UIStackView()
    private let cashbackEarnedRow = UIStackView()

    private let ratingCardView = HistoryDetailView.cardView(radius: 14)
    private let ratingsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let actionContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appColor(.mainBackground)
        return view
    }()

    private let actionStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(with order: OrderHistory) {
        let drinks = displayDrinks(from: order)
        configureDrinks(drinks)
        configureSummary(order: order, drinks: drinks)
        configureRatings(order: order, drinks: drinks)
        configureActions(order: order)
    }
}

private extension HistoryDetailView {
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }

    struct DisplayDrink {
        let name: String
        let imageURL: String?
        var quantity: Int
        var totalPrice: Double
        var modifiers: [OrderHistoryItem]
    }

    static func cardView(radius: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = radius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }

    static func valueLabel(
        fontSize: CGFloat = 16,
        weight: UIFont.Weight = .regular,
        color: UIColor = .secondaryLabel
    ) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.textColor = color
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }

    static func makeButton(title: String, style: ButtonStyle) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }

        switch style {
        case .primary:
            configuration.baseBackgroundColor = .appColor(.mainColor)
            configuration.baseForegroundColor = .appColor(.white)
        case .secondary:
            configuration.baseBackgroundColor = .systemBackground
            configuration.baseForegroundColor = .appColor(.mainColor)
            configuration.background.strokeColor = .appColor(.mainColor)
            configuration.background.strokeWidth = 1
        case .destructive:
            configuration.baseBackgroundColor = UIColor.appColor(.red).withAlphaComponent(0.08)
            configuration.baseForegroundColor = .appColor(.red)
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
        return button
    }

    func setupUI() {
        backgroundColor = .appColor(.mainBackground)

        orderCardView.addSubview(drinksStack)
        NSLayoutConstraint.activate([
            drinksStack.topAnchor.constraint(equalTo: orderCardView.topAnchor),
            drinksStack.leadingAnchor.constraint(equalTo: orderCardView.leadingAnchor),
            drinksStack.trailingAnchor.constraint(equalTo: orderCardView.trailingAnchor),
            drinksStack.bottomAnchor.constraint(equalTo: orderCardView.bottomAnchor)
        ])

        let summaryStack = makeSummaryStack()
        let ratingTitle = UILabel()
        ratingTitle.text = "howWasYourDrink".localized
        ratingTitle.font = .systemFont(ofSize: 15, weight: .regular)
        ratingTitle.textColor = .secondaryLabel

        let ratingContentStack = UIStackView(arrangedSubviews: [ratingTitle, ratingsStack])
        ratingContentStack.translatesAutoresizingMaskIntoConstraints = false
        ratingContentStack.axis = .vertical
        ratingContentStack.spacing = 8
        ratingCardView.addSubview(ratingContentStack)
        NSLayoutConstraint.activate([
            ratingContentStack.topAnchor.constraint(equalTo: ratingCardView.topAnchor, constant: 16),
            ratingContentStack.leadingAnchor.constraint(equalTo: ratingCardView.leadingAnchor, constant: 14),
            ratingContentStack.trailingAnchor.constraint(equalTo: ratingCardView.trailingAnchor, constant: -14),
            ratingContentStack.bottomAnchor.constraint(equalTo: ratingCardView.bottomAnchor, constant: -8)
        ])

        contentStack.addArrangedSubview(orderCardView)
        contentStack.addArrangedSubview(summaryStack)
        contentStack.addArrangedSubview(ratingCardView)

        [getButton, getOrderButton, continuePaymentButton, cancelledButton].forEach {
            actionStack.addArrangedSubview($0)
        }
        actionContainerView.addSubview(actionStack)

        addSubview(scrollView)
        addSubview(actionContainerView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            actionContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionContainerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            actionStack.topAnchor.constraint(equalTo: actionContainerView.topAnchor, constant: 12),
            actionStack.leadingAnchor.constraint(equalTo: actionContainerView.leadingAnchor, constant: 20),
            actionStack.trailingAnchor.constraint(equalTo: actionContainerView.trailingAnchor, constant: -20),
            actionStack.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor, constant: -8),

            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: actionContainerView.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    func makeSummaryStack() -> UIStackView {
        let drinksRow = makeSummaryRow(title: "drinksSummary".localized, valueLabel: drinksValueLabel)
        cashbackUsedRow.axis = .horizontal
        cashbackUsedRow.alignment = .firstBaseline
        cashbackUsedRow.addArrangedSubview(summaryTitleLabel("cashbackSummary".localized))
        cashbackUsedRow.addArrangedSubview(cashbackUsedValueLabel)

        let totalPaidRow = makeSummaryRow(title: "totalPaid".localized, valueLabel: totalPaidValueLabel, emphasized: true)

        cashbackEarnedRow.axis = .horizontal
        cashbackEarnedRow.alignment = .firstBaseline
        let earnedTitle = summaryTitleLabel("earnedCashbackSummary".localized)
        earnedTitle.textColor = .appColor(.green)
        cashbackEarnedRow.addArrangedSubview(earnedTitle)
        cashbackEarnedRow.addArrangedSubview(cashbackEarnedValueLabel)

        let stack = UIStackView(arrangedSubviews: [drinksRow, cashbackUsedRow, totalPaidRow, cashbackEarnedRow])
        stack.axis = .vertical
        stack.spacing = 7
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return stack
    }

    func makeSummaryRow(title: String, valueLabel: UILabel, emphasized: Bool = false) -> UIStackView {
        let titleLabel = summaryTitleLabel(title)
        if emphasized {
            titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
            titleLabel.textColor = .label
        }
        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 10
        return row
    }

    func summaryTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }

    func displayDrinks(from order: OrderHistory) -> [DisplayDrink] {
        let items = order.items ?? []
        let productItems = items.filter(\.isProduct)

        if !productItems.isEmpty {
            return productItems.map { product in
                let modifiers = items.filter { item in
                    guard !item.isProduct else { return false }
                    if let productId = product.id {
                        return item.parentItemId == productId
                            || (productItems.count == 1 && item.parentItemId == nil)
                    }
                    return productItems.count == 1
                }
                let lineTotal = (product.price ?? 0) + modifiers.reduce(0) { partialResult, item in
                    partialResult + (item.price ?? 0)
                }

                return DisplayDrink(
                    name: product.displayName,
                    imageURL: product.imageUrl ?? (productItems.count == 1 ? order.fallbackImageURL : nil),
                    quantity: max(product.quantity ?? 1, 1),
                    totalPrice: lineTotal,
                    modifiers: modifiers
                )
            }
        }

        guard let drinks = order.drinks, !drinks.isEmpty else {
            return [DisplayDrink(
                name: order.fallbackProductName,
                imageURL: order.fallbackImageURL,
                quantity: 1,
                totalPrice: order.productPrice ?? 0,
                modifiers: items
            )]
        }

        var result: [DisplayDrink] = []
        drinks.forEach { drink in
            let rawName = drink.drinkName?.trimmingCharacters(in: .whitespacesAndNewlines)
            let name = (rawName?.isEmpty == false ? rawName : nil) ?? "drink".localized
            if let index = result.firstIndex(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                result[index].quantity += 1
                result[index].totalPrice += drink.drinkPrice ?? 0
            } else {
                result.append(DisplayDrink(
                    name: name,
                    imageURL: drink.drinkImageUrl,
                    quantity: 1,
                    totalPrice: drink.drinkPrice ?? 0,
                    modifiers: []
                ))
            }
        }
        if result.count == 1 {
            result[0].modifiers = items
        }
        if result.reduce(0, { $0 + $1.totalPrice }) <= 0,
           let firstIndex = result.indices.first,
           let productPrice = order.productPrice {
            result[firstIndex].totalPrice = productPrice
        }
        return result
    }

    func configureDrinks(_ drinks: [DisplayDrink]) {
        drinksStack.arrangedSubviews.forEach {
            drinksStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, drink) in drinks.enumerated() {
            if index > 0 { drinksStack.addArrangedSubview(makeDivider()) }
            let detailView = HistoryDetailDrinkView()
            detailView.configure(
                name: drink.name,
                imageURL: drink.imageURL,
                quantity: drink.quantity,
                totalPrice: drink.totalPrice,
                modifiers: drink.modifiers
            )
            drinksStack.addArrangedSubview(detailView)
        }
    }

    func configureSummary(order: OrderHistory, drinks: [DisplayDrink]) {
        let groupedTotal = drinks.reduce(0) { $0 + $1.totalPrice }
        let drinksTotal = order.productPrice ?? groupedTotal
        let cashbackUsed = order.cashbackUsed ?? 0
        let paidTotal = max(drinksTotal - cashbackUsed, 0)
        let cashbackEarned = order.cashbackEarned ?? 0

        drinksValueLabel.text = "+\(drinksTotal.formattedWithCurrency)"
        cashbackUsedValueLabel.text = "-\(cashbackUsed.formattedWithCurrency)"
        totalPaidValueLabel.text = "+\(paidTotal.formattedWithCurrency)"
        cashbackEarnedValueLabel.text = "+\(cashbackEarned.formattedWithCurrency)"
        cashbackUsedRow.isHidden = cashbackUsed <= 0
        cashbackEarnedRow.isHidden = cashbackEarned <= 0
    }

    func configureRatings(order: OrderHistory, drinks: [DisplayDrink]) {
        ratingsStack.arrangedSubviews.forEach {
            ratingsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let isCompleted = normalizedStatus(order.orderStatus) == .completed
        ratingCardView.isHidden = !isCompleted || order.hasFeedback == true
        guard !ratingCardView.isHidden else { return }

        for (index, drink) in drinks.enumerated() {
            if index > 0 { ratingsStack.addArrangedSubview(makeDivider()) }
            let row = HistoryRatingRow()
            row.configure(title: drink.quantity > 1 ? "\(drink.name) x\(drink.quantity)" : drink.name)
            row.onTap = { [weak self] in self?.onRate?() }
            ratingsStack.addArrangedSubview(row)
        }
    }

    func configureActions(order: OrderHistory) {
        let status = normalizedStatus(order.orderStatus)
        getButton.isHidden = order.fiscalLink == nil
        continuePaymentButton.isHidden = status != .pendingPayment || order.checkoutUrl == nil
        cancelledButton.isHidden = status != .pendingPayment
        getOrderButton.isHidden = status == .cancelled || status == .pendingPayment
        actionContainerView.isHidden = [getButton, getOrderButton, continuePaymentButton, cancelledButton].allSatisfy(\.isHidden)
    }

    enum DetailStatus: Equatable {
        case completed
        case cancelled
        case pendingPayment
        case other
    }

    func normalizedStatus(_ status: String?) -> DetailStatus {
        switch status?.lowercased() {
        case "ordered", OrderStatus.completed.rawValue:
            return .completed
        case "canceled", OrderStatus.cancelled.rawValue:
            return .cancelled
        case OrderStatus.pending_payment.rawValue:
            return .pendingPayment
        default:
            return .other
        }
    }

    func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor.separator.withAlphaComponent(0.5)
        divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return divider
    }
}

private final class HistoryDetailDrinkView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let modifiersStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .appColor(.mainColor)
        label.textAlignment = .right
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

    func configure(
        name: String,
        imageURL: String?,
        quantity: Int,
        totalPrice: Double,
        modifiers: [OrderHistoryItem]
    ) {
        let title = NSMutableAttributedString(
            string: name,
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )
        if quantity > 1 {
            title.append(NSAttributedString(
                string: " x\(quantity)",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                    .foregroundColor: UIColor.appColor(.mainColor)
                ]
            ))
        }
        titleLabel.attributedText = title
        imageView.setImage(with: imageURL, placeholder: .appImage(.drinkPlaceholder))

        modifiersStack.arrangedSubviews.forEach {
            modifiersStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        modifiers.compactMap { item -> (String, Double)? in
            let name = item.displayName
            guard name != "drink".localized else { return nil }
            let quantity = max(item.quantity ?? 1, 1)
            let title = quantity > 1 ? "\(name) x\(quantity)" : name
            return (title, item.price ?? 0)
        }.forEach { modifiersStack.addArrangedSubview(makeModifierRow(title: $0.0, price: $0.1)) }

        totalLabel.text = totalPrice.formattedWithCurrency
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        let detailsStack = UIStackView(arrangedSubviews: [titleLabel, modifiersStack, totalLabel])
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        detailsStack.axis = .vertical
        detailsStack.spacing = 8

        addSubview(imageView)
        addSubview(detailsStack)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 28),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            imageView.widthAnchor.constraint(equalToConstant: 62),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -28),

            detailsStack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            detailsStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            detailsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func makeModifierRow(title: String, price: Double) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 0

        let priceLabel = UILabel()
        priceLabel.text = price > 0 ? "+\(price.formattedWithCurrency)" : nil
        priceLabel.font = .systemFont(ofSize: 14, weight: .regular)
        priceLabel.textColor = .secondaryLabel
        priceLabel.textAlignment = .right
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 8
        return row
    }
}

private final class HistoryRatingRow: UIView {
    var onTap: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
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

    func configure(title: String) {
        titleLabel.text = title
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        let starsStack = UIStackView()
        starsStack.translatesAutoresizingMaskIntoConstraints = false
        starsStack.axis = .horizontal
        starsStack.spacing = 7

        for index in 1...5 {
            let button = UIButton(type: .system)
            button.tag = index
            button.tintColor = .systemGray4
            button.setImage(UIImage(systemName: "star.fill"), for: .normal)
            button.setPreferredSymbolConfiguration(
                UIImage.SymbolConfiguration(pointSize: 20, weight: .regular),
                forImageIn: .normal
            )
            button.addTarget(self, action: #selector(starTapped), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 25).isActive = true
            starsStack.addArrangedSubview(button)
        }

        addSubview(titleLabel)
        addSubview(starsStack)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),

            starsStack.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            starsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            starsStack.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 10)
        ])
    }

    @objc private func starTapped(_ sender: UIButton) {
        onTap?()
    }
}

private extension OrderHistoryItem {
    var isProduct: Bool {
        itemType?.caseInsensitiveCompare("product") == .orderedSame
    }

    var displayName: String {
        let value = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (value?.isEmpty == false ? value : nil) ?? "drink".localized
    }
}

private extension OrderHistory {
    var fallbackProductName: String {
        let value = productName ?? drinkName
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmedValue?.isEmpty == false ? trimmedValue : nil) ?? "drink".localized
    }

    var fallbackImageURL: String? {
        productImageUrl ?? drinkImageUrl ?? drinkImage
    }
}
