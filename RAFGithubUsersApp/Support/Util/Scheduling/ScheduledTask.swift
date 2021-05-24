//
//  ScheduledTask.swift
//  RAF_GithubUsersApp
//
//  Created by Volare on 4/16/21.
//

import Foundation
import Reachability

/**
 Task scheduler with supporting exponential backoffs
 */
class ScheduledTask<T, ResultType> {
    typealias Task = (T, ((Result<ResultType,Error>)->Void)?) -> Void
    typealias TaskRequiredResult = (T, (@escaping (Result<ResultType,Error>)->Void)) -> Void
    var task: Task!
    var taskRequiredResult: TaskRequiredResult!
    
    init(task: @escaping Task) {
        self.task = task
        self.taskRequiredResult = nil
    }
    
    init(task: @escaping TaskRequiredResult) {
        self.task = nil
        self.taskRequiredResult = task
    }

    /**
     Exponential delay value with jitter. Output is in milliseconds.
     
     Attribution: https://phelgo.com/exponential-backoff/
     */
    public func getExponentialDelay(for n: Int) -> Int {
        let maxDelay = 300_000
        let delay = Int(pow(2.0, Double(n))) * 1_000
        let jitter = Int.random(in: 0...1_000)
        return min(delay + jitter, maxDelay)
    }
    
    var retryCount: Int = 0;
    
    /**
     Recursively retries task asynchronously with backoff.
     */
    func retryWithBackoff(times n: Int,
                          taskParam: T,
                          onTaskSuccess: ((ResultType)->Void)? = nil,
                          onTaskError: ((Int, Int, Error)->Void)? = nil) {
        let delay = getExponentialDelay(for: retryCount)
        DispatchQueue.global().asyncAfter(
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
                        self.retryWithBackoff(times: n - self.retryCount, taskParam: taskParam, onTaskSuccess: onTaskSuccess, onTaskError: onTaskError)
                        return
                    }
                }
            }
        }
    }
    /**
     Recursively retries task asynchronously with backoff.
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
