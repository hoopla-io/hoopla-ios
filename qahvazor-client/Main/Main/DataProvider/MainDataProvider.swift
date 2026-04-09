//
//  MainDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit
import SkeletonView
import Hero

struct ShopDataCache {
    static var shops: [Shop] = []
}

final class MainDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.showAnimatedSkeleton()
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    var items = [Shop]() {
        didSet {
            self.collectionView.hideSkeleton()
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? CompanyCollectionViewCell else { return UICollectionViewCell() }
        cell.prepareForReuse()
        cell.item = items[indexPath.row]
        if let shopId = items[indexPath.row].shopId {
            cell.imageView.hero.id = HeroType.imageView.rawValue + String(shopId)
            cell.nameLabel.hero.id = HeroType.title.rawValue + String(shopId)
            cell.hero.id = HeroType.view.rawValue + String(shopId)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let vc = viewController as? MainViewController else { return }
//        if indexPath.row == items.count - 1 && vc.totalItems > items.count {
//            vc.currentPage += 1
//            vc.viewModel.notificationsList(page: vc.currentPage)
//        }
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.itemSize(type: .company)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? MainViewController else { return }
        guard let id = items[indexPath.row].shopId else { return }
        vc.coordinator?.pushToShopDetail(id: id, item: items[indexPath.row])
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension MainDataProvider: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CompanyCollectionViewCell.defaultReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}
