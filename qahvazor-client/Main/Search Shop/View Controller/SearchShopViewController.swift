//
//  SearchShopViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 11/07/26.
//

import UIKit
import SkeletonView

final class SearchShopViewController: UIViewController, ViewSpecificController, AlertViewController {
    typealias RootView = SearchShopView

    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    weak var coordinator: MainCoordinator?

    private let partnerId: Int?
    private let partnerName: String?
    private let viewModel = SearchShopViewModel()
    private var shops: [Shop] = []

    init(partner: Company) {
        partnerId = partner.id
        partnerName = partner.name
        super.init(nibName: nil, bundle: nil)
    }

    init(partnerId: Int, partnerName: String? = nil) {
        self.partnerId = partnerId
        self.partnerName = partnerName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SearchShopView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = partnerName
        viewModel.delegate = self
        view().collectionView.dataSource = self
        view().collectionView.delegate = self

        guard let partnerId else { return }
        viewModel.getShops(partnerId: partnerId)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view().collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension SearchShopViewController: SearchShopViewModelProtocol {
    func didFinishFetch(shops: [Shop]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.shops = shops
            self.view().collectionView.reloadData()
            self.view().collectionView.checkEmpty(items: shops, type: .search)
        }
    }
}

extension SearchShopViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shops.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CompanyCollectionViewCell.defaultReuseIdentifier,
            for: indexPath
        ) as? CompanyCollectionViewCell else { return UICollectionViewCell() }
        cell.item = shops[indexPath.item]
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.itemSize(type: .company)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shop = shops[indexPath.item]
        guard let id = shop.shopId else { return }
        coordinator?.pushToShopDetail(id: id, item: shop)
    }
}
