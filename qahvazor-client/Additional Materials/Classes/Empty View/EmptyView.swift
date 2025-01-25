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
    case history
}

final class EmptyView: CustomView {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Attributes
    internal var type: Empty? {
        didSet {
            guard let type = type else { return }
            imageView.image = UIImage.appImage(.empty)
            switch type {
            case .all:
                titleLabel.text = "emptyDetail".localized
            case .search:
                titleLabel.text = "emptySearch".localized
            case .activeSubscription:
                titleLabel.text = "notActivSubs".localized
            case .history:
                titleLabel.text = "emptyHistory".localized
            }
        }
    }
}

