//
//  MainViewController.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import Haptica

class MainViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    // MARK: - Root View
    typealias RootView = MainView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: MainCoordinator?
    let viewModel = MainViewModel()
    let profileViewModel = ProfileViewModel()
    let locationManager = LocationManager()
    
    // MARK: - Attributes
    var dataProvider: MainDataProvider?
    var categoryDataProvider: MainCategoryDataProvider?
    var storiesDataProvider: MainStoriesDataProvider?
    var activeOrderDataProvider: ActiveOrderDataProvider?
    var selectedStoryID: Int?
    let locationAccessContainerView = UIView()
    
    // MARK: - Life cycle
    override func loadView() {
        view = MainView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        viewModel.getStories()
        viewModel.getCategories()
        viewModel.getList()
        checkAccessLocation()
        checkUniversalLink()
        checkUpdate()
        
        if UserDefaults.standard.isAuthed() {
            viewModel.getPendingFeedback()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestLocationPermission()
        if UserDefaults.standard.isAuthed() {
            viewModel.getActiveOrders()
            profileViewModel.getMe()
        } else {
            activeOrderDataProvider?.items = []
        }
        
        guard Purchase.isPurchased else { return }
        Purchase.isPurchased = false
        tabBarController?.selectedIndex = 2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
// MARK: - Networking
extension MainViewController: MainViewModelProtocol {
    func didFinishFetch(data: [Stories]) {
        storiesDataProvider?.items = data
    }
    
    func didFinishFetch(data: Stories) {
        let pendingStoryID = selectedStoryID
        selectedStoryID = nil

        guard let groups = storiesDataProvider?.items,
              let selectedID = data.id ?? pendingStoryID,
              let selectedGroupIndex = groups.firstIndex(where: { $0.id == selectedID }),
              let stories = data.items,
              !stories.isEmpty else {
            addErrorAlertView(error: (.invalidData, nil), completion: nil)
            return
        }

        coordinator?.presentStoryDetailVC(
            groups: groups,
            selectedGroupIndex: selectedGroupIndex,
            initialGroup: data,
            storyLoader: { [weak self] id, completion in
                guard let self else {
                    completion(.Error(.requestFailed))
                    return
                }
                self.viewModel.getStoryDetail(
                    id: id,
                    showsActivityIndicator: false,
                    completion: completion
                )
            }
        )
    }
    
    func didFinishFetch(data: [Categories]) {
        categoryDataProvider?.items = data
    }
    
    func didFinishFetch(data: [Shop]) {
        dataProvider?.items = data
        view().collectionViewHeight.constant = CGFloat(data.count) * (dataProvider?.collectionView.dynamicHeight(type: .company) ?? 320)
        view().shopCollectionView.layoutIfNeeded()
        
        if ShopDataCache.shops.isEmpty {
            ShopDataCache.shops = data
        }
    }

    func didFinishFetch(data: [OrderHistory]) {
        activeOrderDataProvider?.items = data
    }
    
    func didFinishFetch(feedback: OrderHistory) {
        coordinator?.presentReviewVC(data: feedback)
    }
}
// MARK: - Networking
extension MainViewController: ProfileViewModelProtocol {
    func didFinishFetch(data: Account) {
        Cashbeck.balance = data.balance ?? 0
    }
}
// MARK: - Other funcs
extension MainViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        profileViewModel.delegate = self
        navigationItem.title = "home".localized

        setupNavigationBar()
        view().cameraButton.addTarget(self, action: #selector(scannerAction), for: .touchUpInside)
        
        let storiesDataProvider = MainStoriesDataProvider()
        storiesDataProvider.collectionView = view().storiesCollectionView
        storiesDataProvider.delegate = self
        self.storiesDataProvider = storiesDataProvider

        let activeOrderDataProvider = ActiveOrderDataProvider(viewController: self)
        activeOrderDataProvider.collectionView = view().activeOrderCollectionView
        self.activeOrderDataProvider = activeOrderDataProvider

        let dataProvider = MainDataProvider(viewController: self)
        dataProvider.collectionView = view().shopCollectionView
        self.dataProvider = dataProvider
        
        let categoryDataProvider = MainCategoryDataProvider()
        categoryDataProvider.collectionView = view().categoryCollectionView
        categoryDataProvider.delegate = self
        self.categoryDataProvider = categoryDataProvider
        
        let refershControl = UIRefreshControl()
        refershControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        view().scrollView.refreshControl = refershControl
        
        addObservers()
    }

    @objc private func scannerAction() {
        coordinator?.pushToScannerVC(viewController: self)
    }
    
    func addObservers() {
        Notification.Name.universalLink.onPost { [weak self] notification in
            guard let `self` = self else { return }
            let shopId = notification.userInfo?[UserInfoName.shopId.rawValue] as? Int
            actionDeepLink(shopId: shopId)
        }
    }
    
    func checkUniversalLink() {
        actionDeepLink(shopId: UniversalLink.shopId)
    }
    
    @objc func refresh(sender: UIRefreshControl? = nil) {
        viewModel.getList()
        if UserDefaults.standard.isAuthed() {
            viewModel.getActiveOrders()
        }
        locationManager.requestLocationPermission()
        
        DispatchQueue.main.async {
            sender?.endRefreshing()
        }
    }
    
    private func setupNavigationBar() {
        view().searchButton.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        view().notificationButton.addTarget(self, action: #selector(notifitcationAction), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: view().notificationButton), UIBarButtonItem(customView: view().searchButton)]
    }
    
    @objc func searchAction() {
        coordinator?.startSearch()
    }
    
    @objc func notifitcationAction() {
        coordinator?.pushToNotificationsVC()
    }
    
    private func checkAccessLocation() {
        locationManager.requestLocationAuthorization {[weak self] status in
            guard let self else { return }
            switch status {
            case .notDetermined:
                print("Not determined")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Authorized Always")
            default:
                print("Unknown status")
                self.setupLocationAccessView()
            }
        }
    }
    
    func actionDeepLink(shopId: Int?) {
        if let shopId = shopId {
            self.tabBarController?.selectedIndex = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.coordinator?.pushToShopDetail(id: shopId, item: nil)
            }
        }
        UniversalLink.clear()
    }
}
// MARK: - CategoryDataProviderDelegate
extension MainViewController: MainCategoryDataProviderDelegate {
    func didSelectCategory(at index: Int, category: Categories) {
        viewModel.getList(categoryId: category.id)
    }
    
    func didDeselectCategory() {
        viewModel.getList()
    }
}

// MARK: - StoriesDataProviderDelegate
extension MainViewController: MainStoriesDataProviderDelegate {
    func didSelectStory(_ story: Stories) {
        guard !isLoading, let id = story.id else { return }
        isLoading = true
        selectedStoryID = id
        viewModel.getStoryDetail(id: id)
    }
}

//MARK: - SetupLocationAlertView
extension MainViewController {
    func setupLocationAccessView() {
        configureLocationAccessContainer()
        setupBlurEffect()
        setupLocationLabel()
        setupCloseButton()
    }
    
    private func configureLocationAccessContainer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(accessLocationViewAction))
        locationAccessContainerView.addGestureRecognizer(tap)
        locationAccessContainerView.layer.cornerRadius = 10
        locationAccessContainerView.layer.cornerCurve = .continuous
        locationAccessContainerView.clipsToBounds = true
        
        view.addSubview(locationAccessContainerView)
        locationAccessContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationAccessContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            locationAccessContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            locationAccessContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            locationAccessContainerView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = locationAccessContainerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        locationAccessContainerView.addSubview(blurEffectView)
    }
    
    private func setupLocationLabel() {
        let label = UILabel()
        label.halfTextColorChange(fullText: "askAccessLocation".localized, changeText: "askAccess".localized, color: .appColor(.green))
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        locationAccessContainerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: locationAccessContainerView.leftAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: locationAccessContainerView.rightAnchor, constant: -50),
            label.topAnchor.constraint(equalTo: locationAccessContainerView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: locationAccessContainerView.bottomAnchor, constant: -10)
        ])
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton()
        closeButton.setImage(UIImage.appImage(.closeCircle), for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        locationAccessContainerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.rightAnchor.constraint(equalTo: locationAccessContainerView.rightAnchor, constant: -10),
            closeButton.topAnchor.constraint(equalTo: locationAccessContainerView.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: locationAccessContainerView.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func accessLocationViewAction() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
        Haptic.impact(.medium).generate()
        closeAction()
    }
    
    @objc func closeAction() {
        UIView.animate(withDuration: 0.2) {
            self.locationAccessContainerView.alpha = 0
        }
    }
}

//MARK: - Scanner
extension MainViewController: ScannerViewControllerDelegate {
    func didFoundCode(code: String) {
        let separated = code.components(separatedBy: Symbols.slash.rawValue)
        separated.forEach { string in
            if string == UniversalLinksType.shop.rawValue {
                if let id = code.extractID() {
                    self.actionDeepLink(shopId: id)
                }
            }
        }
    }
}

// MARK: - CheckToNewVersion
extension MainViewController {
    func checkUpdate() {
        DispatchQueue.global().async {
            do {
                let hasUpdate = try self.isUpdateAvailable()
                if hasUpdate {
                    DispatchQueue.main.async {
                        self.popupUpdateDialogue()
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
              let currentVersion = info["CFBundleShortVersionString"] as? String,
              let url = URL(string: MainConstants.itunesPath.rawValue) else {
            throw VersionError.invalidBundleInfo
        }
        
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let newVersion = result["version"] as? String {
            return !(currentVersion >= newVersion)
        }
        throw VersionError.invalidResponse
    }
    
    func popupUpdateDialogue() {
        let alert = UIAlertController(title: "updateAvailable".localized, message: "updateMessage".localized, preferredStyle: UIAlertController.Style.alert)
        
        let updateAction = UIAlertAction(title: "update".localized, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: MainConstants.appstorePath.rawValue),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        alert.addAction(updateAction)
        self.present(alert, animated: true, completion: nil)
    }
}
