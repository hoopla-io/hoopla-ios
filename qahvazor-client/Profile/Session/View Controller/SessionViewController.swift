//
//  SessionViewController.swift
//  qahvazor-client
//

import UIKit

final class SessionViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    typealias RootView = SessionView

    var customSpinnerView = CustomSpinnerView()
    var isLoading = false

    private let viewModel = SessionViewModel()
    private let dataProvider = SessionDataProvider()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func loadView() {
        view = SessionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.getSessions()
    }
}

extension SessionViewController: SessionViewModelProtocol {
    func didFinishFetch(sessions: [UserDeviceSession]) {
        let currentSessionID = resolveCurrentSessionID(in: sessions)
        dataProvider.update(items: sessions, currentSessionID: currentSessionID)
        view().setEmptyState(isVisible: sessions.isEmpty)
    }

    func didFinishRevoke(sessionID: Int) {
        dataProvider.remove(sessionID: sessionID)
        view().setEmptyState(isVisible: dataProvider.isEmpty)
        showSuccessAlert(message: "sessionRevoked".localized)
    }

    func didFinishSessionRequest() {
        view().tableView.refreshControl?.endRefreshing()
    }
}

private extension SessionViewController {
    func setupUI() {
        viewModel.delegate = self
        dataProvider.tableView = view().tableView
        dataProvider.onLogoutTapped = { [weak self] session in
            self?.showRevokeConfirmation(for: session)
        }
        navigationItem.title = "sessionsTitle".localized
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .appColor(.mainColor)
        refreshControl.addTarget(self, action: #selector(refreshSessions), for: .valueChanged)
        view().tableView.refreshControl = refreshControl
    }

    @objc func refreshSessions() {
        viewModel.getSessions(showsLoader: false)
    }

    func showRevokeConfirmation(for session: UserDeviceSession) {
        let deviceName = session.deviceName?.nilIfBlank ?? "unknownDevice".localized
        let message = String(format: "sessionLogoutAlert".localized, deviceName)
        showAlertDestructive(message: message, buttonTitle: "logout".localized) { [weak self] in
            self?.viewModel.revokeSession(id: session.id)
        }
    }

    func resolveCurrentSessionID(in sessions: [UserDeviceSession]) -> Int? {
        let currentDevice = ClientDeviceInfo.current
        let matchingSession = sessions.first {
            $0.deviceName?.nilIfBlank == currentDevice.deviceName.nilIfBlank
                && $0.platform?.nilIfBlank?.lowercased() == currentDevice.platform.lowercased()
                && $0.appVersion?.nilIfBlank == currentDevice.appVersion.nilIfBlank
        }

        // Older logins may not contain device metadata. In that case the API's
        // most-recently-active-first ordering is the best available fallback.
        return matchingSession?.id ?? sessions.first?.id
    }
}
