//
//  GradientView.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

class GradientView: UIView {
   
    internal var gradientLayer: CAGradientLayer!
    
    internal var topColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    internal var bottomColor: UIColor = UIColor.appColor(.mainBackground) {
        didSet {
            setNeedsLayout()
        }
    }
    
    internal var startPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    internal var startPointY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    internal var endPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    internal var endPointY: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer = self.layer as? CAGradientLayer
        self.gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        self.gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        self.gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
    }
    
    func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
        let fromColors = self.gradientLayer?.colors
        let toColors: [AnyObject] = [newTopColor.cgColor, newBottomColor.cgColor]
        self.gradientLayer?.colors = toColors
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        self.gradientLayer?.add(animation, forKey: "animateGradient")
        self.topColor = newTopColor
        self.bottomColor = newBottomColor
    }
}

