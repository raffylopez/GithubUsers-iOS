//
//  ViewModelDelegate.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

protocol ViewModelDelegate {
    func onDataAvailable()
    func onRetryError(n: Int, nextAttemptInMilliseconds: Int, error:Error)
    func onFetchInProgress()
    func onFetchDone()
}
