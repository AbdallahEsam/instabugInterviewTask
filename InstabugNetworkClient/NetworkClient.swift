//
//  NetworkClient.swift
//  InstabugNetworkClient
//
//  Created by Yousef Hamza on 1/13/21.
//

import Foundation
public protocol NetworkClientProtocol {
    func get(_ url: URL, completionHandler: @escaping (Data?) -> Void)
    func post(_ url: URL, payload: Data?, completionHandler: @escaping (Data?) -> Void)
    func put(_ url: URL, payload: Data?, completionHandler: @escaping (Data?) -> Void)
    func delete(_ url: URL, completionHandler: @escaping (Data?) -> Void)
}

public class NetworkClient {
    private let storageManager: StorageManagerProtocol
    
    init(storageManager: StorageManagerProtocol) {
        self.storageManager = storageManager
    }
    
    // MARK: Network requests
    private func executeRequest(_ url: URL, method: String, payload: Data?, completionHandler: @escaping (Data?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = payload
        let requestRecordBuilder: RequestRecordBuilder = .init(urlRequest)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            requestRecordBuilder.setResponsePayload(data)
            requestRecordBuilder.setErrorDomain(error)
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("statusCode: \(statusCode)")
                requestRecordBuilder.setStatusCode(statusCode)
            }

            let requestRecord = requestRecordBuilder.build()
            self.storageManager.saveRecord(with: requestRecord)
            print(requestRecord)
            DispatchQueue.main.async {
                completionHandler(data)
            }
        }.resume()
    }

    // MARK: Network recording
    public func allNetworkRequests() -> Any {
        fatalError("Not implemented")
    }
}

extension NetworkClient: NetworkClientProtocol {
    public func get(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "GET", payload: nil, completionHandler: completionHandler)
    }
    
    public func post(_ url: URL, payload: Data? = nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "POSt", payload: payload, completionHandler: completionHandler)
    }
    
    public func put(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "PUT", payload: payload, completionHandler: completionHandler)
    }
    
    public func delete(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "DELETE", payload: nil, completionHandler: completionHandler)
    }
}

