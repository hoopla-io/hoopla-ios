//
//  UIViewController.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import LocalAuthentication

extension UIViewController {
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    ///Creates a tap gesture recognizer that closes the keyboard when an outside view is tapped.
    internal func closeKeyboardOnOutsideTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    var hasSafeArea: Bool {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
}

extension UIViewController {
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

extension UIViewController {
    func openURL(urlString : String) {
        guard let selectedURL = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(selectedURL) {
            UIApplication.shared.open(selectedURL, options: [:], completionHandler: nil)
        }
    }
}

extension UIViewController {
    func resetTabBar(_ index: Int? = nil) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            let tabBar = TabBarController()
            
            if let currentTabIndex = self.tabBarController?.selectedIndex {
                tabBar.selectedIndex = currentTabIndex
            } else if let index = index {
                tabBar.selectedIndex = index
            }
            
            window.rootViewController = tabBar
            window.makeKeyAndVisible()
            
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.2
            window.layer.add(transition, forKey: kCATransition)
        }
    }
    
}

extension UIViewController {
    func share(imageURL: URL? = nil, text: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                var items = [Any]()
                if let imageURL = imageURL, imageURL != URL(fileURLWithPath: ""), UIApplication.shared.canOpenURL(imageURL) {
                    let imageData: NSData = NSData(contentsOf: imageURL)!
                    let image = UIImage(data: imageData as Data)
                    items.append(image!)
                }
                items.append(text)
                let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
                self.view.isUserInteractionEnabled = true
                if UIDevice.current.userInterfaceIdiom == .pad {
                    vc.popoverPresentationController?.sourceView = self.view
                    vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    vc.popoverPresentationController?.permittedArrowDirections = []
                }
                self.present(vc, animated: true)
            }
        }
    }
}

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIViewController {
    func handleStatusBar(scrollView: UIScrollView, topSpace: CGFloat) -> CGFloat {
        guard let statusBarHeight = UIApplication.shared.statusBarUIView?.frame.height else { return .zero }
        let offset = scrollView.contentOffset.y / (topSpace - statusBarHeight)
        let alpha = offset >= 1 ? 1.0 : 0.0
        handleStatusBar(alpha: alpha)
        return alpha
    }
    
    func handleStatusBar(alpha: CGFloat? = nil, clearDuration: Double = 0.0) {
        let alpha = alpha ?? 0.0

        if alpha == 1.0 {
            UIView.animate(withDuration: 0.1) {
                UIApplication.shared.statusBarUIView?.backgroundColor = .appColor(.mainBackground)
            }
        }
        if alpha == 0.0 {
            UIView.animate(withDuration: clearDuration) {
                UIApplication.shared.statusBarUIView?.backgroundColor = .clear
            }
        }
    }
}

extension UIViewController {
    func updateHero(isEnabled: Bool) {
//        navigationController?.hero.isEnabled = isEnabled
//        hero.isEnabled = isEnabled
    }
}

extension UIViewController {
    func authenticate(completionHandler: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "authReason".localized

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in

                DispatchQueue.main.async {
                    completionHandler(success)
                }
            }
        } else {
            // no biometrics
            DispatchQueue.main.async {
                completionHandler(true)
            }
        }
    }
}

extension UIViewController {
    var navigationBarHeight: CGFloat {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return (statusBarHeight) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

