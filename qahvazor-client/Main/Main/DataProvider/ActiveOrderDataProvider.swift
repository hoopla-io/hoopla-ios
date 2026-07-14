//
//  ActiveOrderDataProvider.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 13/07/26.
//

import UIKit

final class ActiveOrderDataProvider: NSObject {
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    weak var viewController: UIViewController?

    var items = [OrderHistory]() {
        didSet {
            collectionView.isHidden = items.isEmpty
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
}

extension ActiveOrderDataProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ActiveOrderCollectionViewCell.defaultReuseIdentifier,
            for: indexPath
        ) as? ActiveOrderCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: items[indexPath.item])
        return cell
    }
}

extension ActiveOrderDataProvider: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: max(1, collectionView.bounds.width - 32),
            height: ActiveOrderCollectionViewCell.preferredHeight
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = viewController as? MainViewController else { return }
        viewController.coordinator?.pushToOrderDetail(items[indexPath.item])
    }
}
