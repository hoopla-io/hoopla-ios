//
//  SearchDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit
import SkeletonView

final class SearchDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private enum Content {
        case partners([Company])
        case shops([Shop])
    }

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    private var content: Content = .partners([])

    var isEmpty: Bool {
        switch content {
        case .partners(let partners): return partners.isEmpty
        case .shops(let shops): return shops.isEmpty
        }
    }

    func showPartners(_ partners: [Company]) {
        content = .partners(partners)
        collectionView.reloadData()
    }

    func showShops(_ shops: [Shop]) {
        content = .shops(shops)
        collectionView.reloadData()
    }

    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }

    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch content {
        case .partners(let partners): return partners.count
        case .shops(let shops): return shops.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch content {
        case .partners(let partners):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PartnerSearchCollectionViewCell.defaultReuseIdentifier,
                for: indexPath
            ) as? PartnerSearchCollectionViewCell else { return UICollectionViewCell() }
            cell.item = partners[indexPath.row]
            return cell
        case .shops(let shops):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier,
                for: indexPath
            ) as? CompanyCollectionViewCell else { return UICollectionViewCell() }
            cell.item = shops[indexPath.row]
            return cell
        }
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch content {
        case .partners:
            return collectionView.itemSize(numberInRow: 1, height: 70)
        case .shops:
            return collectionView.itemSize(type: .company)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? SearchViewController else { return }
        switch content {
        case .partners(let partners):
            vc.didSelectPartner(partners[indexPath.row])
        case .shops(let shops):
            guard let id = shops[indexPath.row].shopId else { return }
            vc.coordinator?.pushToShopDetail(id: id, item: shops[indexPath.row])
        }
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension SearchDataProvider: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CompanyCollectionViewCell.defaultReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}
