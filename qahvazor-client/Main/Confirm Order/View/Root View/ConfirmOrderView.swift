//
//  ConfirmOrderView.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/06/25.
//

import UIKit

final class ConfirmOrderView: CustomView {
    //MARK: - Outlets
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var drinkLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = .clear
            collectionView.showsVerticalScrollIndicator = false
            collectionView.register(
                UINib(nibName: ItemsCollectionViewCell.defaultReuseIdentifier, bundle: nil),
                forCellWithReuseIdentifier: ItemsCollectionViewCell.defaultReuseIdentifier
            )
            collectionView.register(
                ModifierGroupHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ModifierGroupHeaderView.defaultReuseIdentifier
            )

            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.estimatedItemSize = .zero
                layout.minimumLineSpacing = 10
                layout.minimumInteritemSpacing = 0
            }
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            configureTextView()
        }
    }
    @IBOutlet weak var priceButton: UIButton! {
        didSet {
            if #available(iOS 26.0, *) {
                var config: UIButton.Configuration
                config = .clearGlass()
                config.baseForegroundColor = .appColor(.white)
                config.cornerStyle = .large
                priceButton.configuration = config
            }
        }
    }
    
    private enum TextViewLayout {
        static let inset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

    private let textViewPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "addComment".localized
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 15)
        label.isUserInteractionEnabled = false
        return label
    }()
}

extension ConfirmOrderView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewPlaceholderVisibility()
    }
}

private extension ConfirmOrderView {
    func configureTextView() {
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.separator.withAlphaComponent(0.24).cgColor

        textView.delegate = self
        textView.textContainerInset = TextViewLayout.inset
        textView.textContainer.lineFragmentPadding = 0
        textView.addSubview(textViewPlaceholderLabel)

        NSLayoutConstraint.activate([
            textViewPlaceholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: TextViewLayout.inset.top),
            textViewPlaceholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: TextViewLayout.inset.left),
            textViewPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -TextViewLayout.inset.right)
        ])

        updateTextViewPlaceholderVisibility()
    }

    func updateTextViewPlaceholderVisibility() {
        textViewPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
}
