//
//  CustomCollectionViewCell.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    var scaleXY: CGFloat = 0.95
    weak var customLabel: UILabel?
    var durationIn: TimeInterval = 0.25
    var durationOut: TimeInterval = 0.5
    
    func animateCell() {
        if isHighlighted {
            UIView.animate(withDuration: durationIn) {
                self.transform = CGAffineTransform(scaleX: self.scaleXY, y: self.scaleXY)
//                self.customLabel?.backgroundColor = .appColor(.gray4)
            }
        } else {
            UIView.animate(withDuration: durationOut) {
                self.transform = .identity
//                self.customLabel?.backgroundColor = .appColor(.gray2)
            }
        }
    }
    override var isHighlighted: Bool {
        didSet {
            animateCell()
        }
    }
}

