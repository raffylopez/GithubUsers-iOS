//
//  UIHelper.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
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
//            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }
    
    /**
     Continuously check for network signal every n seconds.
     
     Workaround against Reachability library not sending a notification
     when reconnected, whilst using the simulator
     */
    func checkNetworkSignal() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            if let reachability = try? Reachability(hostname: self.confReachabilityIp),
            reachability.connection == .unavailable {
                self.delegate?.onLostConnection()
            } else {
                self.delegate?.onRegainConnection()
            }

            self.checkNetworkSignal()
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            UIApplication.shared.windows.first?.rootViewController?.view.makeToast("Cellular")
            break
        case .wifi:
            print("Network available via WiFi.")
            UIApplication.shared.windows.first?.rootViewController?.view.makeToast("Wifi")
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
