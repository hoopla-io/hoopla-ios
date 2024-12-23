//
//  UIShowHideTextField.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
//import SnapKit
//
//class UIShowHideTextField: CustomTextField {
//    
//    let rightButton  = UIButton(type: .custom)
//    
//    override var isSecureTextEntry: Bool {
//        didSet {
//            if isFirstResponder {
//                _ = becomeFirstResponder()
//            }
//        }
//    }
//    
//    override func becomeFirstResponder() -> Bool {
//        
//        let success = super.becomeFirstResponder()
//        if isSecureTextEntry, let text = self.text {
//            self.text?.removeAll()
//            insertText(text)
//        }
//        return success
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commonInit()
//    }
//    
//    required override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//    
//    func commonInit() {
////        rightButton.setImage(UIImage.appImage(.eye) , for: .normal)
//        rightButton.addTarget(self, action: #selector(toggleShowHide), for: .touchUpInside)
//        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -18, bottom: 0, right: 18)
//        rightButton.frame = CGRect(x: 0, y:0, width: 0, height: 20)
//        
//        rightViewMode = .always
//        rightView = rightButton
//        isSecureTextEntry = true
//    }
//    
//    @objc
//    func toggleShowHide(button: UIButton) {
//        toggle()
//    }
//    
//    func toggle() {
//        isSecureTextEntry.toggle()
//        if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) { replace(textRange, withText: text!) }
////        rightButton.setImage(isSecureTextEntry ? UIImage.appImage(.eye) : UIImage.appImage(.eye) , for: .normal)
//    }
//    
//}
//
