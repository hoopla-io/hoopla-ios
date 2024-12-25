//
//  TextFieldViewController.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

enum ButtonStatus {
    case active
    case passive
}

class TextFieldViewController : UIViewController {
    var textFields: [UITextField]?
    var button: UIButton?
    
    @objc open dynamic func next() {
        
    }
    @objc open dynamic func textFieldDidChange(_ textField: UITextField?) {
        
    }
}

extension TextFieldViewController: UITextFieldDelegate {
    
    func setupTextFields(textFields: [UITextField], button: UIButton) {
        self.textFields = textFields
        self.button = button
        
        for textField in textFields {
            textField.delegate = self
            textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
            next()
        }
        return false
    }

    @objc func editingChanged(_ sender: UITextField? = nil) {
        textFieldDidChange(sender)
        guard let button = button else { return }
        button.setStatus(status())
    }

    func status() -> ButtonStatus {
        guard let textFields = textFields else { return .active }
        for textField in textFields {
            if let text = textField.text, text.isEmpty {
                return .passive
            }
        }
        return .active
    }
}

