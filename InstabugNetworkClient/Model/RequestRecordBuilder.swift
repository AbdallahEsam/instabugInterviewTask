//
//  RequestRecord.swift
//  InstabugInterview
//
//  Created by Macintosh on 15/04/2022.
//

import Foundation

class RequestRecordBuilder {
    private var request: URLRequest?
    private var requestPayload: String?
    private var statusCode: Int?
    private var resposePayload: String?
    private var errorDomain: String?
    
    init(_ request: URLRequest) {
        self.request = request
        self.setRequestPayload(request)
    }
   
    private func setRequestPayload(_ request: URLRequest) {
        requestPayload = payloadAsString(data: request.httpBody)
    }
    
    
    private func payloadAsString(data: Data?) -> String {
      guard let data = data else {
        return String()
      }
      
      guard data.count <= Constants.maxPayloadSize else {
        return "Payload too large"
      }
      
      return String(data: data, encoding: .utf8) ?? String()
    }
    
    
    func setStatusCode(_ statusCode: Int) {
        self.statusCode = statusCode
    }
    
    
    func setResponsePayload(_ resposePayload: Data?){
        self.resposePayload = payloadAsString(data: resposePayload)
    }
    
    func setErrorDomain(_ errorDomain: Error?) {
        self.errorDomain = errorDomain?.localizedDescription
    }
    
    func build() -> RecordModel{
        .init(creationDate: Date(),
              method: request?.httpMethod,
              url: request?.url?.absoluteString,
              statusCode: statusCode,
              requestPayload: requestPayload,
              responsePayload: resposePayload, errorDomain: errorDomain)
    }
}

extension RequestRecordBuilder{
    enum Constants {
        static let maxPayloadSize = 1024 * 1024
    }
}
