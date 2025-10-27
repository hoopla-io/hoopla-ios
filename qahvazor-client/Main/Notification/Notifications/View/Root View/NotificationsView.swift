//
//  NotificationsView.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import UIKit

final class NotificationsView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: NotificationsCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: NotificationsCollectionViewCell.defaultReuseIdentifier)
        }
    }
}
