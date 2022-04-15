//
//  RecordModel.swift
//  InstabugInterview
//
//  Created by Macintosh on 15/04/2022.
//

import Foundation

public struct RecordModel {
  
    
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
