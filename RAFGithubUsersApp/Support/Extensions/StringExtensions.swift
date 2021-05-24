//
//  String.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

// MARK: - String

extension String {
    public func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    var beginsAndEndsWithQuotes: Bool {
        let quote = "\""
        return self.prefix(1) == quote && self.suffix(1) == quote
    }
    
    public func trimQuotes() -> String {
        return self.trimmingCharacters(in:CharacterSet(charactersIn: "\""))
    }
}
