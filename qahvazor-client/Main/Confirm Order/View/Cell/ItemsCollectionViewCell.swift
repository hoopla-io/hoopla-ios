//
//  ItemsCollectionViewCell.swift
//  itv-new
//
//  Created Admin NBU on 03/12/21.

import UIKit

class ItemsCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFit
        }
    }

    private var isOptionSelected = false
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureAppearance()
        updateSelectionState()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        priceLabel.text = nil
        priceLabel.isHidden = false
        setOptionSelected(false)
    }

    func configure(with item: Modification, selected: Bool) {
        titleLabel.text = item.modificationName

        let price = item.modificationPrice ?? 0
        priceLabel.isHidden = price <= 0
        priceLabel.text = price > 0 ? "+\(price.formattedWithSeparator) UZS" : nil

        setOptionSelected(selected)
    }

    func setOptionSelected(_ selected: Bool) {
        isOptionSelected = selected
        updateSelectionState()
    }
}

private extension ItemsCollectionViewCell {
    func configureAppearance() {
        clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 14
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.withAlphaComponent(0.24).cgColor

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        priceLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        priceLabel.textColor = .label
    }

    func updateSelectionState() {
        let imageName = isOptionSelected ? "checkmark.circle.fill" : "circle"
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        imageView.image = UIImage(systemName: imageName, withConfiguration: configuration)
        imageView.tintColor = isOptionSelected ? .appColor(.mainColor) : .systemGray3
    }
}
