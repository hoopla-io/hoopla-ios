//
//  ProfileView.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import UIKit

final class ProfileView: CustomView {
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    let textField: UITextField = {
        let textField = CustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .secondarySystemBackground
        textField.text = "+998"
        textField.font = .systemFont(ofSize: 14)
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 12
        textField.layer.cornerCurve = .continuous
        return textField
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.appColor(.secondBackground)
        button.setTitle("continue".localized, for: .normal)
        button.setTitleColor(.systemGray2, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        return button
    }()

    let loginStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()

    let profileStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 18
        return stackView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " "
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let accounNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " "
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0 " + "som".localized
        label.font = .systemFont(ofSize: 32, weight: .regular)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.65
        return label
    }()

    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    let paymentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.cornerCurve = .continuous
        return view
    }()

    let giftCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.cornerCurve = .continuous
        return view
    }()

    let topUpButton = ProfileView.makePrimaryButton(titleKey: "topUp")

    let versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.isUserInteractionEnabled = true
        return label
    }()

    private(set) var mainButtons = [UIButton]()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()

    private let languageButton = ProfileView.makeMenuButton(
        titleKey: "languages",
        image: UIImage(systemName: "globe"),
        tag: 1
    )

//    private let activeDevicesButton = ProfileView.makeMenuButton(
//        titleKey: "activeDevices",
//        image: UIImage(systemName: "macbook.and.iphone"),
//        tag: 6
//    )

    private let supportButton = ProfileView.makeMenuButton(
        titleKey: "support",
        image: UIImage(systemName: "questionmark.app.fill"),
        tag: 4
    )

    private let privacyButton = ProfileView.makeMenuButton(
        titleKey: "privacyPolicy",
        image: UIImage(systemName: "doc.text.fill"),
        tag: 3
    )

    private let termsButton = ProfileView.makeMenuButton(
        titleKey: "termsOfUse",
        image: UIImage(systemName: "doc.text.fill"),
        tag: 2
    )

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

private extension ProfileView {
    func setupUI() {
        backgroundColor = .mainBackground

        addSubview(scrollView)
        addSubview(versionLabel)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStack)

        setupLoginStack()
        setupProfileStack()

        mainStack.addArrangedSubview(loginStack)
        mainStack.addArrangedSubview(profileStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -96),

            versionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setupLoginStack() {
        let logoImageView = UIImageView(image: UIImage(named: "logo"))
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        logoImageView.layer.cornerRadius = 10
        logoImageView.layer.cornerCurve = .continuous

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "signIn".localized
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)

        let formStack = UIStackView(arrangedSubviews: [textField, loginButton])
        formStack.translatesAutoresizingMaskIntoConstraints = false
        formStack.axis = .vertical
        formStack.distribution = .fillEqually
        formStack.spacing = 15

        loginStack.addArrangedSubview(logoImageView)
        loginStack.addArrangedSubview(titleLabel)
        loginStack.addArrangedSubview(formStack)

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),

            textField.heightAnchor.constraint(equalToConstant: 56),
            loginButton.heightAnchor.constraint(equalToConstant: 56),

            formStack.leadingAnchor.constraint(equalTo: loginStack.leadingAnchor),
            formStack.trailingAnchor.constraint(equalTo: loginStack.trailingAnchor)
        ])
    }

    func setupProfileStack() {
        let profileCardView = makeProfileCardView()
        let balanceCardsStack = UIStackView(arrangedSubviews: [giftCardView, paymentView])
        balanceCardsStack.translatesAutoresizingMaskIntoConstraints = false
        balanceCardsStack.axis = .horizontal
        balanceCardsStack.distribution = .fillEqually
        balanceCardsStack.spacing = 18

        setupGiftCard()
        setupPaymentCard()
        applyCardShadow(to: profileCardView)
        applyCardShadow(to: giftCardView)
        applyCardShadow(to: paymentView)

        profileStack.addArrangedSubview(profileCardView)
        profileStack.addArrangedSubview(balanceCardsStack)
        profileStack.addArrangedSubview(makeMenuButtonsStack())

        NSLayoutConstraint.activate([
            profileCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 112),
            balanceCardsStack.heightAnchor.constraint(equalToConstant: 210)
        ])

        profileStack.setCustomSpacing(20, after: profileCardView)
        profileStack.setCustomSpacing(30, after: balanceCardsStack)
    }

    func makeProfileCardView() -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 22
        cardView.layer.cornerCurve = .continuous

        let phoneTitleLabel = UILabel()
        phoneTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneTitleLabel.text = "phoneNumberProfile".localized
        phoneTitleLabel.font = .systemFont(ofSize: 14)
        phoneTitleLabel.textColor = .label

        let phoneStack = UIStackView(arrangedSubviews: [phoneTitleLabel, accounNumberLabel])
        phoneStack.translatesAutoresizingMaskIntoConstraints = false
        phoneStack.axis = .horizontal
        phoneStack.spacing = 4
        phoneStack.alignment = .firstBaseline

        let topStack = UIStackView(arrangedSubviews: [nameLabel, editButton])
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.axis = .horizontal
        topStack.alignment = .center
        topStack.spacing = 16

        let contentStack = UIStackView(arrangedSubviews: [topStack, phoneStack])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 14

        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 26),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -22),

            editButton.widthAnchor.constraint(equalToConstant: 34),
            editButton.heightAnchor.constraint(equalToConstant: 34)
        ])

        return cardView
    }

    func setupGiftCard() {
        let iconImageView = makeTintedImageView(image: UIImage(systemName: "giftcard.fill"), tintColor: UIColor.appColor(.mainColor))

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "giftCard".localized
        titleLabel.font = .systemFont(ofSize: 18, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        let titleStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal
        titleStack.spacing = 12
        titleStack.alignment = .top

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "giftCardDescription".localized
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0

        let activateButton = ProfileView.makePrimaryButton(titleKey: "activate")

        let contentStack = UIStackView(arrangedSubviews: [titleStack, descriptionLabel, activateButton])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 14

        giftCardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 38),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            contentStack.topAnchor.constraint(equalTo: giftCardView.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: giftCardView.leadingAnchor, constant: 18),
            contentStack.trailingAnchor.constraint(equalTo: giftCardView.trailingAnchor, constant: -18),
            contentStack.bottomAnchor.constraint(equalTo: giftCardView.bottomAnchor, constant: -18),

            activateButton.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    func setupPaymentCard() {
        let iconImageView = makeTintedImageView(image: UIImage(named: "payment") ?? UIImage(systemName: "creditcard"), tintColor: UIColor.appColor(.mainColor))

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "balance".localized
        titleLabel.font = .systemFont(ofSize: 18, weight: .regular)
        titleLabel.textColor = .label

        let titleStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal
        titleStack.spacing = 12
        titleStack.alignment = .center

        let contentStack = UIStackView(arrangedSubviews: [titleStack, balanceLabel, topUpButton])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18

        paymentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 38),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            contentStack.topAnchor.constraint(equalTo: paymentView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor, constant: 18),
            contentStack.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor, constant: -18),
            contentStack.bottomAnchor.constraint(equalTo: paymentView.bottomAnchor, constant: -18),

            topUpButton.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    func makeMenuButtonsStack() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            languageButton,
//            activeDevicesButton,
            supportButton,
            privacyButton,
            termsButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12

        mainButtons = [
            languageButton,
//            activeDevicesButton,
            supportButton,
            privacyButton,
            termsButton
        ]

        mainButtons.forEach {
            applyCardShadow(to: $0)
            $0.setRightImage(image: UIImage(systemName: "chevron.right") ?? UIImage(), height: 19, inset: 24)
        }

        return stackView
    }

    static func makePrimaryButton(titleKey: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.appColor(.mainColor)
        button.setTitle(titleKey.localized, for: .normal)
        button.setTitleColor(UIColor.appColor(.white), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.75
        button.layer.cornerRadius = 23
        button.layer.cornerCurve = .continuous
        return button
    }

    func makeTintedImageView(image: UIImage?, tintColor: UIColor) -> UIImageView {
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = tintColor
        return imageView
    }

    func applyCardShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.16
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.masksToBounds = false
    }

    static func makeMenuButton(
        titleKey: String,
        image: UIImage?,
        tag: Int
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = tag
        button.backgroundColor = .systemBackground
        button.contentHorizontalAlignment = .leading
        button.contentVerticalAlignment = .center
        button.tintColor = .label
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 0)
        button.setImage(image, for: .normal)
        button.setTitle(titleKey.localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 54)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
        return button
    }
}
