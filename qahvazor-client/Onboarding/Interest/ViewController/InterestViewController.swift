//
//  InterestViewController.swift
//  itv-new
//
//  Created Jakhongir Nematov on 19/11/21.

import UIKit
import Magnetic

class InterestViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = InterestView

    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: Coordinator?
    internal var magnetic: Magnetic?

    // MARK: - Attributes
    let coffeeTypes = [
        "Espresso",
        "Americano",
        "Latte",
        "Cappuccino",
        "Macchiato",
        "Mocha",
        "Flat White",
        "Affogato",
        "Cortado",
        "Irish Coffee",
        "Turkish Coffee",
        "Black Coffee"
    ]

    // MARK: - Actions
    @IBAction func nextButtonAction(_ sender: UIButton) {
        UserDefaults.standard.saveAccessToken(token: "")
        resetTabBar()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        setupNodes(list: coffeeTypes)
    }
    
}

// MARK: - Other funcs
extension InterestViewController {
    private func appearanceSettings() {
        navigationItem.hidesBackButton = true
        setupMagnetic()
    }
    
    private func setupMagnetic() {
        magnetic = view().magneticView.magnetic
        
        guard let magnetic = magnetic else { return }
        magnetic.backgroundColor = .clear
        magnetic.allowsMultipleSelection = true
    }
    
    private func setupNodes(list: [String]) {
        for item in list {
            let node = Node(text: item, color: UIColor.secondarySystemBackground, radius: 40)
            node.fontColor = UIColor.label
            node.selectedFontColor = UIColor.appColor(.white)
            node.scaleToFitContent = true
            node.strokeColor = .clear
            node.selectedColor = UIColor.appColor(.mainColor)
            magnetic?.addChild(node)
        }
    }
    
}
