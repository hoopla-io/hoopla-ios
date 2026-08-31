//
//  SessionView.swift
//  qahvazor-client
//

import UIKit

final class SessionView: CustomView {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(SessionTableViewCell.self, forCellReuseIdentifier: SessionTableViewCell.reuseIdentifier)
        return tableView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "noActiveSessions".localized
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setEmptyState(isVisible: Bool) {
        emptyStateLabel.isHidden = !isVisible
    }
}

private extension SessionView {
    func setupUI() {
        addSubview(tableView)
        addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyStateLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }
}
