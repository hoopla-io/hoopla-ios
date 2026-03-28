//
//  ReviewViewController.swift
//  qahvazor-client
//

import UIKit

class ReviewViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    typealias RootView = ReviewView
    
    // MARK: - Root View
    private let reviewView = ReviewView()
    
    // MARK: - Services
    let viewModel = ReviewViewModel()
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    
    // MARK: - Attributes
    var data: OrderHistory?
    private var selectedRating: Double = 0
    private var selectedTags: Set<Int> = []
    
    private let tagOptions = [
        "service".localized,
        "appFunctionality".localized,
        "quality".localized,
        "speed".localized,
        "other".localized
    ]
    
    // MARK: - Life cycles
    override func loadView() {
        view = reviewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        setupActions()
        configureData()
    }
}
// MARK: - Networking
extension ReviewViewController: ReviewViewModelProtocol {
    func didFinishFetch(data: [OrderHistory], meta: Meta?) {
        
    }
}

// MARK: - Setup
extension ReviewViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        
        reviewView.configureTags(tagOptions, target: self, action: #selector(tagTapped(_:)))
        reviewView.commentTextView.delegate = self
        
        reviewView.cosmosView.didTouchCosmos = { [weak self] rating in
            self?.selectedRating = rating
        }
        reviewView.cosmosView.didFinishTouchingCosmos = { [weak self] rating in
            self?.selectedRating = rating
        }
    }
    
    private func setupActions() {
        reviewView.closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        reviewView.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    
    private func configureData() {
        guard let data = data else { return }
        reviewView.drinkNameLabel.text = data.drinkName
        reviewView.dateLabel.text = DateFormatter.string(timestamp: data.purchasedAtUnix, formatter: .orderedDate)
        if let imageUrl = data.drinkImage {
            reviewView.drinkImageView.setImage(with: imageUrl)
        }
    }
}

// MARK: - Actions
extension ReviewViewController {
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func tagTapped(_ sender: UIButton) {
        let index = sender.tag
        if selectedTags.contains(index) {
            selectedTags.remove(index)
            reviewView.updateTagButton(sender, selected: false)
        } else {
            selectedTags.insert(index)
            reviewView.updateTagButton(sender, selected: true)
        }
    }
    
    @objc private func submitTapped() {
        let comment = reviewView.commentTextView.text ?? ""
        let tags = selectedTags.map { tagOptions[$0] }
        guard let id = data?.id else { return }
        
        viewModel.sendFeedback(id: id, rating: Int(selectedRating), comment: comment)
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension ReviewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        reviewView.placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        reviewView.placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        reviewView.placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
