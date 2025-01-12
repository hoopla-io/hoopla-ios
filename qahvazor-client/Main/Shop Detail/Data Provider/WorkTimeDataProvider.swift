//
//  WorkTimeDataProvider.swift
//  qahvazor-client
//
//  Created by Alphazet on 09/01/25.
//

import UIKit

final class WorkTimeDataProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    internal var items = [WorkHour]() {
        didSet {
            tableView.reloadData()
        }
    }
    var cachedPosition = Dictionary<IndexPath,CGPoint>()
    
    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    // MARK: - Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                    UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = "\(items[indexPath.row].openAt ?? "") - \(items[indexPath.row].closeAt ?? "")  \(items[indexPath.row].weekDay?.localized ?? "")"
        cell.imageView?.image = UIImage(systemName: "clock")
        cell.imageView?.tintColor = .label
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
}

