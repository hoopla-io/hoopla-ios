//
//  NotificationsDataProvider.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import UIKit
import SkeletonView
import Hero

enum HeroType: String {
    case view
    case imageView
    case title
    case subTitle
}

final class NotificationsDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
    
    internal var items = [NewsNotification]() {
        didSet {
            self.collectionView.reloadData()
            collectionView.hideSkeleton()
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationsCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? NotificationsCollectionViewCell else { return UICollectionViewCell() }
        cell.titleLabel.text = items[indexPath.row].notificationTitle
        cell.detailLabel.text = items[indexPath.row].notificationDescription
        cell.timeButton.setTitle(items[indexPath.row].createdAt, for: .normal)
        
        if let imageUrl = items[indexPath.row].files?.imageUrl {
            cell.imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage())
        }
        if let notificationId = items[indexPath.row].notificationId {
            cell.imageView.hero.id = HeroType.imageView.rawValue + String(notificationId)
            cell.titleLabel.hero.id = HeroType.title.rawValue + String(notificationId)
            cell.detailLabel.hero.id = HeroType.subTitle.rawValue + String(notificationId)
            cell.hero.id = HeroType.view.rawValue + String(notificationId)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let vc = viewController as? NotificationsViewController else { return }
        if indexPath.row == items.count - 1 && vc.totalItems > items.count {
            vc.currentPage += 1
            vc.viewModel.notificationsList(page: vc.currentPage)
        }
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.itemSize(additionalHeight: 80.0,
                                       additionalSpace: 32.0,
                                       firstText: items[safe: indexPath.row]?.notificationTitle,
                                       firstFont: .systemFont(ofSize: 20, weight: .bold),
                                       secondText: items[safe: indexPath.row]?.notificationDescription,
                                       secondFont: .systemFont(ofSize: 14, weight: .regular),
                                       ratio: 0.465)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? NotificationsViewController else { return }
        guard let id = items[indexPath.row].notificationId else { return }
        vc.coordinator?.pushToNotificationsDetailVC(notificationId: id)
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension NotificationsDataProvider: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return NotificationsCollectionViewCell.defaultReuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}
