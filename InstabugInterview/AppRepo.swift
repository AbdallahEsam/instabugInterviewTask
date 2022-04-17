//
//  AppRepo.swift
//  InstabugInterview
//
//  Created by Macintosh on 16/04/2022.
//

import Foundation
import InstabugNetworkClient

protocol AppRepoProtocol{
    func get(completionHandler: @escaping (Data?) -> Void)
}

class AppRepo {
    
    let network: NetworkClientProtocol
    
    init() {
        self.network = NetworkClient()
    }
    
}

extension AppRepo: AppRepoProtocol {
    func get(completionHandler: @escaping (Data?) -> Void) {
        network.get(URL(string: Constant.url)!, completionHandler: completionHandler)
    }
}
