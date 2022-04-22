//
//  RecordStorageStack.swift
//  InstabugNetworkClient
//
//  Created by Abdallah Essam on 21/04/2022.
//

import Foundation
public protocol RecordStorageStackProtocol {
    func reset()
    func pushRecord(with record: RecordModel, completion: @escaping (Result<Record, Error>) -> Void)
    func fetchRecords(completion: @escaping (Result<[Record]?, Error>) -> Void)
}

public class RecordStorageStack{
    private var count: Int?
    private let maxCount: Int
    private let recordManager: RecordManagerProtocol
    public static let shared = RecordStorageStack()
    
    private let rootQueue: DispatchQueue = DispatchQueue(label: "com.instabug.session.RecordStorageStack", qos: .background)
    private let dispatchGroup = DispatchGroup()
    init(recordManager: RecordManagerProtocol, maxCount: Int) {
        self.recordManager = recordManager
        self.maxCount = maxCount
    }
    
    private convenience init() {
        self.init(recordManager: RecordManager(), maxCount: CoreDataStack.Defaults.maxCount)
    }
    
    
}

extension RecordStorageStack: RecordStorageStackProtocol{
    public func reset() {
        rootQueue.sync {
            self.recordManager.resetAll()
            self.count = nil
        }
        
    }
    
    private func getCount() {
        rootQueue.sync {
            if count == nil {
                count = recordManager.getCount()
            }else{
                return
            }
        }
    }
    
    private func deleteFirstItem() {
        recordManager.deleteFirstRecord()
        count! -= 1
    }
    
    private func preInsertion(){
        rootQueue.sync {
            guard let count = count else{return}
            guard count < maxCount else {
                self.deleteFirstItem()
                return
            }
            return
        }
        
    }
    
    private func insertRecord(_ record: RecordModel, completion: @escaping (Record) -> Void){
        rootQueue.sync {
            count! += 1
            recordManager.createRecord(record, completion: completion)
        }
    }
    
    
    
    public func pushRecord(with record: RecordModel, completion: @escaping (Result<Record, Error>) -> Void) {
        
        getCount()
        preInsertion()
        insertRecord(record) { record in
            completion(.success(record))
        }
        
    }
    
    public func fetchRecords(completion: @escaping (Result<[Record]?, Error>) -> Void) {
        rootQueue.async { [weak self] in
            guard let self = self else{return}
            print(self.recordManager.getCount())
            completion(.success(self.recordManager.fetchRecords()))
        }
    }
    
    
}
