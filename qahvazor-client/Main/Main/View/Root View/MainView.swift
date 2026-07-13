//
//  MainView.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import SkeletonView

final class MainView: CustomView {
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let storiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isHidden = true
        collectionView.register(
            StoryCollectionViewCell.self,
            forCellWithReuseIdentifier: StoryCollectionViewCell.defaultReuseIdentifier
        )
        return collectionView
    }()

    let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            MainCategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: MainCategoryCollectionViewCell.defaultReuseIdentifier
        )
        return collectionView
    }()

    let shopCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isSkeletonable = true
        collectionView.register(
            UINib(nibName: CompanyCollectionViewCell.defaultReuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier
        )
        return collectionView
    }()

    private(set) lazy var collectionViewHeight = shopCollectionView.heightAnchor.constraint(equalToConstant: 1_000)

    let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appColor(.mainColor)
        button.tintColor = .appColor(.white)
        button.setTitle("camera".localized, for: .normal)
        button.setTitleColor(.appColor(.white), for: .normal)
        button.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 30)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        button.layer.cornerRadius = 24
        button.layer.cornerCurve = .continuous

        if #available(iOS 26.0, *) {
            var config = UIButton.Configuration.clearGlass()
            config.title = "camera".localized
            config.image = UIImage(systemName: "camera.viewfinder")
            config.baseForegroundColor = .appColor(.white)
            config.cornerStyle = .capsule
            config.imagePadding = 8
            button.configuration = config
        }
        return button
    }()

    let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 24, weight: .bold),
            forImageIn: .normal
        )
        return button
    }()

    let notificationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 24, weight: .bold),
            forImageIn: .normal
        )
        return button
    }()

    private let shopsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "coffeeShops".localized
        label.font = .systemFont(ofSize: 20, weight: .semibold)
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
}

private extension MainView {
    func setupUI() {
        let shopsTitleContainer = UIView()
        shopsTitleContainer.translatesAutoresizingMaskIntoConstraints = false
        shopsTitleContainer.addSubview(shopsTitleLabel)

        let contentStackView = UIStackView(arrangedSubviews: [
            storiesCollectionView,
            categoryCollectionView,
            shopsTitleContainer,
            shopCollectionView
        ])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 10

        addSubview(scrollView)
        addSubview(cameraButton)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            storiesCollectionView.heightAnchor.constraint(equalToConstant: 86),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 44),
            shopsTitleContainer.heightAnchor.constraint(equalToConstant: 24),
            shopsTitleLabel.leadingAnchor.constraint(equalTo: shopsTitleContainer.leadingAnchor, constant: 16),
            shopsTitleLabel.centerYAnchor.constraint(equalTo: shopsTitleContainer.centerYAnchor),
            shopsTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: shopsTitleContainer.trailingAnchor, constant: -16),
            collectionViewHeight,

            cameraButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
            cameraButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
