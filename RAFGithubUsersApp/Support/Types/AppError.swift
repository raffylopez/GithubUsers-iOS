//
//  AppError.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

enum AppError: Error {
    case fetchInProgressError
    case appConfigLoadError
    case documentsDirectoryNotFoundError
    case missingImageUrlError
    case imageCreationError
    case emptyResultError
    case generalError
    case writeToDatastoreError(Error)
    case readFromDataStoreError(Error)
    case httpTransportError(Error)
    case httpServerSideError(Int)
    case networkUnreachable
    case retriesExceededError(Error)
}
