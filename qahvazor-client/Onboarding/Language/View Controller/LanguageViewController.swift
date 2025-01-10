//
//  LanguageViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/12/24.
//

import UIKit
import Haptica

protocol LanguageViewControllerDelegate: NSObject {
    func didSelectLanguage()
}

class LanguageViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = LanguageView

    // MARK: - Services
    var coordinator: OnboardingCoordinator?
    weak var delegate: LanguageViewControllerDelegate?
    
    // MARK: - Attributes
    var tempLanguage = UserDefaults.standard.getLocalization()
    let languages = [Language(name: "uzbek".localized, domen: AppLanguage.uz.rawValue),
                              Language(name: "russian".localized, domen: AppLanguage.ru.rawValue),
                              Language(name: "english".localized, domen: AppLanguage.en.rawValue)]
    var fromSettings: Bool = false
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
        guard !fromSettings else { return }
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard fromSettings else { return }
        guard tempLanguage != UserDefaults.standard.getLocalization() else { return }
        delegate?.didSelectLanguage()
    }
    
}

// MARK: - Other funcs
extension LanguageViewController {
    private func appearanceSettings() {
        let dataProvider = LanguageDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
        
        self.dataProvider?.items = languages
        
        view().nextButton.isHidden = fromSettings
    }
    
    func didSelectLanguage(lang : String) {
        Haptic.impact(.medium).generate()
        LocalizationManager.shared.setLocale(lang)
        dataProvider?.items = languages
        view().titleLabel.text = "chooseLanguage".localized
        view().nextButton.setTitle("continue".localized, for: .normal)
    }
}

