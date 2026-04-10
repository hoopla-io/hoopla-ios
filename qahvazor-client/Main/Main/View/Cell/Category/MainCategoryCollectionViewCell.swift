//
//  MainCategoryCollectionViewCell.swift
//  qahvazor-client
//

import UIKit

final class MainCategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Elements
    private let imageContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(categoryImageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageContainerView.widthAnchor.constraint(equalToConstant: 64),
            imageContainerView.heightAnchor.constraint(equalToConstant: 64),

            categoryImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            categoryImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            categoryImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            categoryImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        updateAppearance()
    }

    private func updateAppearance() {
        if isSelected {
            UIView.animate(withDuration: 0.25) {
                self.imageContainerView.layer.borderColor = UIColor.appColor(.mainColor).cgColor
                self.titleLabel.textColor = .appColor(.mainColor)
            }
        } else {
            imageContainerView.layer.borderColor = UIColor.clear.cgColor
            titleLabel.textColor = .label
        }
    }

    // MARK: - Configure
    func configure(with category: Categories) {
        titleLabel.text = category.name
        categoryImageView.setImage(with: category.imageUrl, placeholder: .appImage(.placeholder))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryImageView.image = nil
        titleLabel.text = nil
    }
}
