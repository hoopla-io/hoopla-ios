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
    var dataProvider: HistoryDataProvider?
    private var progressTimer: Timer?
    private var duration: Double = 20.0 {
        didSet {
            guard duration >= 0.0 else {
                duration = 0.0
                progressTimer?.invalidate()
                view().reloadButton.isHidden = false
                view().timerLabel.text = "00:00"
                dismiss(animated: true)
                return
            }
            view().reloadButton.isHidden = true
            view().timerLabel.text = duration.convertToTime(calendarType: [.minute, .second])
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
    var appDeactiveTime = Double()
    var durationInDeactive = Double()
    
    // MARK: - Actions
    @IBAction func authAction() {
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func reloadAction() {
        viewModel.getQRCode()
        Haptic.impact(.heavy).generate()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        if UserDefaults.standard.isAuthed() {
            viewModel.getQRCode()
//            viewModel.getOrderHistoryList()
        }
    }
    
}
// MARK: - Networking
extension QRViewController: QRViewModelProtocol {
    func didFinishFetch(data: QR) {
        self.data = data
        setupProgressTimer()
    }
    
    func didFinishFetch(data: [OrderHistory]) {
        dataProvider?.items = data
    }
}

// MARK: - Other funcs
extension QRViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationItem.title = "QR".localized
        
        let dataProvider = HistoryDataProvider()
        dataProvider.tableView = view().tableView
        self.dataProvider = dataProvider
        
        view().authContainerView.isHidden = UserDefaults.standard.isAuthed()
        setupObserver()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        view().tableView.refreshControl = refreshControl
        
        let data: [OrderHistory] = [OrderHistory(id: 1, partnerName: "Aroma", shopName: "Aroma Toshkent City Mall", purchasedAtUnix: 1736671295),
                                    OrderHistory(id: 1, partnerName: "Safia", shopName: "Safia Toshkent City", purchasedAtUnix: 1736670295)]
        dataProvider.items = data
    }
    
    @objc func handleRefreshControl(sender: UIRefreshControl? = nil) {
//        viewModel.getOrderHistoryList()
        
        DispatchQueue.main.async {
            sender?.endRefreshing()
        }
    }
    
    private func setupProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(progressAction), userInfo: nil, repeats: true)
    }
    
    @objc func progressAction() {
        duration -= timeInterval
    }
    
    @objc func appBecomeActive() {
        let currentTime = Double(Date().timeIntervalSince1970)
        let difference = currentTime - appDeactiveTime
        let differenceDuration = abs(duration - durationInDeactive)
        
        duration -= abs(difference - differenceDuration)
    }
    
    @objc func appBecomeDeactive() {
        appDeactiveTime = Double(Date().timeIntervalSince1970)
        durationInDeactive = duration
    }
    
    private func setupObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appBecomeDeactive), name: UIApplication.willResignActiveNotification, object: nil)
    }
}
