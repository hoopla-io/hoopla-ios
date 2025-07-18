//
//  ShopDetailViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 09/01/25.
//

import UIKit

class ShopDetailViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = ShopDetailView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: MainCoordinator?
    let viewModel = ShopDetailViewModel()
    //MARK: - Data Providers
    var pictureDataProvider: PhotoDataProvider?
    var workTimeDataProvider: WorkTimeDataProvider?
    var coffeeDataProvider: CoffeeListDataProvider?
    var socialDataProvider: SocialDataProvider?
    // MARK: - Attributes
    var distance: Double? {
        didSet {
            view().addressButton.setTitle("address".localized + " - " + (distance?.formatDistance() ?? ""), for: .normal)
        }
    }
    var shopId: Int?
    var data: Shop?
    var isExpanded: Bool = false
    var workTimeData: [WorkHour]? {
        didSet {
            showWorkTime()
        }
    }
    
    // MARK: - Actions
    @IBAction func addressButtonAction(_ sender: Any) {
        guard let lat = data?.location?.lat, let lng = data?.location?.lng else { return }
        openMaps(latitude: lat, longitude: lng, title: "maps".localized)
    }

    @IBAction func showHoursAction(_ sender: Any) {
        isExpanded.toggle()
        showWorkTime()
        view().tableViewHeight.constant = isExpanded ? 210 : 30
        view().showMoreButton.setTitle(isExpanded ? "showLess".localized : "showMore".localized, for: .normal)
        view().layoutIfNeeded()
    }
    
    @IBAction func callButtonAction(_ sender: Any) {
        guard let phoneNumbers = data?.phoneNumbers else { return }
        if phoneNumbers.count == 1 {
            self.callAction(phoneNumber: phoneNumbers.first?.phoneNumber)
        } else {
            showCallPhoneActionSheet(items: phoneNumbers) { phoneNumber in
                self.callAction(phoneNumber: phoneNumber)
            }
        }
    }
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        
        guard let shopId else { return }
        viewModel.getShopInfo(shopId: shopId)
    }
    
}
// MARK: - Networking
extension ShopDetailViewController: ShopDetailViewModelProtocol {
    func didFinishFetch(data: Shop) {
        self.data = data
        
        navigationItem.title = data.name
        if let pictures = data.pictures {
            pictureDataProvider?.items = pictures
            view().pageControll.numberOfPages = pictures.count
        }
        var socialsData: [SocialMedia] = []
        
        if let drinks = data.drinks {
            coffeeDataProvider?.items = drinks
            view().coffeeCollectionHeight.constant = coffeeDataProvider?.collectionView.collectionViewLayout.collectionViewContentSize.height ?? 100
            view().coffeeListCollectionView.layoutIfNeeded()
        }
        if let phone = data.phoneNumbers?.first {
            let phoneNumberString = phone.phoneNumber?.displayPhone() ?? ""
            view().phoneNumberButton.setTitle("phoneNumber".localized + " \(phoneNumberString)", for: .normal)
            view().phoneNumberButton.isHidden = false
        }
        if let socials = data.urls {
            socialsData += socials
        }
        socialDataProvider?.items = socialsData
        self.workTimeData = data.workingHours
    }
}

// MARK: - Other funcs
extension ShopDetailViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        
        let pictureDataProvider = PhotoDataProvider(viewController: self)
        pictureDataProvider.collectionView = view().collectionView
        self.pictureDataProvider = pictureDataProvider
        
        let coffeeDataProvider = CoffeeListDataProvider(viewController: self)
        coffeeDataProvider.collectionView = view().coffeeListCollectionView
        self.coffeeDataProvider = coffeeDataProvider
        
        let socialDataProvider = SocialDataProvider(viewController: self)
        socialDataProvider.collectionView = view().socialListCollectionView
        self.socialDataProvider = socialDataProvider
        
        let workTimeDataProvider = WorkTimeDataProvider()
        workTimeDataProvider.tableView = view().tableView
        self.workTimeDataProvider = workTimeDataProvider
    }
    
    func nextAction(item: Drinks) {
        guard UserDefaults.standard.isAuthed() else {
            tabBarController?.selectedIndex = 2
            return
        }
        guard let canAcceptOrders = data?.canAcceptOrders, canAcceptOrders else {
            showWarningAlert(message: "cantOrder".localized)
            return
        }
        coordinator?.pushToConfirmOrderVC(viewController: self, data: item, shop: data)
    }
    
    private func showWorkTime() {
        guard let workTimeData else { return }
        let currentWeekDay = DateFormatter.string(formatter: .weekDay).lowercased()
        if isExpanded {
            workTimeDataProvider?.items = workTimeData
        } else {
            for i in workTimeData {
                if i.weekDay?.lowercased() == currentWeekDay {
                    workTimeDataProvider?.items = [WorkHour(closeAt: "\(i.closeAt ?? "")", openAt: "\(i.openAt ?? "")", weekDay: "today".localized)]
                    break
                }
            }
        }
    }
    
    func callAction(phoneNumber: String?) {
        guard let phoneNumber else { return }
        if let url = URL(string: "tel://+\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Phone call not supported on this device")
            }
        }
    }
    
    func openMaps(latitude: Double, longitude: Double, title: String?) {
        let application = UIApplication.shared
        let coordinate = "\(latitude),\(longitude)"
        let encodedTitle = title?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let handlers = [
            ("Yandex Maps", "yandexmaps://maps.yandex.ru/?pt=\(longitude),\(latitude)"),
            ("Apple Maps".localized, "http://maps.apple.com/?q=\(encodedTitle)&ll=\(coordinate)"),
            ("Yandex Navigator", "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)"),
            ("2gis Map", "dgis://2gis.ru/routeSearch/rsType/car/to/\(longitude),\(latitude)")
        ]
        
            .compactMap { (name, address) in URL(string: address).map { (name, $0) } }
            .filter { (_, url) in application.canOpenURL(url) }

        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
            handlers.forEach { (name, url) in
                alert.addAction(UIAlertAction(title: name, style: .default) { _ in
                    application.open(url, options: [:])
                })
            }
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    func didScrollPicture(offset: CGFloat) {
        guard !offset.isNaN else { return }
        view().pageControll.currentPage = Int(offset)
    }
}


