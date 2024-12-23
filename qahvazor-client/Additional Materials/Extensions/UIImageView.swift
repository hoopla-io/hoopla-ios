//
//  UIImageView.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
//import SDWebImage
//
//extension UIImageView {
//    @IBInspectable var cornerRadius: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerCurve = .continuous
//            layer.cornerRadius = newValue
//        }
//    }
//
//    func setImage(with url: String? = nil, placeholder: UIImage = UIImage()) {
//        guard let url = url, url != "" else {
//            DispatchQueue.main.async {
//                self.image = placeholder
//            }
//            return
//        }
//        
//        self.sd_setImage(with: URL(string: url), placeholderImage: placeholder)
//    }
//}
//
//extension UIImageView {
//    func setImage(_ image: UIImage, animated shouldAnimate: Bool) {
//        self.image = image
//        
//        if shouldAnimate {
//            let animationKey = "hub_imageAnimation"
//            layer.removeAnimation(forKey: animationKey)
//            
//            let animation = CATransition()
//            animation.duration = 0.3
//            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            animation.type = .fade
//            layer.add(animation, forKey: animationKey)
//        }
//    }
//}
//
//
