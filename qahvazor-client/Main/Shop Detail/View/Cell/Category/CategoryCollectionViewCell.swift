//
//  CategoryCollectionViewCell.swift
//  qahvazor-client
//
//  Created by iOS on 09/04/26.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        updateAppearance()
    }
    
    private func updateAppearance() {
        if isSelected {
            contentView.backgroundColor = .appColor(.mainColor)
            contentView.layer.borderColor = UIColor.appColor(.mainColor).cgColor
            titleLabel.textColor = .appColor(.white)
        } else {
            contentView.backgroundColor = .mainBackground
            contentView.layer.borderColor = UIColor.separator.cgColor
            titleLabel.textColor = .label
        }
    }
}
