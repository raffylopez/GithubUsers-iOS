//
//  ScheduledTask.swift
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import Reachability

/**
 Task scheduler for exponential backoff
 */
class ScheduledTask<T, ResultType> {
    typealias Task = (T, ((Result<ResultType,Error>)->Void)?) -> Void
    let task: Task
    init(task: @escaping Task) {
        self.task = task
    }
    
    /**
     Exponential delay value with jitter. Output is in milliseconds.
     
     Attribution: https://phelgo.com/exponential-backoff/
     */
    private func getExponentialDelay(for n: Int) -> Int {
        let maxDelay = 300_000
        let delay = Int(pow(2.0, Double(n))) * 1_000
        let jitter = Int.random(in: 0...1_000)
        return min(delay + jitter, maxDelay)
    }
    
    var retryCount: Int = 0;
    
    /**
     Retries task asynchronously with backoff. Uses recursion for repetition.
     */
    func retryWithBackoff(times n: Int,
                          taskParam: T,
                          queue: DispatchQueue,
                          onTaskSuccess: ((ResultType)->Void)? = nil,
                          onTaskError: ((Int, Int, Error)->Void)? = nil) {
        let delay = getExponentialDelay(for: retryCount)
        queue.asyncAfter(
        deadline: DispatchTime.now() + .milliseconds(delay)) {
            self.task(taskParam) { result in
                switch result {
                case let .success(users):
                    onTaskSuccess?(users)
                case let .failure(error):
                    self.retryCount += 1
                    print("Error in try \(self.retryCount)...retrying in \(delay) milliseconds")
                    
                    onTaskError?(self.retryCount, delay, error)
                    
                    if n > 0 {
                        self.retryWithBackoff(times: n - self.retryCount, taskParam: taskParam, queue: queue, onTaskSuccess: onTaskSuccess, onTaskError: onTaskError)
                        return
                    }
                }
            }
        }
    }
}
