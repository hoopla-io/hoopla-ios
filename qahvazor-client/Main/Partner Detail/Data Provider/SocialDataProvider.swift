//
//  SocialDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 08/01/25.
//

import UIKit
import SkeletonView

enum SocialUrlType: String {
    case web
    case instagram
    case facebook
    case telegram
    case youtube
    case phone
}

final class SocialDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    var items = [SocialMedia]() {
        didSet {
            self.collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }

    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SocialCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? SocialCollectionViewCell else { return UICollectionViewCell() }
        let urlType = items[indexPath.row].urlType ?? "web"
        cell.imageView.image = UIImage(named: urlType)
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.itemSize(width: 60, additionalHeight: 0, ratio: .coffee)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? ShopDetailViewController else { return }
        guard let urlString = items[indexPath.row].url else { return }
        if items[indexPath.row].urlType == SocialUrlType.phone.rawValue {
            vc.callAction(phoneNumber: urlString)
        } else {
            vc.openURL(urlString: urlString)
        }
    }
}

