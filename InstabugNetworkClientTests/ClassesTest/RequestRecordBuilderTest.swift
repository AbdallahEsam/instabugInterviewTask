//
//  RequestRecordBuilderTest.swift
//  InstabugNetworkClientTests
//
//  Created by Macintosh on 16/04/2022.
//

import XCTest
@testable import InstabugNetworkClient


class RequestRecordBuilderTest: XCTestCase {
    var sut: RequestRecordBuilder!
    
    override func setUpWithError() throws {
      sut = RequestRecordBuilder()
    }
    
    override func tearDownWithError() throws {
      sut = nil
    }
    
    func testRequestRecordBuilderTest_whenRequestPayloadIsLarge_willBuildRecordrRequestPayloadWithTooLarge(){
        sut = .init(RequestStub.RequestDataWithLargePayload())
        
        let record = sut.build()
        
        XCTAssertEqual(record.requestPayload, RequestRecordBuilder.Constants.tooLargePayload)
    }
    
    func testRequestRecordBuilderTest_whenResponsePayloadIsLarge_willBuildRecordrResponsePayloadWithTooLarge(){
        sut = .init(RequestStub.RequestDataWithSmallPayload())
        
        sut.setResponsePayload(ResposeStub.ResponseDataWithLargePayload().data)
        let record = sut.build()
        
        XCTAssertEqual(record.responsePayload, RequestRecordBuilder.Constants.tooLargePayload)
    }
  

}
