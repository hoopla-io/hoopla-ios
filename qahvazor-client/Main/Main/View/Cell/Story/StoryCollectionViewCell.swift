//
//  StoryCollectionViewCell.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 16/05/26.
//

import UIKit

final class StoryCollectionViewCell: UICollectionViewCell {

    private enum Constants {
        static let cornerRadius: CGFloat = 20
        static let imageInset: CGFloat = 4
    }

    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor(.white)
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.appColor(.mainColor).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius - Constants.imageInset
        imageView.layer.cornerCurve = .continuous
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(storyImageView)

        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            storyImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: Constants.imageInset),
            storyImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor, constant: Constants.imageInset),
            storyImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: -Constants.imageInset),
            storyImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -Constants.imageInset)
        ])
    }

    func configure(with item: Stories) {
        accessibilityLabel = item.title
        imageContainerView.layer.borderColor = item.isSeen == true ? UIColor.clear.cgColor : UIColor.appColor(.mainColor).cgColor
        storyImageView.setImage(with: item.coverImageUrl, placeholder: .appImage(.placeholder))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        storyImageView.image = nil
        imageContainerView.layer.borderColor = UIColor.appColor(.mainColor).cgColor
    }
}
