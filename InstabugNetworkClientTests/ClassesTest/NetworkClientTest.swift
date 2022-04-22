//
//  NetworkClientTest.swift
//  InstabugNetworkClientTests
//
//  Created by Abdallah Essam on 16/04/2022.
//

import XCTest
@testable import InstabugNetworkClient

class NetworkClientTest: XCTestCase {

    var sut: NetworkClient!
    var storageMock: StorageManagerMock!
    
    override func setUpWithError() throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: config)
        storageMock = StorageManagerMock()
        sut = NetworkClient(storageManager: storageMock, urlSession: urlSession)
    }
    
    override func tearDownWithError() throws {
      sut = nil
    }
    
    //   Test the execution of requests
    func testNetworkClient_whenRequestInfoProvided_willReturnData(){
        let promise = expectation(description: "Test the execution of requests")
        sut.get(MockURL.getURL) { data in
            XCTAssertNotNil(data)
            promise.fulfill()
        }
        waitForExpectations(timeout: Double(1), handler: nil)
    }
    
  
    
    // Test the recording
    func testNetworkClient_WhenCreateARequest_ShouldSavedLocally() {
        let promise = expectation(description: "Test the recording")
        sut.get(MockURL.getURL) { _ in
            // Assert
            XCTAssertEqual(self.storageMock.isSaveRecordCalled, true)
            promise.fulfill()
        }
        waitForExpectations(timeout: Double(1), handler: nil)
    }
    
   
    

    
    
  
}
