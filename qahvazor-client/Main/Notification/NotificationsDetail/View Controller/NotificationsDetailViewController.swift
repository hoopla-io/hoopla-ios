//
//  NotificationsDetailViewController.swift
//  itv-new
//
//  Created Admin NBU on 14/10/21.

import UIKit

class NotificationsDetailViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = NotificationsDetailView

    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: MainCoordinator?
    private let viewModel = NotificationsDetailViewModel()
    
    // MARK: - Attributes
    internal var notificationId: Int?
    internal var shareUrl: String?
    internal var item: NewsNotification?
    
    // MARK: - Actions
    @objc func shareAction(_ sender: UIButton) {
        guard let shareUrl = shareUrl  else { return }
        share(text: shareUrl)
    }
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        prepareForTransition()
        
        guard let notificationId = notificationId else { return }
        viewModel.notificationsShow(notificationId: notificationId)
    }
    
}

// MARK: - Networking
extension NotificationsDetailViewController: NotificationsDetailViewModelProtocol {
    func didFinishFetch(notification: NewsNotification) {
        view().titleLabel.text = notification.notificationTitle
        view().detailLabel.text = notification.notificationDescription
        
        view().timeButton.setTitle(notification.createdAt, for: .normal)
        
        if let imageUrl = notification.files?.imageUrl {
            view().imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage())
        }
        
        shareUrl = notification.shareUrl
    }
}
// MARK: - Other funcs
extension NotificationsDetailViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
    }
    
    private func prepareForTransition() {
        guard let item = item, let notificationId = item.notificationId else { return }
        if let posterUrl = item.files?.imageUrl {
            view().imageView.sd_setImage(with: URL(string: posterUrl), placeholderImage: view().imageView.image)
        }
        view().titleLabel.text = item.notificationTitle
        view().detailLabel.text = item.notificationDescription
        view().titleLabel.hero.id = HeroType.title.rawValue + String(notificationId)
        view().imageView.hero.id = HeroType.imageView.rawValue + String(notificationId)
        view().detailLabel.hero.id = HeroType.subTitle.rawValue + String(notificationId)
        view().hero.id = HeroType.view.rawValue + String(notificationId)
        view().hero.modifiers = [.forceAnimate]
        
        viewModel.notificationsShow(notificationId: notificationId)
    }
}
