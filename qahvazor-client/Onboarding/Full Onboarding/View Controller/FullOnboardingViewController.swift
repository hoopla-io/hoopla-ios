//
//  FullOnboardingViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/12/24.
//

import UIKit
import GhostTypewriter
import Haptica

enum FullOnboarding: CaseIterable {
    case first
    case second
}

class FullOnboardingViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = FullOnboardingView

    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: OnboardingCoordinator?
    internal var duration = 5.0
    internal var task = DispatchWorkItem {}

    // MARK: - Attributes
    var firstTimer = Timer()
    var secondTimer = Timer()
    internal var onboarding: FullOnboarding? {
        didSet {
            switch onboarding {
            case .first:
                secondTimer.invalidate()
                view().bakgroundImageView.image = UIImage.appImage(.firstOnboarding)
                self.view().titleLabel.text = "firstOnboarding".localized
                view().titleLabel.startTypewritingAnimation()
                view().nextView.setProgressWithAnimation(duration: duration, value: 0.5)
                startTypingWithHaptics(timer: &firstTimer)
            case .second:
                firstTimer.invalidate()
                view().bakgroundImageView.setImage(UIImage.appImage(.secondOnboarding), animated: true)
                view().titleLabel.text = "secondOnboarding".localized
                view().titleLabel.restartTypewritingAnimation()
                view().nextView.setProgressWithAnimation(duration: duration, value: 1, fromValue: 0.5)
                startTypingWithHaptics(timer: &secondTimer)
            case .none:
                break
            }

            task.cancel()
            task = DispatchWorkItem { self.next() }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
    var characterCount = 0

    // MARK: - Actions
    @IBAction func nextButtonAction(_ sender: UIButton) {
        next()
    }
    @IBAction func skipButtonAction(_ sender: UIButton) {
        coordinator?.pushToInterestVC()
    }
    
    func next() {
        guard let fullOnboarding = onboarding else { return }
        switch fullOnboarding {
        case .first:
            self.onboarding = .second
        case .second:
            coordinator?.pushToInterestVC()
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        task.cancel()
        firstTimer.invalidate()
        secondTimer.invalidate()
    }
}

// MARK: - Other funcs
extension FullOnboardingViewController {
    private func appearanceSettings() {
        navigationItem.hidesBackButton = true
    }
    
    func startTypingWithHaptics(timer: inout Timer) {
        characterCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: view().titleLabel.typingTimeInterval, repeats: true) { [weak self] timer in
            guard let self else { return }
            if characterCount < view().titleLabel.text?.count ?? 0 {
                characterCount += 1
                if characterCount % 3 == 0 {  // Haptic every 3 characters
                    Haptic.impact(.light).generate()
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

