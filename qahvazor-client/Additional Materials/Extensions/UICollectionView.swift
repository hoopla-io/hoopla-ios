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
    case card
    case channel
    case catalog
    case radio
    case stream
    case actual
    case file
    case profile
    case serial
    case rent
    case news
}

struct ItemCountCard: ItemCount {
    var padLandscape = 7
    var padPortrait  = 5
    var phone        = 3
}

struct ItemCountChannel: ItemCount {
    var padLandscape = 7
    var padPortrait  = 5
    var phone        = 3
}

struct ItemCountCatalog: ItemCount {
    var padLandscape = 6
    var padPortrait  = 4
    var phone        = 2
}

struct ItemCountRadio: ItemCount {
    var padLandscape = 6
    var padPortrait  = 4
    var phone        = 2
}

struct ItemCountStream: ItemCount {
    var padLandscape = 3
    var padPortrait  = 2
    var phone        = 1
}

struct ItemCountEpisode: ItemCount {
    var padLandscape = 6
    var padPortrait  = 4
    var phone        = 2
}

struct ItemCountFile: ItemCount {
    var padLandscape = 6
    var padPortrait  = 4
    var phone        = 2
}

struct ItemCountProfile: ItemCount {
    var padLandscape = 3
    var padPortrait  = 2
    var phone        = 1
}

struct ItemCountSerial: ItemCount {
    var padLandscape = 3
    var padPortrait  = 2
    var phone        = 1
}

struct ItemCountRent: ItemCount {
    var padLandscape = 2
    var padPortrait  = 2
    var phone        = 1
}

struct ItemCountNews: ItemCount {
    var padLandscape = 3
    var padPortrait  = 2
    var phone        = 1
}

enum ItemRatio: CGFloat {
    case card    = 1.43
    case channel = 1.0
    case catalog = 0.41
    case stream  = 0.56
    case news    = 0.465
    case person  = 0.46
    case actual  = 0.79
    case serial  = 0.21
    case rent    = 0.36
}

enum ItemSpacing: CGFloat {
    case standard = 16.0
    case custom   = 10.0
    case card     = 12.0
    case zero     = 0.0
}

enum ItemAdditionalHeight: CGFloat {
    case card    = 50.0
    case channel = 0.0
    case catalog = 36.0
    case stream  = 32.0
    case actual  = 31.0
}

enum ItemLayout {
    case horizontal
    case vertical
}

extension UICollectionView {
    func itemSize(type: ItemType, layout: ItemLayout = .vertical) -> CGSize {
        switch type {
        case .card:
            return itemSize(itemType: .card, layout: layout, ratio: .card, spacing: .card, additionalHeight: .card)
        case .channel:
            return itemSize(itemType: .channel, layout: layout, ratio: .channel, spacing: .custom, additionalHeight: .channel)
        case .catalog:
            return itemSize(itemType: .catalog, layout: layout, ratio: .catalog, spacing: .standard, additionalHeight: .channel)
        case .radio:
            return itemSize(itemType: .radio, layout: layout, ratio: .channel, spacing: .standard, additionalHeight: .card)
        case .stream:
            return itemSize(itemType: .stream, layout: layout, ratio: .stream, spacing: .standard, additionalHeight: .stream)
        case .actual:
            return itemSize(itemType: .actual, layout: layout, ratio: .actual, spacing: .standard, additionalHeight: .channel)
        case .file:
            return itemSize(itemType: .file, layout: layout, ratio: .stream, spacing: .standard, additionalHeight: .channel)
        case .serial:
            return itemSize(itemType: .serial, layout: layout, ratio: .serial, spacing: .zero, additionalHeight: .channel)
        case .rent:
            return itemSize(itemType: .rent, layout: layout, ratio: .rent, spacing: .standard, additionalHeight: .channel)
        case .news:
            return itemSize(itemType: .news, layout: layout, ratio: .news, spacing: .standard, additionalHeight: .channel)
        default:
            return CGSize.zero
        }
    }
                    
    func numberInRow(type: ItemType) -> Int {
        switch type {
        case .card:
            return numberInRow(type: ItemCountCard())
        case .channel:
            return numberInRow(type: ItemCountChannel())
        case .catalog:
            return numberInRow(type: ItemCountCatalog())
        case .radio:
            return numberInRow(type: ItemCountRadio())
        case .stream:
            return numberInRow(type: ItemCountStream())
        case .actual:
            return numberInRow(type: ItemCountEpisode())
        case .file:
            return numberInRow(type: ItemCountFile())
        case .profile:
            return numberInRow(type: ItemCountProfile())
        case .serial:
            return numberInRow(type: ItemCountSerial())
        case .rent:
            return numberInRow(type: ItemCountRent())
        case .news:
            return numberInRow(type: ItemCountNews())
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
        let numberInRow = self.numberInRow(type: .profile)
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
    
//    func checkEmpty(items: [Any]?, type: Empty = .all) {
//        guard let items = items else { return }
//        items.isEmpty ? self.setEmptyView(type: type) : self.restore()
//        self.hideSkeleton()
//    }
//    
//    func setEmptyView(type: Empty) {
//        let emptyView = EmptyView.fromNib()
//        emptyView.type = type
//        emptyView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
//        self.backgroundView = emptyView
//    }
    
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

