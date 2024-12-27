//
//  MainDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit
import SkeletonView

final class MainDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
    
    var items = [Company]() {
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
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? CompanyCollectionViewCell else { return UICollectionViewCell() }
//        cell.titleLabel.text = items[indexPath.row].notificationTitle
//        cell.detailLabel.text = items[indexPath.row].notificationDescription
//        cell.timeButton.setTitle(items[indexPath.row].createdAt, for: .normal)
//        
//        if let isRead = items[indexPath.row].params?.isRead {
//            cell.redView.isHidden = isRead
//        }
//        
//        if let imageUrl = items[indexPath.row].files?.imageUrl {
//            cell.imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage())
//        }
//        if let notificationId = items[indexPath.row].notificationId {
//            cell.imageView.hero.id = HeroType.imageView.rawValue + String(notificationId)
//            cell.titleLabel.hero.id = HeroType.title.rawValue + String(notificationId)
//            cell.detailLabel.hero.id = HeroType.subTitle.rawValue + String(notificationId)
//            cell.hero.id = HeroType.view.rawValue + String(notificationId)
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let vc = viewController as? MainViewController else { return }
//        if indexPath.row == items.count - 1 && vc.totalItems > items.count {
//            vc.currentPage += 1
//            vc.viewModel.notificationsList(page: vc.currentPage)
//        }
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.itemSize(type: .company)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? MainViewController else { return }
        vc.coordinator?.pushToShopsListVC()
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension MainDataProvider: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CompanyCollectionViewCell.defaultReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}
