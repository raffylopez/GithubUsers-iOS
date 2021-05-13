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
}
