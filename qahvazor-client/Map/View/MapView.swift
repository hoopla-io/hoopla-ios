//
//  MapView.swift
//  qahvazor-client
//
//  Created by Husan on 31/08/26.
//

import UIKit
import MapKit

final class ShopAnnotation: NSObject, MKAnnotation {
    let shop: Shop
    let coordinate: CLLocationCoordinate2D

    var title: String? {
        shop.name
    }

    var subtitle: String? {
        shop.distance?.formatDistance()
    }

    init(shop: Shop) {
        self.shop = shop
        self.coordinate = CLLocationCoordinate2D(latitude: shop.location?.lat ?? 0, longitude: shop.location?.lng ?? 0)
        super.init()
    }
}

final class ShopAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "ShopAnnotationView"

    private enum Layout {
        static let viewSize = CGSize(width: 44, height: 52)
        static let logoSize = CGSize(width: 36, height: 36)
        static let pointerSize = CGSize(width: 14, height: 14)
        static let logoInset: CGFloat = 4
    }

    private let containerView = UIView()
    private let pointerView = UIView()
    private let imageView = UIImageView()

    private static let placeholderImage = UIImage(named: "placeHolder") ?? UIImage(named: "placeholder") ?? UIImage()

    override var annotation: MKAnnotation? {
        didSet {
            configure()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        configure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = Self.placeholderImage
        setSelectionAppearance(isSelected: false, animated: false)
    }

    private func setupView() {
        bounds = CGRect(origin: .zero, size: Layout.viewSize)
        centerOffset = CGPoint(x: 0, y: -Layout.viewSize.height / 2)
        calloutOffset = CGPoint(x: 0, y: -4)

        pointerView.frame = CGRect(
            x: (Layout.viewSize.width - Layout.pointerSize.width) / 2,
            y: Layout.viewSize.height - Layout.pointerSize.height - 5,
            width: Layout.pointerSize.width,
            height: Layout.pointerSize.height
        )
        pointerView.backgroundColor = .systemBackground
        pointerView.transform = CGAffineTransform(rotationAngle: .pi / 4)

        containerView.frame = CGRect(x: 0, y: 0, width: Layout.viewSize.width, height: Layout.viewSize.width)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = Layout.viewSize.width / 2
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.systemBackground.cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.18
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)

        imageView.frame = CGRect(
            x: Layout.logoInset,
            y: Layout.logoInset,
            width: Layout.logoSize.width,
            height: Layout.logoSize.height
        )
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.logoSize.width / 2
        imageView.image = Self.placeholderImage

        containerView.addSubview(imageView)
        addSubview(pointerView)
        addSubview(containerView)
    }

    private func configure() {
        guard let shop = (annotation as? ShopAnnotation)?.shop else { return }

        guard let logoUrl = shop.logoUrl, let url = URL(string: logoUrl) else {
            imageView.image = Self.placeholderImage
            return
        }

        imageView.sd_setImage(with: url, placeholderImage: Self.placeholderImage)
    }

    func setSelectionAppearance(isSelected: Bool, animated: Bool) {
        let changes = {
            self.transform = isSelected ? CGAffineTransform(scaleX: 1.24, y: 1.24) : .identity
            self.alpha = 1
            self.containerView.layer.borderWidth = isSelected ? 3 : 2
            self.containerView.layer.borderColor = isSelected
                ? UIColor.appColor(.mainColor).cgColor
                : UIColor.systemBackground.cgColor
            self.containerView.layer.shadowOpacity = isSelected ? 0.34 : 0.18
            self.containerView.layer.shadowRadius = isSelected ? 8 : 5
            self.pointerView.backgroundColor = isSelected ? .appColor(.mainColor) : .systemBackground
            self.layer.zPosition = isSelected ? 1 : 0
        }

        guard animated else {
            changes()
            return
        }

        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut, .beginFromCurrentState],
            animations: changes
        )
    }
}

final class ShopPreviewView: UIView {
    private enum Layout {
        static let cornerRadius: CGFloat = 22
        static let contentInset: CGFloat = 14
        static let imageSize: CGFloat = 72
        static let buttonHeight: CGFloat = 44
    }

    var onClose: (() -> Void)?
    var onOrder: (() -> Void)?

    private let shopImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let distanceIconView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let imageView = UIImageView(image: UIImage(systemName: "mappin", withConfiguration: configuration))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let statusContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
        button.tintColor = .secondaryLabel
        button.accessibilityLabel = "close".localized
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()

    private lazy var orderButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appColor(.mainColor)
        button.setTitle("toOrder".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 13
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(orderTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        layer.shadowColor = UIColor.black.cgColor
    }

    func configure(with shop: Shop) {
        let imageUrl = [shop.pictureUrl, shop.logoUrl]
            .compactMap { $0 }
            .first { !$0.isEmpty }
        shopImageView.setImage(with: imageUrl, placeholder: .appImage(.placeholder))
        titleLabel.text = shop.name

        if let distance = shop.distance, distance > 0 {
            distanceLabel.text = distance.formatDistance()
            distanceIconView.isHidden = false
        } else {
            distanceLabel.text = nil
            distanceIconView.isHidden = true
        }

        configureStatus(for: shop)

        let canOrder = shop.canAcceptOrders != false && shop.open != false
        orderButton.isEnabled = canOrder
        orderButton.alpha = canOrder ? 1 : 0.42
    }
}

extension ShopPreviewView {
    func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = Layout.cornerRadius
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 6)

        let distanceStack = UIStackView(arrangedSubviews: [distanceIconView, distanceLabel])
        distanceStack.axis = .horizontal
        distanceStack.alignment = .center
        distanceStack.spacing = 5

        let detailsStack = UIStackView(arrangedSubviews: [titleLabel, distanceStack, statusContainerView])
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        detailsStack.axis = .vertical
        detailsStack.alignment = .leading
        detailsStack.spacing = 5

        addSubview(shopImageView)
        addSubview(detailsStack)
        addSubview(closeButton)
        addSubview(orderButton)
        statusContainerView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            shopImageView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.contentInset),
            shopImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentInset),
            shopImageView.widthAnchor.constraint(equalToConstant: Layout.imageSize),
            shopImageView.heightAnchor.constraint(equalToConstant: Layout.imageSize),

            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            detailsStack.leadingAnchor.constraint(equalTo: shopImageView.trailingAnchor, constant: 12),
            detailsStack.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -4),
            detailsStack.centerYAnchor.constraint(equalTo: shopImageView.centerYAnchor),

            distanceIconView.widthAnchor.constraint(equalToConstant: 13),
            distanceIconView.heightAnchor.constraint(equalToConstant: 15),

            statusLabel.topAnchor.constraint(equalTo: statusContainerView.topAnchor, constant: 5),
            statusLabel.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor, constant: 9),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor, constant: -9),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainerView.bottomAnchor, constant: -5),

            orderButton.topAnchor.constraint(equalTo: shopImageView.bottomAnchor, constant: 12),
            orderButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentInset),
            orderButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.contentInset),
            orderButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.contentInset),
            orderButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ])
    }

    func configureStatus(for shop: Shop) {
        let color: UIColor
        let text: String

        if shop.canAcceptOrders == false {
            color = .appColor(.red)
            text = "notAcceptingOrders".localized
        } else if shop.open == false {
            color = .appColor(.red)
            text = "shopClosed".localized
        } else {
            color = .appColor(.green)
            text = "shopOpen".localized
        }

        statusLabel.text = text
        statusLabel.textColor = color
        statusContainerView.backgroundColor = color.withAlphaComponent(0.12)
    }

    @objc func closeTapped() {
        onClose?()
    }

    @objc func orderTapped() {
        onOrder?()
    }
}
