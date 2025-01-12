//
//  HistoryDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 12/01/25.
//

import UIKit

final class HistoryDataProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    internal var items = [OrderHistory]() {
        didSet {
            self.tableView.reloadData()
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let vc = viewController as? QRViewController else { return }
//        if indexPath.row == items.count - 1 && vc.totalItems > items.count {
//        vc.nextPage()
//    }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

