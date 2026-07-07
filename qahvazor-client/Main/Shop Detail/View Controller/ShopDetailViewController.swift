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
//    var pictureDataProvider: PhotoDataProvider?
    var workTimeDataProvider: WorkTimeDataProvider?
    var categoryDataProvider: CategoryListDataProvider?
    var secondCategoryDataProvider: CategoryListDataProvider?
    var coffeeDataProvider: CoffeeListDataProvider?
    var socialDataProvider: SocialDataProvider?
    // MARK: - Attributes
    var distance: Double? {
        didSet {
//            view().addressButton.setTitle("address".localized + " - " + (distance?.formatDistance() ?? ""), for: .normal)
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
    var isOpen = true {
        didSet {
            view().closedLabel.isHidden = isOpen
        }
    }
    private var currentSelectedSection = 0
    private var isScrollingFromCategoryTap = false
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
        prepareForTransition()
        
        guard let shopId else { return }
        viewModel.getShopInfo(shopId: shopId)
        viewModel.getDrinks(shopId: shopId)
    }
    
}
// MARK: - Networking
extension ShopDetailViewController: ShopDetailViewModelProtocol {
    func didFinishFetch(data: Shop) {
        self.data = data
        
        view().titleLabel.text = data.name
        if let pictures = data.pictures {
            view().imageView.setImage(with: pictures.first?.pictureUrl)
//            pictureDataProvider?.items = pictures
            view().pageControll.numberOfPages = pictures.count
        }
        var socialsData: [SocialMedia] = []
        
        if let _ = data.phoneNumbers?.first {
            view().phoneNumberButton.isHidden = false
        }
        if let socials = data.urls {
            socialsData += socials
        }
        socialDataProvider?.items = socialsData
        view().socialStackView.isHidden = socialsData.isEmpty
        
        self.workTimeData = data.workingHours
    }
    
    func didFinishFetch(drinks: [Categories]) {
        let showCategories = drinks.count > 1
        view().categoryListCollectionView.isHidden = !showCategories
        
        if showCategories {
            categoryDataProvider?.items = drinks
            secondCategoryDataProvider?.items = drinks
        }
        
        coffeeDataProvider?.items = drinks
        view().coffeeCollectionHeight.constant = coffeeDataProvider?.collectionView.collectionViewLayout.collectionViewContentSize.height ?? 100
        view().coffeeListCollectionView.layoutIfNeeded()
    }
}

// MARK: - Other funcs
extension ShopDetailViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        view().scrollView.delegate = self
        
//        let pictureDataProvider = PhotoDataProvider(viewController: self)
//        pictureDataProvider.collectionView = view().collectionView
//        self.pictureDataProvider = pictureDataProvider
//        
        let categoryDataProvider = CategoryListDataProvider()
        categoryDataProvider.delegate = self
        categoryDataProvider.collectionView = view().categoryListCollectionView
        self.categoryDataProvider = categoryDataProvider
        
        let secondCategoryDataProvider = CategoryListDataProvider()
        secondCategoryDataProvider.delegate = self
        secondCategoryDataProvider.collectionView = view().secondCategoryListCollectionView
        self.secondCategoryDataProvider = secondCategoryDataProvider
        
        let coffeeDataProvider = CoffeeListDataProvider(viewController: self)
        coffeeDataProvider.collectionView = view().coffeeListCollectionView
        self.coffeeDataProvider = coffeeDataProvider
        
        let socialDataProvider = SocialDataProvider(viewController: self)
        socialDataProvider.collectionView = view().socialListCollectionView
        self.socialDataProvider = socialDataProvider
        
        let workTimeDataProvider = WorkTimeDataProvider()
        workTimeDataProvider.tableView = view().tableView
        self.workTimeDataProvider = workTimeDataProvider
        
        view().imageView.translatesAutoresizingMaskIntoConstraints = false
        view().imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true

    }
    
    private func prepareForTransition() {
        guard let item = data, let shopId = item.shopId else { return }
        if let posterUrl = item.pictureUrl {
            view().imageView.sd_setImage(with: URL(string: posterUrl), placeholderImage: view().imageView.image)
        }
        view().titleLabel.text = item.name
        view().titleLabel.hero.id = HeroType.title.rawValue + String(shopId)
        view().imageView.hero.id = HeroType.imageView.rawValue + String(shopId)
        view().hero.id = HeroType.view.rawValue + String(shopId)
        view().hero.modifiers = [.fade]
    }
    
    func nextAction(item: Drinks) {
        guard isOpen else {
            showErrorAlert(message: "closed".localized)
            return
        }
        guard UserDefaults.standard.isAuthed() else {
            tabBarController?.selectedIndex = 3
            return
        }
        guard let canAcceptOrders = data?.canAcceptOrders, canAcceptOrders else {
            showWarningAlert(message: "cantOrder".localized)
            return
        }
        coordinator?.pushToConfirmOrderVC(viewController: self, data: item, shop: data)
    }
    
    private func showWorkTime() {
        guard let workTimeData else {
            view().workTimeStackView.isHidden = true
            return
        }
        view().workTimeStackView.isHidden = workTimeData.isEmpty
        let currentWeekDay = DateFormatter.string(formatter: .weekDay).lowercased()
        if isExpanded {
            workTimeDataProvider?.items = workTimeData
        } else {
            for i in workTimeData {
                if i.weekDay?.lowercased() == currentWeekDay {
                    let item = WorkHour(closeAt: "\(i.closeAt ?? "")", openAt: "\(i.openAt ?? "")", weekDay: "today".localized)
                    workTimeDataProvider?.items = [item]
                    isOpen = i.isOpen()
                    view().workingHoursButton.setTitle("\(i.openAt ?? "") - \(i.closeAt ?? "")", for: .normal)
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

// MARK: - UIScrollViewDelegate
extension ShopDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrollingFromCategoryTap = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == view().scrollView else { return }
        
        let categoryFrame = view().categoryListCollectionView.convert(view().categoryListCollectionView.bounds, to: view())
        let isHidden = categoryFrame.maxY > view().safeAreaInsets.top
        navigationItem.title = isHidden ? "" : data?.name
        
        guard let items = categoryDataProvider?.items, items.count > 1 else { return }
        
        UIView.animate(withDuration: 0.2) { [self] in
            view().secondCategoryListCollectionView.alpha = isHidden ? 0 : 1
        }
        
        // Skip auto-selection while scrolling from a category tap
        guard !isScrollingFromCategoryTap else { return }
        
        // Auto-select category based on visible coffee section
        let coffeeCollectionView = view().coffeeListCollectionView!
        let coffeeOriginY = coffeeCollectionView.frame.origin.y
        let visibleY = scrollView.contentOffset.y - coffeeOriginY
        
        var newSection = 0
        for section in 0..<items.count {
            let indexPath = IndexPath(item: 0, section: section)
            guard let attributes = coffeeCollectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) else { continue }
            if attributes.frame.origin.y <= visibleY + 10 {
                newSection = section
            } else {
                break
            }
        }
        
        // Only update selection when the section actually changes
        guard newSection != currentSelectedSection else { return }
        currentSelectedSection = newSection
        
        let categoryIndexPath = IndexPath(item: newSection, section: 0)
        categoryDataProvider?.collectionView.selectItem(at: categoryIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        secondCategoryDataProvider?.collectionView.selectItem(at: categoryIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

// MARK: - CategoryListDataProviderDelegate
extension ShopDetailViewController: CategoryListDataProviderDelegate {
    func didSelectCategory(at index: Int) {
        let categoryIndexPath = IndexPath(item: index, section: 0)
        currentSelectedSection = index
        isScrollingFromCategoryTap = true
        
        // Sync selection on both category lists
        categoryDataProvider?.collectionView.selectItem(at: categoryIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        secondCategoryDataProvider?.collectionView.selectItem(at: categoryIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        // Scroll coffee list to the selected section
        let sectionIndexPath = IndexPath(item: 0, section: index)
        guard let attributes = view().coffeeListCollectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: sectionIndexPath) else {
            isScrollingFromCategoryTap = false
            return
        }
        let yPosition = view().coffeeListCollectionView.frame.origin.y + attributes.frame.origin.y
        view().scrollView.setContentOffset(CGPoint(x: 0, y: yPosition), animated: true)
    }
}
