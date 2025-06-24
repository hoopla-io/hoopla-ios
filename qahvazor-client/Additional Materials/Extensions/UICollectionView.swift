//
//  UICollectionView.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import DeviceKit
import SkeletonView

protocol ItemCount {
    var padLandscape: Int { get set }
    var padPortrait:  Int { get set }
    var phone:        Int { get set }
}

enum ItemType {
    case company
    case shops
    case subscription
    case payment
    case coffeeCard
}

struct ItemCountCompany: ItemCount {
    var padLandscape = 3
    var padPortrait  = 2
    var phone        = 1
}

struct ItemCountShops: ItemCount {
    var padLandscape = 3
    var padPortrait  = 2
    var phone        = 1
}

struct ItemCountPayment: ItemCount {
    var padLandscape = 5
    var padPortrait  = 3
    var phone        = 2
}

struct ItemCountCoffeeCard: ItemCount {
    var padLandscape = 5
    var padPortrait  = 3
    var phone        = 2
}

enum ItemRatio: CGFloat {
    case company    = 0.71
    case shops      = 0.5
    case coffee     = 1.0
    case photo      = 0.56
    case subscription = 0.8
    case coffeeCard = 1.43
}

enum ItemSpacing: CGFloat {
    case standard = 16.0
    case custom   = 10.0
    case card     = 12.0
    case zero     = 0.0
}

enum ItemAdditionalHeight: CGFloat {
    case zero = 0
}

enum ItemLayout {
    case horizontal
    case vertical
}

extension UICollectionView {
    func itemSize(type: ItemType, layout: ItemLayout = .vertical) -> CGSize {
        switch type {
        case .company:
            return itemSize(itemType: .company, layout: layout, ratio: .company, spacing: .standard, additionalHeight: .zero)
        case .shops:
            return itemSize(itemType: .shops, layout: layout, ratio: .shops, spacing: .standard, additionalHeight: .zero)
        case .subscription:
            return itemSize(itemType: .company, layout: layout, ratio: .subscription, spacing: .standard, additionalHeight: .zero)
        case .payment:
            return itemSize(itemType: .payment, layout: layout, ratio: .coffee, spacing: .custom, additionalHeight: .zero)
        case .coffeeCard:
            return itemSize(itemType: .coffeeCard, layout: layout, ratio: .coffeeCard, spacing: .card, additionalHeight: .zero)
        default:
            return CGSize.zero
        }
    }
                    
    func numberInRow(type: ItemType) -> Int {
        switch type {
        case .company:
            return numberInRow(type: ItemCountCompany())
        case .shops:
            return numberInRow(type: ItemCountShops())
        case .subscription:
            return numberInRow(type: ItemCountCompany())
        case .payment:
            return numberInRow(type: ItemCountPayment())
        case .coffeeCard:
            return numberInRow(type: ItemCountCoffeeCard())
        }
    }
    
    func itemSize(itemType: ItemType, layout: ItemLayout, ratio: ItemRatio, spacing: ItemSpacing, additionalHeight: ItemAdditionalHeight) -> CGSize {
        let numberInRow = self.numberInRow(type: itemType)
        let ratio = ratio.rawValue
        let spacing = spacing.rawValue
        let additionalHeight = additionalHeight.rawValue
        var additionalWidth = 0.0
        switch layout {
        case .horizontal:
            additionalWidth = ItemSpacing.standard.rawValue * 2 + ItemSpacing.custom.rawValue * CGFloat(numberInRow - 1)
        case .vertical:
            additionalWidth = spacing * CGFloat(numberInRow + 1)
        }
        let width = (UIScreen.main.bounds.width - additionalWidth) / CGFloat(numberInRow)
        let height = width*ratio + additionalHeight
        return CGSize(width: width, height: height)
    }
    
    func itemSize(additionalHeight: CGFloat, additionalSpace: CGFloat? = nil, firstText: String? = nil, firstFont: UIFont? = nil, secondAdditionalHeight: CGFloat = 0, secondText: String? = nil, secondFont: UIFont? = nil, ratio: CGFloat? = nil) -> CGSize {
        let numberInRow = self.numberInRow(type: .company)
        let spacing = ItemSpacing.standard.rawValue
        let additionalHeight = additionalHeight
        let additionalWidth = spacing * CGFloat(numberInRow + 1)
        let width = (UIScreen.main.bounds.width - additionalWidth) / CGFloat(numberInRow)
        
        guard let firstText = firstText , let firstFont = firstFont, let additionalSpace = additionalSpace else {
            let height = CGFloat(additionalHeight)
            return CGSize(width: width, height: height)
        }
        
        let firstHeight = firstText.height(withConstrainedWidth: width - additionalSpace, font: firstFont)
        
        guard let secondText = secondText , let secondFont = secondFont else {
            let height = CGFloat(additionalHeight) + firstHeight
            return CGSize(width: width, height: height)
        }
        
        let secondHeight = secondText.height(withConstrainedWidth: width - additionalSpace, font: secondFont) + secondAdditionalHeight
        
        guard let ratio = ratio else {
            let height = CGFloat(additionalHeight) + firstHeight + secondHeight
            return CGSize(width: width, height: height)
        }
        
        let height = CGFloat(additionalHeight) + firstHeight + secondHeight + width*ratio
        return CGSize(width: width, height: height)
    }
    
    func itemSize(height: CGFloat, additionalWidth: CGFloat, text: String? = nil, font: UIFont? = nil) -> CGSize {
        
        guard let text = text , let font = font else {
            return CGSize.zero
        }
        
        let textWidth = text.width(withConstrainedHeight: height, font: font)
       
        let width = additionalWidth + textWidth
        return CGSize(width: width, height: height)
    }
    
    func itemSize(numberInRow: Int = 1, height: CGFloat? = nil, width: CGFloat? = nil, spacing: ItemSpacing = .standard) -> CGSize {
        let height = height ?? self.frame.height
        let additionalWidth =  spacing.rawValue * CGFloat(numberInRow + 1)
        let width = width ?? (self.frame.width - additionalWidth) / CGFloat(numberInRow)
        return CGSize(width: width, height: height)
    }
    
    func itemSize(width: CGFloat, additionalHeight: CGFloat, ratio: ItemRatio) -> CGSize {
        let width = width
        let height = width * ratio.rawValue + additionalHeight
        return CGSize(width: width, height: height)
    }
    
    func numberInRow(type: ItemCount) -> Int {
        return Device.current.isPad ? UIWindow.isLandscape ? type.padLandscape : type.padPortrait : type.phone
    }
    
    func dynamicHeight(type: ItemType) -> CGFloat {
        let height = itemSize(type: type, layout: .horizontal).height.rounded(.up) + 36.0
        return height
    }
}

extension UICollectionView {
    
    func checkEmpty(items: [Any]?, type: Empty = .all) {
        guard let items = items else { return }
        items.isEmpty ? self.setEmptyView(type: type) : self.restore()
        self.hideSkeleton()
    }
    
    func setEmptyView(type: Empty) {
        let emptyView = EmptyView.fromNib()
        emptyView.type = type
        emptyView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        self.backgroundView = emptyView
    }
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UICollectionView {
    /// Reloads a table view without losing track of what was selected.
    func reloadDataSavingSelections() {
        let selectedItems = indexPathsForSelectedItems

        reloadData()

        if let selectedItems = selectedItems {
            for indexPath in selectedItems {
                selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
}

extension UICollectionView {
    func reloadWithoutAnimation() {
        UIView.transition(with: self,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                      self.reloadData()
                                  },
                                  completion: nil)
    }
}

