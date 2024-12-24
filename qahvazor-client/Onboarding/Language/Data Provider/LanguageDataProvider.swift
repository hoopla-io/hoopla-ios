//
//  LanguageDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/12/24.
//

import UIKit

final class LanguageDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?

    internal var items = [Language]() {
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LanguageCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? LanguageCollectionViewCell else { return UICollectionViewCell() }
        cell.label.text = items[indexPath.row].name
        cell.isTicked = items[indexPath.row].domen == UserDefaults.standard.getLocalization()
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.itemSize(height: 48.0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = viewController as? LanguageViewController {
            vc.didSelectLanguage(lang: items[indexPath.row].domen)
        }
    }
}

