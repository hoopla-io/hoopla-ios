//
//  HistoryDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 12/01/25.
//

import UIKit
import SkeletonView

final class HistoryDataProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.showAnimatedSkeleton()
        }
    }
    
    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    var items = [OrderHistory]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.hideSkeleton()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    // MARK: - Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryTableViewCell.defaultReuseIdentifier, for: indexPath) as? OrderHistoryTableViewCell else { return UITableViewCell() }
        cell.item = items[indexPath.row]
        cell.viewController = viewController
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = viewController as? HistoryViewController else { return }
        vc.coordinator?.pushToHistoryDetailVC(item: items[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let vc = viewController as? HistoryViewController else { return }
        if indexPath.row == items.count - 1 && vc.totalItems > items.count {
            vc.currentPage += 1
            vc.viewModel.getOrderHistoryList(page: vc.currentPage)
        }
    }
}

//MARK: - SkeletonTableViewDataDource
extension HistoryDataProvider: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return OrderHistoryTableViewCell.defaultReuseIdentifier
    }
}
