//
//  CircularProgressBar.swift
//  itv-new
//
//  Created by Jakhongir Nematov on 19/11/21.
//

import UIKit

class CircularProgressView: UIView {
    
    var progressLyr = CAShapeLayer()
    var trackLyr = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeCircularPath()
    }
    
    var progressClr = UIColor.appColor(.mainColor) {
        didSet {
            progressLyr.strokeColor = progressClr.cgColor
        }
    }
    var trackClr = UIColor.appColor(.white).withAlphaComponent(0.2) {
        didSet {
            trackLyr.strokeColor = trackClr.cgColor
        }
    }
    
    func makeCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 4.0)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLyr.path = circlePath.cgPath
        trackLyr.fillColor = UIColor.clear.cgColor
        trackLyr.strokeColor = trackClr.cgColor
        trackLyr.lineWidth = 4.0
        trackLyr.strokeEnd = 1.0
        layer.addSublayer(trackLyr)
        progressLyr.lineCap = CAShapeLayerLineCap.round
        progressLyr.path = circlePath.cgPath
        progressLyr.fillColor = UIColor.clear.cgColor
        progressLyr.strokeColor = progressClr.cgColor
        progressLyr.lineWidth = 4.0
        progressLyr.strokeEnd = 0.0
        layer.addSublayer(progressLyr)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float, fromValue: Float = 0, action: (()->())? = nil) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLyr.strokeEnd = CGFloat(value)
        progressLyr.add(animation, forKey: "animateprogress")
        guard let action = action else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            action()
        }
    }
}


