//
//  MilkDataProvider.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 13/09/25.
//

import UIKit
import Haptica

final class MilkDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?

    var items = [Modification]() {
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemsCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? ItemsCollectionViewCell else { return UICollectionViewCell() }
        cell.titleLabel.text = items[indexPath.row].modificationName
        cell.priceLabel.text = "+" + (items[indexPath.row].modificationPrice?.formattedWithCurrency ?? "0")
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 38)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? ConfirmOrderViewController else { return }
        if items[indexPath.row].modificationId == vc.selectedMilk?.modificationId {
            collectionView.deselectItem(at: indexPath, animated: true)
            vc.selectedMilk = nil
        } else {
            vc.selectedMilk = items[indexPath.row]
        }
        vc.changePricingAction()
        Haptic.impact(.light).generate()
    }
}

