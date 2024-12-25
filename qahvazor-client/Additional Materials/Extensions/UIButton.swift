//
//  UIButton.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import SnapKit

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerCurve = .continuous
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
}

extension UIButton {
    func imageShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        layer.masksToBounds = false
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
    }
}

extension UIButton {
    func setRightImage(image: UIImage, height: CGFloat = 17.0, inset: CGFloat = 16.0) {
        let rightImageView = UIImageView()
        rightImageView.image?.withRenderingMode(.alwaysOriginal)
        rightImageView.image = image
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.layer.masksToBounds = true
        addSubview(rightImageView)
        
        rightImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(height)
            make.right.equalToSuperview().inset(inset)
        }
    }
}

extension UIButton {
    func setStatus(_ status: ButtonStatus) {
        switch status {
        case .active:
            backgroundColor = .appColor(.mainColor)
            setTitleColor(UIColor.appColor(.white), for: .normal)
        case .passive:
            backgroundColor = UIColor.systemGray5
            setTitleColor(UIColor.systemGray2, for: .normal)
        }
    }
}

extension UIButton {
    func selectedStatus(_ status: ButtonStatus) {
        switch status {
        case .active:
            backgroundColor = .appColor(.mainColor)
            setTitleColor(UIColor.appColor(.white), for: .normal)
        case .passive:
            backgroundColor = UIColor.darkGray
            setTitleColor(UIColor.placeholderText, for: .normal)
        }
    }
}

extension UIButton {
    func setMenuItems(items: [String], image: [UIImage], completion: @escaping (String) -> ()) {
        var actions = [UIAction]()
        items.indices.forEach { index in
            let action = UIAction(title: items[index], image: image[index] ) { action in
                completion(items[index])
            }
            actions.append(action)
        }
        menu = UIMenu(children: actions)
        showsMenuAsPrimaryAction = true
    }
    
    func setMenuItems(items: [String], selectedItem: String, completion: @escaping (String) -> ()) {
        var actions = [UIAction]()
        items.indices.forEach { index in
            let action = UIAction(title: items[index].localized, state: items[index] == selectedItem ? .on : .off) { action in
                completion(items[index])
            }
            actions.append(action)
        }
        menu = UIMenu(children: actions)
        showsMenuAsPrimaryAction = true
    }
}

extension UIButton {
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 100
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
    func shake() {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}

