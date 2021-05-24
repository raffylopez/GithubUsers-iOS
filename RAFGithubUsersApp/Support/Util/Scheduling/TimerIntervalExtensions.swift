//
//  ScheduledTask.swift
//  RAF_GithubUsersApp
//
//  Created by Volare on 4/16/21.
//

import Foundation

/**
 Task scheduler with supporting exponential backoffs
 */
extension TimeInterval {
    /**
     Exponential delay value with jitter. Output is in milliseconds.
     
     Attribution: https://phelgo.com/exponential-backoff/
     */
    public static func getExponentialDelay(for n: Int) -> Int {
        let maxDelay = 300_000
        let delay = Int(pow(2.0, Double(n))) * 1_000
        let jitter = Int.random(in: 0...1_000)
        return min(delay + jitter, maxDelay)
    }
}
