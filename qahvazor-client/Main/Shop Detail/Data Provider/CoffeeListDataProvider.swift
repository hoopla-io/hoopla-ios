//
//  CoffeeListDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 06/01/25.
//

import UIKit
import SkeletonView

// MARK: - CoffeeListDataProvider
final class CoffeeListDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
    
    var items = [Categories]() {
        didSet {
            self.collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }

    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].drinks?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CoffeeCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? CoffeeCollectionViewCell else { return UICollectionViewCell() }
        cell.titleLabel.text = items[indexPath.section].drinks?[indexPath.row].name
        cell.priceLabel.text = items[indexPath.section].drinks?[indexPath.row].productPrice?.formattedWithCurrency
        if let imageURL = items[indexPath.section].drinks?[indexPath.row].pictureUrl {
            cell.imageView.setImage(with: imageURL, placeholder: .appImage(.placeholder))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CoffeeSectionHeaderView.reuseIdentifier, for: indexPath) as! CoffeeSectionHeaderView
        header.titleLabel.text = items[indexPath.section].name
        return header
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.itemSize(type: .coffeeCard)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.section].drinks?[indexPath.row]
        guard let vc = viewController as? ShopDetailViewController, let item else { return }
        vc.nextAction(item: item)
    }

}

// MARK: - SkeletonCollectionViewDataSource
extension CoffeeListDataProvider: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CoffeeCollectionViewCell.defaultReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}

