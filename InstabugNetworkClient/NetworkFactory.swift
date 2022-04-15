//
//  NetworkFactory.swift
//  InstabugInterview
//
//  Created by Macintosh on 15/04/2022.
//

import Foundation

public class NetworkFactory {
    static public func getNetwok() -> NetworkClientProtocol {
        let storage: StorageManagerProtocol = StorageManager.shared
        let object = NetworkClient(storageManager: storage)
        return object
    }
}
