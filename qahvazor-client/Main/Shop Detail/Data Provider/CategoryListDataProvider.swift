//
//  CategoryListDataProvider.swift
//  qahvazor-client
//
//  Created by iOS on 09/04/26.
//

import UIKit

protocol CategoryListDataProviderDelegate: AnyObject {
    func didSelectCategory(at index: Int)
}

final class CategoryListDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var delegate: CategoryListDataProviderDelegate?
    
    var items = [Categories]() {
        didSet {
            collectionView.reloadData()
            if !items.isEmpty {
                let firstIndex = IndexPath(item: 0, section: 0)
                collectionView.selectItem(at: firstIndex, animated: false, scrollPosition: [])
            }
        }
    }

    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.titleLabel.text = items[indexPath.row].name
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let name = items[indexPath.row].name ?? ""
        let width = name.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width + 40
        return CGSize(width: width, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.didSelectCategory(at: indexPath.row)
    }
}
