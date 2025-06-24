//
//  SceneDelegate.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        setupLaunch(scene, connectionOptions)
        guard let url = connectionOptions.urlContexts.first?.url else { return }
        fetchUniversalLinks(url, isAppActive: false)
    }
    
    func setupLaunch(_ scene: UIScene, _ connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.backgroundColor = UIColor.appColor(.mainBackground)
        window?.rootViewController = UINavigationController(rootViewController: LaunchScreenViewController())
        window?.makeKeyAndVisible()
        
        guard let activity: NSUserActivity = connectionOptions.userActivities.first,
              activity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = activity.webpageURL else { return }
        fetchUniversalLinks(incomingURL, isAppActive: false)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        fetchUniversalLinks(url, isAppActive: true)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else { return }
        fetchUniversalLinks(incomingURL, isAppActive: true)
    }
    
    private func fetchUniversalLinks(_ url: URL, isAppActive: Bool) {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let path = components.path else { return }
        let second = path.components(separatedBy: Symbols.slash.rawValue)
        second.forEach { string in
            if string == UniversalLinksType.shop.rawValue {
                if let id = path.extractID() {
                    if isAppActive {
                        Notification.Name.universalLink.post(userInfo: [UserInfoName.shopId.rawValue : id])
                    } else {
                        UniversalLink.shopId = id
                    }
                }
//            } else if string == UniversalLinksType.channels.rawValue {
//                if let id = path.extractID() {
//                    if isAppActive {
//                        Notification.Name.universalLink.post(userInfo: [UserInfoName.channelId.rawValue : id])
//                    } else {
//                        UniversalLink.channelId = id
//                    }
//                }
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

