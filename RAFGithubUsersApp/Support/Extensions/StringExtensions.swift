//
//  StringExtensions.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

// MARK: - String
extension String {
    public func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    var isQuoted: Bool {
        let quote = "\""
        return self.prefix(1) == quote && self.suffix(1) == quote
    }
    
    public func stripQuotes() -> String {
        guard self.count >= 2 else { return self }
        let range = self.index(self.startIndex, offsetBy: 1)..<self.index(self.endIndex, offsetBy: -1)
        return String(self[range])
    }
}
