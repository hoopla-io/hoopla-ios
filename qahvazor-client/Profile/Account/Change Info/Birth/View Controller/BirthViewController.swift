//
//  BirthViewController.swift
//  itv-new
//
//  Created Jakhongir Nematov on 12/11/21.

import UIKit

protocol BirthViewControllerDelegate: NSObject {
    func didSelect(date: Int)
}

class BirthViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = BirthView

    // MARK: - Services
    weak var delegate: BirthViewControllerDelegate?
    //MARK: - Attributes
    var dateOfBirth: Int = Int(Date().timeIntervalSince1970)
    
    // MARK: - Actions
    @IBAction func saveAction(_ sender: UIButton) {
        let birthDate = Int(view().datePicker.date.timeIntervalSince1970)
        delegate?.didSelect(date: birthDate)
        dismiss(animated: true)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view().datePicker.date = Date(timeIntervalSince1970: TimeInterval(dateOfBirth))
        view().datePicker.maximumDate = Date()
    }
    
}
