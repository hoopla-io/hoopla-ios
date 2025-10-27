//
//  NotificationsCollectionViewCell.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import UIKit

class NotificationsCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerCurve = .continuous
        layer.cornerRadius = 12
    }
}
