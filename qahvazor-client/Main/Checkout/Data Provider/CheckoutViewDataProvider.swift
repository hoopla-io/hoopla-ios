//
//  CheckoutViewDataProvider.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 27/06/26.
//

import UIKit

extension CheckoutViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedModifiers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CheckoutModifierCollectionViewCell.defaultReuseIdentifier,
            for: indexPath
        ) as? CheckoutModifierCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: selectedModifiers[indexPath.row])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let modifier = selectedModifiers[indexPath.row]
        let priceWidth: CGFloat = 100
        let spacing: CGFloat = 16
        let titleWidth = max(collectionView.bounds.width - priceWidth - spacing, 0)
        let title = modifier.modificationName ?? ""
        let titleHeight = title.boundingRect(
            with: CGSize(width: titleWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        ).height

        return CGSize(width: collectionView.bounds.width, height: max(22, ceil(titleHeight)))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }
}

final class CheckoutModifierCollectionViewCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    func configure(with modifier: Modification) {
        titleLabel.text = modifier.modificationName
        priceLabel.text = "+" + (modifier.modificationPrice ?? 0).formattedWithCurrency
    }
}

private extension CheckoutModifierCollectionViewCell {
    func configureView() {
        contentView.backgroundColor = .clear

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 0

        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .systemFont(ofSize: 16)
        priceLabel.textColor = .secondaryLabel
        priceLabel.textAlignment = .right
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -16),

            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
}
