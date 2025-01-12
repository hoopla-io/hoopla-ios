//
//  SubscriptionFeatureDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 12/01/25.
//

import UIKit

final class SubscriptionFeatureDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?

    internal var items = [SubscriptionFeature]() {
        didSet {
            self.collectionView.reloadData()
        }
    }

    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeatureCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? FeatureCollectionViewCell else { return UICollectionViewCell() }
        cell.titleLabel.text = "- \(items[indexPath.row].feature ?? "")"
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width), height: 20.0)
    }
}
