//
//  StorageManagerMock.swift
//  InstabugNetworkClientTests
//
//  Created by Abdallah Essam on 16/04/2022.
//

import Foundation
@testable import InstabugNetworkClient

class StorageManagerMock: RecordStorageStackProtocol {
    
    
    var isSaveRecordCalled: Bool =  false
    var isFetchRecordsCalled: Bool =  false
    var isResetAllRecordsCalled: Bool = false
   
    
    func reset() {
        isResetAllRecordsCalled = true
    }
    
    func pushRecord(with record: RecordModel, completion: @escaping (Result<Record, Error>) -> Void) {
        isSaveRecordCalled = true
    }
    
    
    func fetchRecords(completion: @escaping (Result<[Record]?, Error>) -> Void) {
        isFetchRecordsCalled = true

    }
    
    
}
