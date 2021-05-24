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
class ScheduleTracker {
    public static var retryIsActive: Bool = false
}

class ScheduledTask<T, ResultType> {
    typealias TaskRequiredResult = (T, (@escaping (Result<ResultType,Error>)->Void)) -> Void
    var taskRequiredResult: TaskRequiredResult!
    init(task: @escaping TaskRequiredResult) {
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
    
    var tryIndex: Int = 1;

    /**
     Recursively retries task asynchronously with backoff.
     */
    func retryWithBackoff(times n: Int,
                          taskParam: T,
                          onTaskSuccess: ((ResultType)->Void)? = nil,
                          onTaskError: ((Int, Int, Error)->Void)? = nil) {
        let delay = getExponentialDelay(for: tryIndex)
        DispatchQueue.global().asyncAfter(
        deadline: .now() + .milliseconds(delay)) {
            self.taskRequiredResult(taskParam) { result in
                switch result {
                case let .success(users):
                    onTaskSuccess?(users)
                case let .failure(error):
                    self.tryIndex += 1
                    print("Error in try \(self.tryIndex)...retrying in \(delay) milliseconds")
                    if n > 0 {
                        ScheduleTracker.retryIsActive = true
                        self.retryWithBackoff(times: n - 1, taskParam: taskParam, onTaskSuccess: onTaskSuccess, onTaskError: onTaskError)
                        return
                    }
                    onTaskError?(self.tryIndex, delay, error)
                }
                ScheduleTracker.retryIsActive = false
                self.tryIndex = 1
            }
        }
//        ConcurrencyUtils.networkRetrySemaphore.wait()
    }
}
