//
//  StoryDetailViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 16/05/26.
//

import UIKit
import SDWebImage

typealias MainStoryLoadCompletion = (Result<Stories>) -> Void
typealias MainStoryLoader = (_ id: Int, _ completion: @escaping MainStoryLoadCompletion) -> Void

final class MainStoryViewController: UIViewController, @MainActor AlertViewController {

    enum PauseReason: Hashable {
        case hold
        case inactive
        case hidden
        case transition
        case loading
        case mediaLoading
        case loadFailure
    }

    enum NavigationDirection: Equatable {
        case forward
        case backward

        var step: Int {
            switch self {
            case .forward: return 1
            case .backward: return -1
            }
        }
    }

    enum Constants {
        static let defaultDuration: TimeInterval = 5
    }

    private let groups: [Stories]
    private let storyLoader: MainStoryLoader
    private var groupCache: [Int: [StoryDetail]]
    private var stories: [StoryDetail]
    private var currentGroupIndex: Int
    private var currentIndex = 0

    private var previousCollectionViewSize = CGSize.zero
    private var progressViews = [MainStoryProgressView]()
    private var pendingItemIndex: Int?
    private var itemNavigationFallback: DispatchWorkItem?
    private var pendingGroupIndex: Int?
    private var pressStartTime: TimeInterval = 0
    private var pressStartLocation = CGPoint.zero
    private var pressMoved = false

    private var displayLink: CADisplayLink?
    private var elapsedTime: TimeInterval = 0
    private var playbackStartTime: TimeInterval?
    private var pauseReasons: Set<PauseReason> = [.hidden]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            MainStoryPageCollectionViewCell.self,
            forCellWithReuseIdentifier: MainStoryPageCollectionViewCell.reuseIdentifier
        )
        return collectionView
    }()

    private let progressStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 3
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        button.layer.cornerRadius = 16
        button.accessibilityLabel = "close".localized
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var holdGestureRecognizer = UILongPressGestureRecognizer(
        target: self,
        action: #selector(handleHold(_:))
    )

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(
        groups: [Stories],
        selectedGroupIndex: Int,
        initialGroup: Stories,
        storyLoader: @escaping MainStoryLoader
    ) {
        let maximumIndex = max(groups.count - 1, 0)
        let safeGroupIndex = min(max(selectedGroupIndex, 0), maximumIndex)
        let initialStories = initialGroup.items ?? []

        self.groups = groups
        self.currentGroupIndex = safeGroupIndex
        self.stories = initialStories
        self.groupCache = [safeGroupIndex: initialStories]
        self.storyLoader = storyLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        setupObservers()
        rebuildProgressViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startDisplayLinkIfNeeded()
        updateMediaLoadingState()
        removePauseReason(.hidden)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addPauseReason(.hidden)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        invalidateDisplayLink()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let collectionViewSize = collectionView.bounds.size
        guard collectionViewSize != .zero,
              collectionViewSize != previousCollectionViewSize else { return }

        previousCollectionViewSize = collectionViewSize
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionViewSize
            layout.invalidateLayout()
        }
        collectionView.layoutIfNeeded()

        guard stories.indices.contains(currentIndex) else { return }
        collectionView.setContentOffset(
            CGPoint(x: collectionViewSize.width * CGFloat(currentIndex), y: 0),
            animated: false
        )
    }

    deinit {
        itemNavigationFallback?.cancel()
        displayLink?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(collectionView)
        view.addSubview(progressStackView)
        view.addSubview(closeButton)
        view.addSubview(loadingIndicator)

        closeButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            progressStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            progressStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            progressStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            progressStackView.heightAnchor.constraint(equalToConstant: 3),

            closeButton.topAnchor.constraint(equalTo: progressStackView.bottomAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupGestures() {
        holdGestureRecognizer.delegate = self
        holdGestureRecognizer.minimumPressDuration = 0
        holdGestureRecognizer.allowableMovement = CGFloat.greatestFiniteMagnitude
        holdGestureRecognizer.cancelsTouchesInView = false

        view.addGestureRecognizer(holdGestureRecognizer)
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
}

// MARK: - Playback
private extension MainStoryViewController {
    var currentDuration: TimeInterval {
        guard stories.indices.contains(currentIndex),
              let duration = stories[currentIndex].duration,
              duration > 0 else {
            return Constants.defaultDuration
        }
        return TimeInterval(duration)
    }

    var playedTime: TimeInterval {
        guard let playbackStartTime else { return elapsedTime }
        return elapsedTime + CACurrentMediaTime() - playbackStartTime
    }

    func startDisplayLinkIfNeeded() {
        guard displayLink == nil else { return }
        let displayLink = CADisplayLink(target: self, selector: #selector(updatePlayback(_:)))
        displayLink.isPaused = true
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
        reconcilePlaybackState()
    }

    func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    func addPauseReason(_ reason: PauseReason) {
        guard pauseReasons.insert(reason).inserted else { return }
        reconcilePlaybackState()
    }

    func removePauseReason(_ reason: PauseReason) {
        guard pauseReasons.remove(reason) != nil else { return }
        reconcilePlaybackState()
    }

    func reconcilePlaybackState() {
        let shouldPlay = pauseReasons.isEmpty
            && viewIfLoaded?.window != nil
            && displayLink != nil

        if shouldPlay {
            if playbackStartTime == nil {
                playbackStartTime = CACurrentMediaTime()
            }
            displayLink?.isPaused = false
        } else {
            snapshotPlayedTime()
            displayLink?.isPaused = true
            updateProgressViews()
        }
    }

    func snapshotPlayedTime() {
        guard let playbackStartTime else { return }
        elapsedTime += CACurrentMediaTime() - playbackStartTime
        self.playbackStartTime = nil
    }

    func restartPlayback() {
        elapsedTime = 0
        playbackStartTime = nil
        updateProgressViews()
        reconcilePlaybackState()
    }

    @objc func updatePlayback(_ displayLink: CADisplayLink) {
        guard pauseReasons.isEmpty,
              pendingItemIndex == nil,
              pendingGroupIndex == nil,
              stories.indices.contains(currentIndex) else { return }

        let duration = currentDuration
        let progress = min(max(playedTime / duration, 0), 1)
        progressViews[safe: currentIndex]?.progress = CGFloat(progress)

        guard progress >= 1 else { return }
        elapsedTime = duration
        playbackStartTime = nil
        moveForward()
    }

    func rebuildProgressViews() {
        progressStackView.arrangedSubviews.forEach { view in
            progressStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        progressViews = stories.map { _ in
            let progressView = MainStoryProgressView()
            progressStackView.addArrangedSubview(progressView)
            return progressView
        }
        updateProgressViews()
    }

    func updateProgressViews() {
        let currentProgress = currentDuration > 0
            ? min(max(playedTime / currentDuration, 0), 1)
            : 0

        for (index, progressView) in progressViews.enumerated() {
            switch index {
            case ..<currentIndex:
                progressView.progress = 1
            case currentIndex:
                progressView.progress = CGFloat(currentProgress)
            default:
                progressView.progress = 0
            }
        }
    }

    func updateMediaLoadingState() {
        guard stories.indices.contains(currentIndex),
              let cell = collectionView.cellForItem(
                at: IndexPath(item: currentIndex, section: 0)
              ) as? MainStoryPageCollectionViewCell else {
            addPauseReason(.mediaLoading)
            return
        }

        if cell.isImageLoadFinished {
            removePauseReason(.mediaLoading)
        } else {
            addPauseReason(.mediaLoading)
        }
    }
}

// MARK: - Navigation
private extension MainStoryViewController {
    func moveForward() {
        guard pendingItemIndex == nil,
              !pauseReasons.contains(.loading),
              !pauseReasons.contains(.transition) else { return }

        let nextIndex = currentIndex + 1
        if stories.indices.contains(nextIndex) {
            navigateToItem(at: nextIndex)
        } else {
            navigateToAdjacentGroup(.forward)
        }
    }

    func moveBackward() {
        guard pendingItemIndex == nil,
              !pauseReasons.contains(.loading),
              !pauseReasons.contains(.transition) else { return }

        let previousIndex = currentIndex - 1
        if stories.indices.contains(previousIndex) {
            navigateToItem(at: previousIndex)
        } else if currentGroupIndex > 0 {
            navigateToAdjacentGroup(.backward)
        } else {
            restartPlayback()
        }
    }

    func navigateToItem(at index: Int) {
        guard stories.indices.contains(index), index != currentIndex else { return }

        addPauseReason(.transition)
        pendingItemIndex = index
        collectionView.isUserInteractionEnabled = false
        collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: true
        )

        itemNavigationFallback?.cancel()
        let fallback = DispatchWorkItem { [weak self] in
            self?.completeItemNavigation()
        }
        itemNavigationFallback = fallback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: fallback)
    }

    func completeItemNavigation() {
        guard let pendingItemIndex else { return }

        itemNavigationFallback?.cancel()
        itemNavigationFallback = nil
        collectionView.setContentOffset(
            CGPoint(
                x: collectionView.bounds.width * CGFloat(pendingItemIndex),
                y: 0
            ),
            animated: false
        )
        currentIndex = pendingItemIndex
        self.pendingItemIndex = nil
        collectionView.isUserInteractionEnabled = true
        updateMediaLoadingState()
        restartPlayback()
        removePauseReason(.transition)
    }

    func navigateToAdjacentGroup(_ direction: NavigationDirection) {
        guard !pauseReasons.contains(.loading) else { return }
        removePauseReason(.loadFailure)
        addPauseReason(.loading)
        loadFirstAvailableGroup(
            at: currentGroupIndex + direction.step,
            direction: direction
        )
    }

    func loadFirstAvailableGroup(at index: Int, direction: NavigationDirection) {
        guard groups.indices.contains(index) else {
            finishAtGroupBoundary(direction)
            return
        }

        if let cachedStories = groupCache[index] {
            guard !cachedStories.isEmpty else {
                loadFirstAvailableGroup(at: index + direction.step, direction: direction)
                return
            }
            displayGroup(at: index, stories: cachedStories, direction: direction)
            return
        }

        guard let groupID = groups[index].id else {
            groupCache[index] = []
            loadFirstAvailableGroup(at: index + direction.step, direction: direction)
            return
        }

        pendingGroupIndex = index
        loadingIndicator.startAnimating()
        storyLoader(groupID) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleLoadedGroup(result, at: index, direction: direction)
            }
        }
    }

    func handleLoadedGroup(
        _ result: Result<Stories>,
        at index: Int,
        direction: NavigationDirection
    ) {
        guard !pauseReasons.contains(.hidden),
              pendingGroupIndex == index else { return }
        pendingGroupIndex = nil

        switch result {
        case .Success(let group):
            guard groups.indices.contains(index),
                  group.id == groups[index].id else {
                finishGroupLoadingWithError(.invalidData, message: nil)
                return
            }

            let loadedStories = group.items ?? []
            groupCache[index] = loadedStories
            guard !loadedStories.isEmpty else {
                loadFirstAvailableGroup(at: index + direction.step, direction: direction)
                return
            }
            displayGroup(at: index, stories: loadedStories, direction: direction)

        case .Error(let error, let message):
            finishGroupLoadingWithError(error, message: message)
        }
    }

    func finishGroupLoadingWithError(_ error: APIError, message: String?) {
        pendingGroupIndex = nil
        loadingIndicator.stopAnimating()

        switch error {
        case .notAuthorized:
            dismissAction()
            removePauseReason(.loading)
            showErrorAlert(message: AlertViewTexts.errorMSG.rawValue.localized)

        default:
            restartPlayback()
            addPauseReason(.loadFailure)
            removePauseReason(.loading)
            addErrorAlertView(error: (error, message), completion: nil)
        }
    }

    func displayGroup(
        at groupIndex: Int,
        stories: [StoryDetail],
        direction: NavigationDirection
    ) {
        currentGroupIndex = groupIndex
        self.stories = stories
        currentIndex = direction == .forward ? 0 : max(stories.count - 1, 0)
        elapsedTime = 0
        playbackStartTime = nil
        rebuildProgressViews()

        UIView.transition(
            with: collectionView,
            duration: 0.2,
            options: [.transitionCrossDissolve, .allowAnimatedContent],
            animations: {
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.layoutIfNeeded()
                self.collectionView.setContentOffset(
                    CGPoint(
                        x: self.collectionView.bounds.width * CGFloat(self.currentIndex),
                        y: 0
                    ),
                    animated: false
                )
            },
            completion: { [weak self] _ in
                guard let self else { return }
                self.loadingIndicator.stopAnimating()
                self.updateMediaLoadingState()
                self.restartPlayback()
                self.removePauseReason(.loading)
            }
        )
    }

    func finishAtGroupBoundary(_ direction: NavigationDirection) {
        loadingIndicator.stopAnimating()
        pendingGroupIndex = nil

        switch direction {
        case .forward:
            dismissAction()
            removePauseReason(.loading)
        case .backward:
            restartPlayback()
            removePauseReason(.loading)
        }
    }

}

// MARK: - Actions
private extension MainStoryViewController {
    @objc func handleHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            pressStartTime = CACurrentMediaTime()
            pressStartLocation = gestureRecognizer.location(in: view)
            pressMoved = false
            addPauseReason(.hold)

        case .changed:
            let location = gestureRecognizer.location(in: view)
            let movement = hypot(
                location.x - pressStartLocation.x,
                location.y - pressStartLocation.y
            )
            pressMoved = pressMoved || movement > 12

        case .ended:
            let pressDuration = CACurrentMediaTime() - pressStartTime
            let shouldNavigate = pressDuration < 0.25
                && !pressMoved
                && pendingItemIndex == nil
                && !pauseReasons.contains(.loading)
                && !pauseReasons.contains(.transition)

            removePauseReason(.hold)

            guard shouldNavigate else { return }
            removePauseReason(.loadFailure)
            if pressStartLocation.x < view.bounds.midX {
                moveBackward()
            } else {
                moveForward()
            }

        case .cancelled, .failed:
            removePauseReason(.hold)

        default:
            break
        }
    }

    @objc func applicationWillResignActive() {
        addPauseReason(.inactive)
    }

    @objc func applicationDidBecomeActive() {
        removePauseReason(.inactive)
    }

    @objc func dismissAction() {
        addPauseReason(.hidden)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MainStoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MainStoryPageCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? MainStoryPageCollectionViewCell else {
            return UICollectionViewCell()
        }

        let groupIndex = currentGroupIndex
        if indexPath.item == currentIndex {
            addPauseReason(.mediaLoading)
        }
        cell.configure(with: stories[indexPath.item]) { [weak self] in
            guard let self,
                  self.currentGroupIndex == groupIndex,
                  self.currentIndex == indexPath.item else { return }
            self.removePauseReason(.mediaLoading)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MainStoryViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard indexPath.item == currentIndex else { return }
        updateMediaLoadingState()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        completeItemNavigation()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MainStoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        var touchedView = touch.view
        while let view = touchedView {
            if view is UIControl {
                return false
            }
            touchedView = view.superview
        }
        return true
    }
}

private final class MainStoryProgressView: UIView {

    private let fillView = UIView()

    var progress: CGFloat = 0 {
        didSet {
            progress = min(max(progress, 0), 1)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.35)
        clipsToBounds = true
        addSubview(fillView)
        fillView.backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        fillView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width * progress,
            height: bounds.height
        )
    }
}

private final class MainStoryPageCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "MainStoryPageCollectionViewCell"

    private let bottomGradientLayer = CAGradientLayer()
    private var imageRequestID = UUID()
    private(set) var isImageLoadFinished = false

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let bottomGradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .natural
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .natural
        label.numberOfLines = 0
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageRequestID = UUID()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        isImageLoadFinished = false
        titleLabel.text = nil
        descriptionLabel.text = nil
    }

    func configure(with story: StoryDetail, imageLoadCompletion: @escaping () -> Void) {
        let hasTitle = story.title?.isEmpty == false
        let hasDescription = story.description?.isEmpty == false

        titleLabel.text = story.title
        titleLabel.isHidden = !hasTitle
        descriptionLabel.text = story.description
        descriptionLabel.isHidden = !hasDescription
        textStackView.isHidden = !hasTitle && !hasDescription

        let requestID = UUID()
        imageRequestID = requestID
        isImageLoadFinished = false

        guard let imageURL = story.imageUrl,
              !imageURL.isEmpty,
              let url = URL(string: imageURL) else {
            imageView.image = nil
            isImageLoadFinished = true
            imageLoadCompletion()
            return
        }

        imageView.sd_setImage(
            with: url,
            placeholderImage: nil,
            options: []
        ) { [weak self] _, _, _, _ in
            DispatchQueue.main.async {
                guard let self, self.imageRequestID == requestID else { return }
                self.isImageLoadFinished = true
                imageLoadCompletion()
            }
        }
    }

    private func setupUI() {
        contentView.backgroundColor = .black
        contentView.addSubview(imageView)
        contentView.addSubview(bottomGradientView)
        contentView.addSubview(textStackView)

        bottomGradientLayer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor
        ]
        bottomGradientLayer.locations = [0, 1]
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            bottomGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomGradientView.heightAnchor.constraint(equalToConstant: 260),

            textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            textStackView.bottomAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,
                constant: -40
            )
        ])
    }
}
