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
    
    public convenience init() {
        self.init(storageManager: StorageManager.shared)
    }
    
    // MARK: Network requests
    private func executeRequest(_ url: URL, method: String, payload: Data?, completionHandler: @escaping (Data?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = payload
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            let response = Response(response: response, data: data, error: error)
            self.saveRequest(urlRequest, response)
            DispatchQueue.main.async {
                completionHandler(data)
            }
        }.resume()
    }
    
    private func saveRequest(_ request: URLRequest, _ response: Response) {
        let recordBuilder = RequestRecordBuilder(request)
        recordBuilder.setResponsePayload(response.data)
        recordBuilder.setErrorDomain(response.error)
        if let httpResponse = response.response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            recordBuilder.setStatusCode(statusCode)
        }

        let requestRecord = recordBuilder.build()
        self.storageManager.saveRecord(with: requestRecord)
    }

    // MARK: Network recording
    public func allNetworkRequests() -> Any {
        fatalError("Not implemented")
    }
}

// MARK: - Nested Types
//
extension NetworkClient {
    struct Response {
        let response: URLResponse?
        let data: Data?
        let error: Error?
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

