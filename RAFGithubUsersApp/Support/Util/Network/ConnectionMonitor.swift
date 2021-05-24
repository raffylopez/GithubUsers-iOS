//
//  ConnectionMonitor.swift
//  RAF_GithubUsersApp
//
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import Reachability

protocol ReachabilityDelegate {
    func onLostConnection()
    func onRegainConnection()
}

class ConnectionMonitor {
    let confIntervalInSeconds: Int = 5;
    let confReachabilityIp: String = "http://www.google.com"
    let confApiIp: String = "http://api.github.com"
    
    var delegate: ReachabilityDelegate? = nil

    static let shared = ConnectionMonitor()
    private var reachability : Reachability!
    
    var isApiReachable: Bool {
        if let reachability = try? Reachability(hostname: self.confReachabilityIp),
            reachability.connection == .unavailable {
            return false
        }
        return true
    }
    
    func observeReachability() throws {
        self.reachability = try? Reachability()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    var lastConnectivityState: Reachability.Connection = .unavailable
    /**
     Continuously check for network signal every n seconds.
     
     Workaround against Reachability library not sending a notification
     when reconnected, whilst using the simulator
     */
    func periodicConnectivityCheck(start: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: start) {
            guard let reachability = try? Reachability(hostname: self.confReachabilityIp) else {
                self.periodicConnectivityCheck(start: .now() + .seconds(5))
                return
            }
            switch reachability.connection {
            case .unavailable:
                self.delegate?.onLostConnection()
                self.lastConnectivityState = .unavailable
            case .cellular where self.lastConnectivityState == .unavailable, .wifi where self.lastConnectivityState == .unavailable:
                self.lastConnectivityState = .wifi
                self.delegate?.onRegainConnection()
            default:
                break
            }
            self.periodicConnectivityCheck(start: .now() + .seconds(5))
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular, .wifi:
            break
        case .unavailable, .none:
            UIApplication.shared.windows.first?.rootViewController?.view.makeToast("Connection to Internet lost")
            print("Network is unavailable.")
            break
        @unknown default:
            print("Unknown reachability status.")
            break
        }
    }
}
enum LastDataSource {
    case network
    case offline
    case parkedFromSearch
    case unspecified
}

