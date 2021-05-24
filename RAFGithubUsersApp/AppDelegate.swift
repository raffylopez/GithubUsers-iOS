import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var appConnectionState: AppConnectionState = ConnectionMonitor.shared.isApiReachable ?
        .networkReachable : .networkUnreachable {
        didSet {
            switch appConnectionState {
            case .networkReachable:
                NotificationCenter.default.post(name: .connectionDidBecomeReachable, object: nil)
            case .networkUnreachable:
                NotificationCenter.default.post(name: .connectionDidBecomeUnreachable, object: nil)
            case .unknown:
                break
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupReachability()
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    private func setupReachability() {
        ConnectionMonitor.shared.delegate = self
        ConnectionMonitor.shared.periodicConnectivityCheck(start: .now())
    }
    
}

extension AppDelegate: ReachabilityDelegate {
    func onLostConnection() {
        self.appConnectionState = .networkUnreachable
    }
    
    func onRegainConnection() {
        self.appConnectionState = .networkReachable
    }
}

