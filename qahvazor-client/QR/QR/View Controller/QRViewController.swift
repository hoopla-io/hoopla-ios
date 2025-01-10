//
//  QRViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 10/01/25.
//

import UIKit
import ImageViewer_swift
import Haptica

class QRViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = QRView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: QRCoordinator?
    let viewModel = QRViewModel()
    
    // MARK: - Attributes
    var dataProvider: MainDataProvider?
    private var progressTimer: Timer?
    private var duration: Double = 20.0 {
        didSet {
            guard duration >= 0.0 else {
                duration = 0.0
                progressTimer?.invalidate()
                view().reloadButton.isHidden = false
                view().timerLabel.isHidden = true
                dismiss(animated: true)
                return
            }
            view().reloadButton.isHidden = true
            view().timerLabel.isHidden = false
            view().timerLabel.text = "\(Int(duration))"
        }
    }
    private var timeInterval: Double = 1
    var data: QR? {
        didSet {
            guard let data else { return }
            if let value = data.qrCode {
                view().qrImageView.image = .generateQRCode(key: value)
                view().containerView.hideSkeleton()
                view().qrImageView.setupImageViewer(images: [view().qrImageView.image ?? UIImage()], options: [.theme(.dark), .closeIcon(.appImage(.closeCircle))], from: self)
            }
            guard let expireTime = data.expireAt else { return }
            duration = Double(expireTime - Int(Date().timeIntervalSince1970))
        }
    }
    // MARK: - Actions
    @IBAction func reloadAction() {
        viewModel.getQRCode()
        Haptic.impact(.heavy).generate()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        viewModel.getQRCode()
    }
    
}
// MARK: - Networking
extension QRViewController: QRViewModelProtocol {
    func didFinishFetch(data: QR) {
        self.data = data
        setupProgressTimer()
    }
}

// MARK: - Other funcs
extension QRViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationItem.title = "QR".localized
        
    }
    
    private func setupProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(progressAction), userInfo: nil, repeats: true)
    }
    
    @objc func progressAction() {
        duration -= timeInterval
    }
}
