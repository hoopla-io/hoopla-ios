//
//  LanguageViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/12/24.
//

import UIKit
import Haptica

class LanguageViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = LanguageView

    // MARK: - Services
    internal var coordinator: OnboardingCoordinator?

    // MARK: - Attributes
    internal let languages = [Language(name: "uzbek".localized, domen: AppLanguage.uz.rawValue),
                              Language(name: "russian".localized, domen: AppLanguage.ru.rawValue),
                              Language(name: "english".localized, domen: AppLanguage.en.rawValue)]
    
    // MARK: - Data Providers
    private var dataProvider: LanguageDataProvider?

    // MARK: - Actions
    @IBAction func nextAction(_ sender: UIButton) {
        coordinator?.pushToFullOnBoardingVC()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
}

// MARK: - Other funcs
extension LanguageViewController {
    private func appearanceSettings() {
        let dataProvider = LanguageDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
        
        self.dataProvider?.items = languages
    }
    
    func didSelectLanguage(lang : String) {
        Haptic.impact(.medium).generate()
        LocalizationManager.shared.setLocale(lang)
        dataProvider?.items = languages
        view().titleLabel.text = "chooseLanguage".localized
        view().nextButton.setTitle("continue".localized, for: .normal)
    }
}

