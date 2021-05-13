//
//  UIHelper.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

class ConnectionManager {
    
    static let sharedInstance = ConnectionManager()
    private var reachability : Reachability!
    
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
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
//            UIApplication.shared.windows.first?.rootViewController?.view.makeToast("Cellular")
            break
        case .wifi:
            print("Network available via WiFi.")
//            UIApplication.shared.windows.first?.rootViewController?.view.makeToast("Wifi")
            break
        case .unavailable:
//            UIApplication.shared.windows.first?.rootViewController?.view.makeToast("No Network")
            print("Network is unavailable.")
            break
        }
    }
}
