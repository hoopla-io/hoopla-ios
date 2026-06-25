//
//  ConfirmOrderView.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/06/25.
//

import UIKit

final class ConfirmOrderView: CustomView {
    //MARK: - Outlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var drinkSizeStackView: UIStackView! {
        didSet {
            drinkSizeStackView.isHidden = true
        }
    }
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var drinkLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sugarStackView: UIStackView! {
        didSet {
            sugarStackView.isHidden = true
        }
    }
    @IBOutlet weak var sugarSegmentControl: UISegmentedControl!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var milkCollectionView: UICollectionView! {
        didSet {
            milkCollectionView.register(UINib(nibName: ItemsCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ItemsCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var syrupCollectionView: UICollectionView! {
        didSet {
            syrupCollectionView.register(UINib(nibName: ItemsCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ItemsCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var milkCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var syrupCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var milkStackView: UIStackView! {
        didSet {
            milkStackView.isHidden = true
        }
    }
    @IBOutlet weak var syrupStackView: UIStackView! {
        didSet {
            syrupStackView.isHidden = true
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
