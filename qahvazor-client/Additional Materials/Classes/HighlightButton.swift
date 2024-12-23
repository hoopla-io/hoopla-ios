//
//  HighlightButton.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

final class HighlightButton: UIButton {
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        appearanceSettings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        appearanceSettings()
    }
    
    func appearanceSettings() {
        self.adjustsImageWhenHighlighted = false
        self.layer.cornerCurve = .continuous
        guard let textColor = normalTextColor else { return }
        self.setTitleColor(textColor, for: .normal)
        self.tintColor = textColor
    }
    
    //MARK: - HighlightButton
    var highlightDuration: TimeInterval = 0.1
    
    @IBInspectable var normalBackgroundColor: UIColor? {
        didSet {
            backgroundColor = normalBackgroundColor
        }
    }
    
    @IBInspectable var highlightedBackgroundColor: UIColor?
    @IBInspectable var normalTextColor: UIColor?
    let highlightedTextColor: UIColor = .appColor(.mainBackground)
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue == false && isHighlighted {
                highlight()
            } else if oldValue == true && !isHighlighted {
                unHighlight()
            }
        }
    }
    
    private func animateBackground(backColor: UIColor?, textColor: UIColor?, duration: TimeInterval) {
        guard let color = backColor else { return }
        UIView.animate(withDuration: highlightDuration) {
            self.backgroundColor = color
            self.setTitleColor(textColor, for: .normal)
            self.tintColor = textColor
        }
    }
    
    func highlight() {
        animateBackground(backColor: highlightedBackgroundColor, textColor: highlightedTextColor, duration: highlightDuration)
    }
    
    func unHighlight() {
        animateBackground(backColor: normalBackgroundColor, textColor: normalTextColor, duration: highlightDuration)
    }
    
}


