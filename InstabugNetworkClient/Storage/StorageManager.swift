//
//  StorageManager.swift
//  InstabugInterview
//
//  Created by Macintosh on 15/04/2022.
//

import UIKit
import CoreData

public protocol StorageManagerProtocol {
    func resetAllRecords()
    func saveRecord(with record: RecordModel, compeletion: @escaping (Result<Record, Error>) -> Void)
    func fetchRecords(compeletion: @escaping (Result<[Record], Error>) -> Void)
}

public final class StorageManager: StorageManagerProtocol {
    
    public static let shared = StorageManager()
    private let mainContext: NSManagedObjectContext
    private let maxCount: Int
    init(mainContext: NSManagedObjectContext, maxCount: Int) {
        self.mainContext = mainContext
        self.maxCount = maxCount
    }
    
    private convenience init() {
        self.init(mainContext: CoreDataStack.shared.mainContext, maxCount: Defaults.maxCount)
    }
    
    
    private let rootQueue: DispatchQueue = DispatchQueue(label: "com.instabug.session.rootQueue", qos: .background)
    
    
    func performOnRootQueue(_ completion: (NSManagedObjectContext) -> Void) {
        rootQueue.sync{
            completion(mainContext)
        }
    }
}

// MARK: - Save Record
//
extension StorageManager {
    
    public func saveRecord(with record: RecordModel, compeletion: @escaping (Result<Record, Error>) -> Void) {
        performPreRecordInsertion {
            self.saveRecord(record, on: mainContext, compeletion: compeletion)
        }
    }
    
    private func createRecordFromModel(_ viewContext: NSManagedObjectContext, _ record: RecordModel, compeletion: @escaping (Result<Record, Error>) -> Void) {
        let newItem = Record(context: viewContext)
        newItem.createAt = record.creationDate
        newItem.errorDomain = record.errorDomain
        newItem.method = record.method
        newItem.requestPayload = record.requestPayload
        newItem.responsePayload = record.responsePayload
        newItem.statusCode = Int64(record.statusCode ?? 200)
        newItem.url = record.url
        compeletion(.success(newItem))
    }
    
    private func saveRecord(_ record: RecordModel, on viewContext: NSManagedObjectContext, compeletion: @escaping (Result<Record, Error>) -> Void) {
        createRecordFromModel(viewContext, record, compeletion: compeletion)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            }
            catch {
                print(error)
                compeletion(.failure(error))
            }
        }
    }
    
    func performPreRecordInsertion(_ completion: () -> Void) {
        performOnRootQueue { viewContext in
            do {
                let count = try viewContext.count(for: Record.fetchRequest())
                guard count < maxCount else {
                    self.deleteFirstItem { _ in completion() }
                    return
                }
                
                completion()
            } catch {
                
            }
            
        }
    }
    
    private func deleteFirstItem(_ completion: (Error?) -> Void) {
        let request = Record.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let items = try mainContext.fetch(request) as [NSManagedObject]
            if let firstItem = items.first {
                if let item = firstItem as? Record {
                    print(item.statusCode)
                }
                mainContext.delete(firstItem)
            }
            
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

// MARK: - Reset All Records
extension StorageManager {
    public func resetAllRecords() {
        rootQueue.sync {
            let storeContainer =
            CoreDataStack.shared.persistentContainer.persistentStoreCoordinator
            
            // Delete each existing persistent store
            for store in storeContainer.persistentStores {
                do{
                    try storeContainer.destroyPersistentStore(
                        at: store.url!,
                        ofType: store.type,
                        options: nil
                    )
                }
                catch {
                    print(error)
                }
            }
            
            // Re-create the persistent container
            CoreDataStack.shared.persistentContainer = NSPersistentContainer(
                name: Defaults.coreDataName // the name of
                // a .xcdatamodeld file
            )
            
            // Calling loadPersistentStores will re-create the
            // persistent stores
            CoreDataStack.shared.persistentContainer.loadPersistentStores {
                (store, error) in
                // Handle errors
            }
        }
    }
    
}

// MARK: - Fetch All records
extension StorageManager {
    
    public func fetchRecords(compeletion: @escaping (Result<[Record], Error>) -> Void) {
        rootQueue.async { [weak self] in
            guard let self = self else{return}
            do {
                
                let items = try self.mainContext.fetch(Record.fetchRequest())
                DispatchQueue.main.async {
                    compeletion(.success(items))
                }
            }
            catch {
                DispatchQueue.main.async {
                    compeletion(.failure(error))
                }
            }
        }
    }
}



// MARK: - Defaults
extension StorageManager {
    enum Defaults {
        static let maxCount = 1000
        static let coreDataName = "Model"
    }
    
}
