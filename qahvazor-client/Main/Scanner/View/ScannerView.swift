//
//  ScannerView.swift
//  itv-new
//
//  Created Admin NBU on 14/02/22.

import UIKit

final class ScannerView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flashLightButton: UIButton!
    
    override func setupBackgroundColor() {
        backgroundColor = .clear
    }
    
}
