//
//  RecordModel.swift
//  InstabugInterview
//
//  Created by Macintosh on 15/04/2022.
//

import Foundation

public struct RecordModel {
    public init(creationDate: Date?, method: String?, url: String?, statusCode: Int?, requestPayload: String?, responsePayload: String?, errorDomain: String?) {
        self.creationDate = creationDate
        self.method = method
        self.url = url
        self.statusCode = statusCode
        self.requestPayload = requestPayload
        self.responsePayload = responsePayload
        self.errorDomain = errorDomain
    }
    
  
    
  /// Request Creation Date
  ///
  public let creationDate: Date?
  
  /// Request method
  ///
  public let method: String?
  
  /// URL
  ///
  public let url: String?
    
  /// Response status code
  ///
  public let statusCode: Int?
  
  /// Request payload
  ///
  public let requestPayload: String?

  /// Response payload if exists
  ///
  public let responsePayload: String?
  
  /// For error response. Client error domain
  ///
  public let errorDomain: String?
}
