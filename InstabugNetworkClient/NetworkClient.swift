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
    func allNetworkRecords(onCompletion: @escaping(Result<[Record]?, Error>) -> Void)
}

public class NetworkClient {
    
    private let storageManager: RecordStorageStackProtocol
    private var urlSession: URLSession
    
    init(storageManager: RecordStorageStackProtocol, urlSession: URLSession) {
        self.storageManager = storageManager
        self.urlSession = urlSession
    }
    
    public convenience init() {
        self.init(storageManager: RecordStorageStack.shared, urlSession: URLSession.shared)
    }
    
    // MARK: Network requests
    private func executeRequest(_ url: URL, method: String, payload: Data?, completionHandler: @escaping (Data?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = payload
        
        urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let response = Response(response: response, data: data, error: error)
                self.saveRequest(urlRequest, response)
                completionHandler(data)
            }
        }.resume()
    }
    
    // MARK: Save Request
    private func saveRequest(_ request: URLRequest, _ response: Response) {
        let recordBuilder = RequestRecordBuilder(request)
        recordBuilder.setResponsePayload(response.data)
        recordBuilder.setErrorDomain(response.error)
        if let httpResponse = response.response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            recordBuilder.setStatusCode(statusCode)
        }

        let requestRecord = recordBuilder.build()
        self.storageManager.pushRecord(with: requestRecord) { _ in}
    }

    // MARK: Network recording
    /// - Note: Should not be used as the response happens asynchronously.
    ///
    @available(*, unavailable, renamed: "allNetworkRecords(onCompletion:)")
    public func allNetworkRequests() -> [Record] {
      fatalError("Not implemented")
    }
    
    /// Fetch all network records
    ///
    public func allNetworkRecords(onCompletion: @escaping(Result<[Record]?, Error>) -> Void) {
        storageManager.fetchRecords(completion: onCompletion)
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

