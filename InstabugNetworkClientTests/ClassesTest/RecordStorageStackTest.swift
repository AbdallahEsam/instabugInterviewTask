//
//  RecordStorageStack.swift
//  InstabugNetworkClientTests
//
//  Created by Abdallah Essam on 16/04/2022.
//

import XCTest
import CoreData
@testable import InstabugNetworkClient

class StorageManagerTest: XCTestCase {

    var sut: RecordStorageStack!
    var maxCount = 5
    override func setUpWithError() throws {
        let recordManager = RecordManager(mainContext: CoreDataTestStack().mainContext, backgroundContext:  CoreDataTestStack().backgroundContext)
        sut = RecordStorageStack(recordManager: recordManager, maxCount: maxCount)
    }
    
    override func tearDownWithError() throws {
      sut = nil
    }
    
   //    Test Save Record
    func testStorageManager_SaveNewRecord_RecordURLEqualToStubURL() {
        let promise = expectation(description: "Test Save Record")
        let record = MockRecordModel.createRecord()
        sut.pushRecord(with: record) { result in
            switch result {
            case .success(let record):
                XCTAssertEqual(record.url, MockURL.getURL.absoluteString)
            case .failure(_):
                print("")
            }
            promise.fulfill()
        }
        waitForExpectations(timeout: Double(20), handler: nil)
       
    }
    
    
    //    Test Records More Than Max Size
     func testStorageManager_whenRecordsMoreThanMaxSize_willRemoveFirstAndCountIsTheMax() {
         let promise = expectation(description: "Test Save Record")
         let record = MockRecordModel.createRecord()
         sut.pushRecord(with: record) { _ in}
         sut.pushRecord(with: record) { _ in}
         sut.pushRecord(with: record) { _ in}
         sut.pushRecord(with: record) { _ in}
         sut.pushRecord(with: record) { _ in}

         
       
         sut.fetchRecords { [weak self] result in
             guard let self = self else{return}
             switch result {
             case .success(let records):
                 XCTAssertEqual(records!.count, self.maxCount)
             case .failure(_):
                 print("")
             }
             promise.fulfill()
         }
         waitForExpectations(timeout: Double(20), handler: nil)
        
     }
    
   


}
