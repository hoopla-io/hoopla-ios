//
//  SessionDataProvider.swift
//  qahvazor-client
//

import UIKit

final class SessionDataProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    var onLogoutTapped: ((UserDeviceSession) -> Void)?

    private var items = [UserDeviceSession]()
    private var currentSessionID: Int?

    var isEmpty: Bool {
        items.isEmpty
    }

    func update(items: [UserDeviceSession], currentSessionID: Int?) {
        self.items = items
        self.currentSessionID = currentSessionID
        tableView.reloadData()
    }

    func remove(sessionID: Int) {
        items.removeAll { $0.id == sessionID }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SessionTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? SessionTableViewCell else {
            return UITableViewCell()
        }

        let session = items[indexPath.row]
        cell.configure(with: session, isCurrent: session.id == currentSessionID)
        cell.onLogoutTapped = { [weak self] in
            self?.onLogoutTapped?(session)
        }
        return cell
    }
}
