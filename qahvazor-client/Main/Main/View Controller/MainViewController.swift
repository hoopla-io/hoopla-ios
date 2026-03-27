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
    let locationAccessContainerView = UIView()
    
    //MARK: - Actions
    @IBAction func scannerAction(_ sender: Any) {
        coordinator?.pushToScannerVC(viewController: self)
    }
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        viewModel.getList()
        checkAccessLocation()
        checkUniversalLink()
        checkUpdate()
        viewModel.getPendingFeedback()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestLocationPermission()
        if UserDefaults.standard.isAuthed() {
            profileViewModel.getMe()
        }
        
        guard Purchase.isPurchased else { return }
        Purchase.isPurchased = false
        tabBarController?.selectedIndex = 2
    }
}
// MARK: - Networking
extension MainViewController: MainViewModelProtocol {
    func didFinishFetch(data: [Shop]) {
        dataProvider?.items = data
        ShopDataCache.shops = data
        view().collectionViewHeight.constant = CGFloat(data.count) * (dataProvider?.collectionView.dynamicHeight(type: .company) ?? 320)
        view().shopCollectionView.layoutIfNeeded()
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

        setupSearchBar()
        setupNavigationBar()
        
        let dataProvider = MainDataProvider(viewController: self)
        dataProvider.collectionView = view().shopCollectionView
        self.dataProvider = dataProvider
        
        let refershControl = UIRefreshControl()
        refershControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        view().scrollView.refreshControl = refershControl
        
        addObservers()
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
        locationManager.requestLocationPermission()
        
        DispatchQueue.main.async {
            sender?.endRefreshing()
        }
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.backgroundColor = UIColor.appColor(.secondBackground)
        searchController.searchBar.updateHeight(height: 44)
        searchController.searchBar.placeholder = "placeholderSearch".localized
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupNavigationBar() {
        view().notificationButton.addTarget(self, action: #selector(notifitcationAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: view().notificationButton)
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
                self.coordinator?.pushToShopDetail(id: shopId, name: "")
            }
        }
        UniversalLink.clear()
    }
}
// MARK: - Delegate
extension MainViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        coordinator?.startSearch()
        return true
    }
}

//MARK: - Scroll to up
extension MainViewController: TabBarReselectHandling {
    func handleReselect() {
//        guard let items = dataProvider?.items, !items.isEmpty else { return }
//        view().collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
}

//MARK: - SetupLocationAlertView
extension MainViewController {
    func setupLocationAccessView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(accessLocationViewAction))
        locationAccessContainerView.addGestureRecognizer(tap)
        locationAccessContainerView.layer.cornerRadius = 10
        locationAccessContainerView.layer.cornerCurve = .continuous
        locationAccessContainerView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = locationAccessContainerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let label = UILabel()
        label.halfTextColorChange(fullText: "askAccessLocation".localized, changeText: "askAccess".localized, color: .appColor(.green))
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        let closeButton = UIButton()
        closeButton.setImage(UIImage.appImage(.closeCircle) , for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        self.view.addSubview(locationAccessContainerView)
        locationAccessContainerView.addSubview(blurEffectView)
        locationAccessContainerView.translatesAutoresizingMaskIntoConstraints = false
        locationAccessContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 18).isActive = true
        locationAccessContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -18).isActive = true
        locationAccessContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        locationAccessContainerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        locationAccessContainerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: locationAccessContainerView.leftAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(equalTo: locationAccessContainerView.rightAnchor, constant: -50).isActive = true
        label.bottomAnchor.constraint(equalTo: locationAccessContainerView.bottomAnchor, constant: -10).isActive = true
        label.topAnchor.constraint(equalTo: locationAccessContainerView.topAnchor, constant: 10).isActive = true
        
        locationAccessContainerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.rightAnchor.constraint(equalTo: locationAccessContainerView.rightAnchor, constant: -10).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: locationAccessContainerView.bottomAnchor, constant: 0).isActive = true
        closeButton.topAnchor.constraint(equalTo: locationAccessContainerView.topAnchor, constant: 0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
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
