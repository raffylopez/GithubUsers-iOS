//
//  AppError.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

enum AppError: Error {
    case networkError
    case fetchInProgress
    case appConfigLoadError
    case documentsDirectoryNotFound
    case missingImageUrl
    case imageCreationError
    case emptyResult
    case generalError
    case httpTransportError(Error)
    case httpServerSideError(Int)
}
