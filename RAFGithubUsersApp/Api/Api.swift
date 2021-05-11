//
//  Created by Volare on 4/17/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

protocol Api {
    associatedtype T
    func fetchResult(completion: ((Result<[T], Error>) -> Void)?)
}
protocol UserApi: Api where T == GithubUser {
    func fetchResult(completion: ((Result<[GithubUser], Error>) -> Void)?)
}
