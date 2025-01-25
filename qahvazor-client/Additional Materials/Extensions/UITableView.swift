//
//  UITableView.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import SkeletonView

extension UITableView {
    func checkEmpty(items: [Any]?, type: Empty? = nil) {
        guard let items = items else { return }
        items.isEmpty ? self.setEmptyView(type: type ?? .all) : self.restore()
        self.hideSkeleton()
    }
    
    func setEmptyView(type: Empty) {
        let emptyView = EmptyView.fromNib()
        emptyView.type = type
        emptyView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        self.backgroundView = emptyView
    }
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UITableView {
    func reloadDataAndSavingSelections() {
        let selectedRows = self.indexPathsForSelectedRows
        reloadData()
        if let selectedRows = selectedRows {
            for indexPath in selectedRows {
                self.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
}
extension UITableView {
    func reloadWithoutAnimation() {
        UIView.transition(with: self,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                      self.reloadData()
                                  },
                                  completion: nil)
    }
}

