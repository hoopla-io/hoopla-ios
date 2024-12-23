////
////  ViewModelProtocol.swift
////  qahvazor-vendor
////
////  Created by Alphazet on 15/12/24.
////
//
//import UIKit
//
//protocol ViewModelProtocol: AnyObject {
//    // MARK: - Attributes
//    var customSpinnerView: CustomSpinnerView { get }
//    var isLoading: Bool { get set }
//    
//    func showActivityIndicator()
//    func hideActivityIndicator()
//    func showAlertClosure(error: (APIError, String?))
//}
//
//extension ViewModelProtocol where Self: UIViewController {
//    func showActivityIndicator() {
//        DispatchQueue.main.async {
//            self.isLoading = true
//            self.view.isUserInteractionEnabled = false
//            self.customSpinnerView.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(self.customSpinnerView)
////            self.customSpinnerView.tintColor = UIColor.appColor(.green)
//            NSLayoutConstraint.activate([
//                self.customSpinnerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//                self.customSpinnerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
//            ])
//            self.customSpinnerView.startAnimating()
//        }
//    }
//    
//    func hideActivityIndicator() {
//        self.isLoading = false
//        self.customSpinnerView.stopAnimating()
//        self.customSpinnerView.removeFromSuperview()
//        self.view.isUserInteractionEnabled = true
//    }
//    
//    func showAlertClosure(error: (APIError, String?)) {
//        guard let self = self as? AlertViewController else { return }
//        self.addErrorAlertView(error: error, completion: nil)
//    }
//}


