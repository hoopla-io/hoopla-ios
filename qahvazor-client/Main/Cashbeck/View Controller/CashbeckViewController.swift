//
//  CashbeckViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//

import UIKit

protocol CashbeckViewProtocol: AnyObject {
    func didFinishCashbeck(cashbek: Double)
}
class CashbeckViewController: UIViewController, ViewSpecificController {
    // MARK: - Root View
    typealias RootView = CashbeckView
    
    // MARK: - Attributes
    weak var delegate: CashbeckViewProtocol?
    var selectedCashbekPrice: Double = 0.0 {
        didSet {
            view().usedPriceLabel.text = selectedCashbekPrice.formattedWithCurrency
        }
    }
    var totalPrice: Double = 0.0
    var maxLimit: Double = 0.0
    var minLimit: Double = 1000.0
    
    // MARK: - Actions
    @IBAction func calculateAction(_ sender: UIButton) {
        switch sender.tag {
        case 1 where selectedCashbekPrice >= minLimit  && selectedCashbekPrice < maxLimit:
            selectedCashbekPrice += 1000

        case 0 where selectedCashbekPrice > minLimit && selectedCashbekPrice <= maxLimit:
            selectedCashbekPrice -= 1000

        default:
            break
        }
    }
    @IBAction func useAction(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.didFinishCashbeck(cashbek: selectedCashbekPrice)
        }
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
}

// MARK: - Other funcs
extension CashbeckViewController {
    private func appearanceSettings() {
        if Cashbeck.balance < totalPrice {
            maxLimit = Cashbeck.balance
        } else {
            maxLimit = totalPrice
        }
        if selectedCashbekPrice > totalPrice {
            selectedCashbekPrice = totalPrice
        }
        
        view().availablePriceLabel.text = Cashbeck.balance.formattedWithCurrency
        let note = "cashNote".localized
        if UserDefaults.standard.getLocalization() == AppLanguage.uz.rawValue {
            view().cashNoteLabel.text = "\(selectedCashbekPrice.formattedWithCurrency)\(note)"
        } else {
            view().cashNoteLabel.text = "\(note) \(selectedCashbekPrice.formattedWithCurrency)"
        }
    }
}
