//
//  PhotoDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 09/01/25.
//

import UIKit
import ImageViewer_swift

final class PhotoDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    var items = [Pictures]() {
        didSet {
            imageUrls = items.compactMap { $0.pictureUrl }.compactMap { URL(string: $0) }
            self.collectionView.reloadData()
        }
    }
    var imageUrls = [URL]()
    
    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }

    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        if let imageUrl = items[indexPath.row].pictureUrl {
            cell.photoImageView.setImage(with: imageUrl, placeholder: .appImage(.placeholder))
        }
        
        if let vc = viewController as? ShopDetailViewController {
            cell.photoImageView.setupImageViewer(urls: imageUrls, initialIndex: indexPath.row, options: [.theme(.dark), .closeIcon(.appImage(.closeCircle))], from: vc)
        }
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.itemSize(width: collectionView.frame.width, additionalHeight: 0, ratio: .photo)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let vc = viewController as? ShopDetailViewController else { return }
        let offSet = scrollView.contentOffset.x/scrollView.bounds.width
        vc.didScrollPicture(offset: offSet.truncatingRemainder(dividingBy: CGFloat((items.count))))
    }

}
