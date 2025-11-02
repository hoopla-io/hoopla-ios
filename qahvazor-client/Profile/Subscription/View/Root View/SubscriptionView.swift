//
//  SubscriptionView.swift
//  qahvazor-client
//
//  Created by Alphazet on 11/01/25.
//

import UIKit
import Lottie

final class SubscriptionView: CustomView {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: SubscriptionCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: SubscriptionCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var comingStackView: UIStackView!
    @IBOutlet weak var lottieStackView: UIStackView!
    @IBOutlet weak var comingLabel: UILabel!
    
    func animate() {
        let loadingView = Lottie.LottieAnimationView(name: "soon")
        loadingView.contentMode = .scaleAspectFit
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.loopMode = .loop
        
        lottieStackView.addArrangedSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.width.height.equalTo(200)
        }
        
        loadingView.play()
    }
}
