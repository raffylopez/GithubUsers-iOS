//
//  AppConnectionState.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import Reachability

enum AppConnectionState {
    case networkReachable
    case networkUnreachable
    case unknown
}

