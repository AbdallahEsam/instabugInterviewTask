//
//  StorageManagerTest.swift
//  InstabugNetworkClientTests
//
//  Created by Macintosh on 16/04/2022.
//

import XCTest
import CoreData
@testable import InstabugNetworkClient

class StorageManagerTest: XCTestCase {

    var sut: StorageManagerProtocol!
    var maxCount = 4
    override func setUpWithError() throws {
        sut = StorageManager(type: .memory, maxCount: maxCount)
    }
    
    override func tearDownWithError() throws {
      sut = nil
    }
    
   //    Test Save Record
    func testStorageManager_SaveNewRecord_RecordURLEqualToStubURL() {
        let promise = expectation(description: "Test Save Record")
        let record = MockRecordModel.createRecord()
        sut.saveRecord(with: record) { result in
            switch result {
            case .success(let record):
                XCTAssertEqual(record.url, MockURL.getURL.absoluteString)
            case .failure(_):
                print("")
            }
            promise.fulfill()
        }
        waitForExpectations(timeout: Double(1), handler: nil)
       
    }
    
    
    //    Test Records More Than Max Size
     func testStorageManager_whenRecordsMoreThanMaxSize_willRemoveFirstAndCountIsTheMax() {
         let promise = expectation(description: "Test Save Record")
         let record = MockRecordModel.createRecord()
         sut.saveRecord(with: record) { _ in}
         sut.saveRecord(with: record) { _ in}
         sut.saveRecord(with: record) { _ in}
         sut.saveRecord(with: record) { _ in}
         sut.saveRecord(with: record) { _ in}
         sut.fetchRecords { [weak self] result in
             guard let self = self else{return}
             switch result {
             case .success(let records):
                 XCTAssertEqual(records.count, self.maxCount)
             case .failure(_):
                 print("")
             }
             promise.fulfill()
         }
         waitForExpectations(timeout: Double(1), handler: nil)
        
     }
    
   


}
