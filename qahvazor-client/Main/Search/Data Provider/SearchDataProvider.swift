//
//  SearchDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit
import SkeletonView

final class SearchDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    private var partners: [Company] = []

    var isEmpty: Bool {
        partners.isEmpty
    }

    func showPartners(_ partners: [Company]) {
        self.partners = partners
        collectionView.reloadData()
    }

    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }

    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        partners.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PartnerSearchCollectionViewCell.defaultReuseIdentifier,
            for: indexPath
        ) as? PartnerSearchCollectionViewCell else { return UICollectionViewCell() }
        cell.item = partners[indexPath.row]
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.itemSize(numberInRow: 1, height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? SearchViewController else { return }
        vc.didSelectPartner(partners[indexPath.row])
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension SearchDataProvider: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PartnerSearchCollectionViewCell.defaultReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}
