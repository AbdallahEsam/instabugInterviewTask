//
//  MokeRecordModel.swift
//  InstabugNetworkClientTests
//
//  Created by Macintosh on 16/04/2022.
//

import Foundation
@testable import InstabugNetworkClient
class MockRecordModel {
    static func createRecord() -> RecordModel {
        return .init(creationDate: Date(),
                     method: "Get",
                     url: MockURL.url.absoluteString,
                     statusCode: 200,
                     requestPayload: "requestPayload",
                     responsePayload: "responsePayload",
                     errorDomain: "errorDomain")
    }
    
    static func createMaxRecords() -> [RecordModel] {
        var records: [RecordModel] = []
        for _ in 0...StorageManager.Defaults.maxCount {
            records.append(MockRecordModel.createRecord())
        }
        return records
    }
}


