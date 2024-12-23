//
//  MainViewController.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

class MainViewController: UIViewController, ViewSpecificController {
    // MARK: - Root View
    typealias RootView = MainView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view().backgroundColor = .blue
    }
}
