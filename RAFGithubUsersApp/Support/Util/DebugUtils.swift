//
//  DebugUtils.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/19/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

func print_r<T>(array: [T]) where T: CustomStringConvertible {
    for t in array {
        print(t)
    }
}
