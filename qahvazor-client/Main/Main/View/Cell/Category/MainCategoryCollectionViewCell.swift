//
//  MainCategoryCollectionViewCell.swift
//  qahvazor-client
//

import UIKit

final class MainCategoryCollectionViewCell: UICollectionViewCell {

    private enum Constants {
        static let height: CGFloat = 44
        static let imageSide: CGFloat = 28
        static let horizontalInset: CGFloat = 16
        static let imageSpacing: CGFloat = 10
        static let minimumWidth: CGFloat = 86
        static let titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    // MARK: - UI Elements
    let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
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
        contentView.backgroundColor = .dynamicWhite
        contentView.layer.cornerRadius = Constants.height / 2
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1

        contentView.addSubview(categoryImageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            categoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            categoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryImageView.widthAnchor.constraint(equalToConstant: Constants.imageSide),
            categoryImageView.heightAnchor.constraint(equalToConstant: Constants.imageSide),

            titleLabel.leadingAnchor.constraint(equalTo: categoryImageView.trailingAnchor, constant: Constants.imageSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        updateAppearance()
    }

    private func updateAppearance() {
        let borderColor = isSelected ? UIColor.appColor(.mainColor) : .clear
        let titleColor = isSelected ? UIColor.appColor(.mainColor) : UIColor.label

        UIView.animate(withDuration: 0.2) {
            self.contentView.layer.borderColor = borderColor.cgColor
            self.titleLabel.textColor = titleColor
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

    static func size(for category: Categories) -> CGSize {
        let title = category.name ?? ""
        let titleWidth = (title as NSString).size(withAttributes: [.font: Constants.titleFont]).width
        let width = Constants.horizontalInset * 2 + Constants.imageSide + Constants.imageSpacing + ceil(titleWidth)
        return CGSize(width: max(Constants.minimumWidth, width), height: Constants.height)
    }
}
