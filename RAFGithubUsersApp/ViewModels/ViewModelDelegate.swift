//
//  AmiiboElementsViewModel.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/17/21.
//  Copyright © 2021 Raf. All rights reserved.
//

protocol ViewModelDelegate {
    func onDataAvailable()
    func onRetryError(n: Int, nextAttemptInMilliseconds: Int, error:Error)
    func onFetchInProgress()
    func onFetchDone()
}
