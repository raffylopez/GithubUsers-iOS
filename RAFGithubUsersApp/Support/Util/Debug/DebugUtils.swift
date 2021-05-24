//
//  DebugUtils.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

func print_r<T>(array: [T]) where T: CustomStringConvertible {
    for t in array {
        print(t)
    }
}

func print_opt<T>(item: Optional<T>) {
    let label = String(describing: item)
    if let item = item {
        print("\(label): \(item)")
        return
    }
    print("\(label): nil")
}
