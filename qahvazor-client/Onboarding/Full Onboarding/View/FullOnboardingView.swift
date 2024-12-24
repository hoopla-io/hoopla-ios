//
//  FullOnboardingView.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/12/24.
//

import UIKit
import GhostTypewriter

final class FullOnboardingView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var bakgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var titleLabel: TypewriterLabel! {
        didSet {
            titleLabel.typingTimeInterval = 0.04
        }
    }
    @IBOutlet weak var nextView: CircularProgressView!
    @IBOutlet weak var nextButton: UIButton!
    
}

