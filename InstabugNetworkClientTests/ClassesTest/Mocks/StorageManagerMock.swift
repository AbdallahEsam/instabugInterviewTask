//
//  StorageManagerMock.swift
//  InstabugNetworkClientTests
//
//  Created by Macintosh on 16/04/2022.
//

import Foundation
@testable import InstabugNetworkClient

class StorageManagerMock: StorageManagerProtocol {
    
    
    var isSaveRecordCalled: Bool =  false
    var isFetchRecordsCalled: Bool =  false
    var isResetAllRecordsCalled: Bool = false
   
    
    func resetAllRecords() {
        isResetAllRecordsCalled = true
    }
    
    func saveRecord(with record: RecordModel) {
        isSaveRecordCalled = true
    }
    
    func fetchRecords(compeletion: @escaping (Result<[Record], Error>) -> Void) {
        isFetchRecordsCalled = true

    }
    
    
}
