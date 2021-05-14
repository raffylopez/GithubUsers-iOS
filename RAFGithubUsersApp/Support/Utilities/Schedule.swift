//
//  UIHelper.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import Reachability

class Schedule {
    /**
     Exponential delay value with jitter. Output is in milliseconds.
     */
    private static func getDelay(for n: Int) -> Int {
        let maxDelay = 300_000
        let delay = Int(pow(2.0, Double(n))) * 1_000
        let jitter = Int.random(in: 0...1_000)
        return min(delay + jitter, maxDelay)
    }
    
    /**
     Asynchronous execution with exponential backoff
     */
    static func asyncWithBackoff(on queue: DispatchQueue, retry: Int = 0, closure: @escaping ()-> ()) {
        queue.asyncAfter(
            deadline: DispatchTime.now() + .milliseconds(getDelay(for: retry)),
            execute: closure
        )
    }
    
    /**
     Synchronous execution with exponential backoff. Avoid using within DispatchQueue.main.
     */
    static func syncWithBackoff(on queue: DispatchQueue, retry: Int = 0, closure: @escaping ()-> ()) {
        let delay = getDelay(for: retry)
        usleep(useconds_t(delay))
        queue.sync { closure() }
    }
    
    
}
