//
//  MokeURL.swift
//  InstabugNetworkClientTests
//
//  Created by Macintosh on 16/04/2022.
//

import Foundation
enum MockURL {
    
    /// https://httpbin.org/get *GET Method*
    ///
    static let getURL = URL(string: "https://httpbin.org/get")!
    static let failURL = URL(string: "https://httpbin.org/dadf")!
    
}
