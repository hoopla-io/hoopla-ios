//
//  RewardDataProvider.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 02/11/25.
//

import UIKit
import SkeletonView

final class RewardDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
    
    var items = [Loyalty]() {
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RewardsCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? RewardsCollectionViewCell else { return UICollectionViewCell() }
        cell.item = items[indexPath.row]
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 110)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? MainViewController else { return }
//        guard let id = items[indexPath.row].shopId else { return }
//        vc.coordinator?.pushToShopDetail(id: id, name: items[indexPath.row].name, distance: items[indexPath.row].distance)
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension RewardDataProvider: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return RewardsCollectionViewCell.defaultReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}

