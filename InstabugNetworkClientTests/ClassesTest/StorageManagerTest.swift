//
//  StorageManagerTest.swift
//  InstabugNetworkClientTests
//
//  Created by Macintosh on 16/04/2022.
//

import XCTest
@testable import InstabugNetworkClient

class StorageManagerTest: XCTestCase {

    var sut: StorageManager!
    
    override func setUpWithError() throws {
        sut = StorageManager.shared
    }
    
    override func tearDownWithError() throws {
      sut = nil
    }
    
   //    Test respecting the limit of recording.
    func testStorageManager_whenRecordsMoreThanMaxSize_willRemoveFirstAndCountIsTheMax(){
        let records = MockRecordModel.createMaxRecords()
        for x in records {
            sut.saveRecord(with: x)
        }
        XCTAssertEqual(records.count, 1001)
        
        sut.fetchRecords { result in
            switch result {
            case .success(let records):
                XCTAssertEqual(records.count, StorageManager.Defaults.maxCount)
            case .failure(_):
                print("error")
            }
        }
    }
    
   


}
