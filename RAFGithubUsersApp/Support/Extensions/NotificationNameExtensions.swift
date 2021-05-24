//
//  NotificationNameExtensions.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/24/21.
//  Copyright © 2021 Raf. All rights reserved.
//

extension Notification.Name {
    public static let connectionDidBecomeUnreachable = NSNotification.Name("ConnectionDidBecomeUnreachable")
    public static let connectionDidBecomeReachable = NSNotification.Name("ConnectionDidBecomeReachable")
    public static let serverDidError = NSNotification.Name("ServerDidError")
}
