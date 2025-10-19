//
//  OnsDataProvider.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 13/09/25.
//

//import UIKit
//import Haptica
//
//final class OnsDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//    // MARK: - Outlets
//    weak var collectionView: UICollectionView! {
//        didSet {
//            collectionView.dataSource = self
//            collectionView.delegate = self
//        }
//    }
//
//    // MARK: - Attributes
//    weak var viewController: UIViewController?
//
//    internal var items = [Modification]() {
//        didSet {
//            self.collectionView.reloadData()
//            guard let vc = viewController as? ConfirmOrderViewController else { return }
//            for (index,item) in items.enumerated() {
//                if item.modificationId == vc.selectedShugar?.modificationId {
//                    self.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .top)
//                }
//            }
//        }
//    }
//
//    // MARK: - Lifecycle
//    init(viewController: UIViewController? = nil) {
//        self.viewController = viewController
//    }
//
//    // MARK: - Data Source
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return items.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let vc = viewController as? ConfirmOrderViewController else { return UICollectionViewCell() }
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterGenresCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? FilterGenresCollectionViewCell else { return UICollectionViewCell() }
//        cell.titleLabel.text = items[indexPath.row].modificationName
//        cell.isSelected = items[indexPath.row].modificationId == vc.selectedShugar?.modificationId
//        return cell
//    }
//
//    // MARK: - Delegate
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return collectionView.itemSize(height: 28.0)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let vc = viewController as? ConfirmOrderViewController else { return }
//        vc.selectedShugar = items[indexPath.row]
//        Haptic.impact(.light).generate()
//    }
//}
//
