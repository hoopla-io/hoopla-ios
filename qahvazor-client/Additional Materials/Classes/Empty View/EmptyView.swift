//
//  EmptyView.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit

enum Empty {
    case all
    case search
    case activeSubscription
}

final class EmptyView: CustomView {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Attributes
    internal var type: Empty? {
        didSet {
            guard let type = type else { return }
            switch type {
            case .all:
                imageView.image = UIImage.appImage(.empty)
                titleLabel.text = "emptyDetail".localized
            case .search:
                imageView.image = UIImage.appImage(.empty)
                titleLabel.text = "emptySearch".localized
            case .activeSubscription:
                imageView.image = UIImage.appImage(.empty)
                titleLabel.text = "notActivSubs".localized
            }
        }
    }
}

