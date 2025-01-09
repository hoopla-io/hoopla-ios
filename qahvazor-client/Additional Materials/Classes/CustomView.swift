//
//  CustomView.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

class CustomView: UIView {

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundColor()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackgroundColor()
    }
    
    // MARK: - UI Setup
    func setupBackgroundColor() {
        backgroundColor = UIColor.appColor(.mainBackground)
    }
    
}

