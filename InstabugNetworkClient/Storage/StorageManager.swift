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
    func saveRecord(with record: RecordModel)
    func fetchRecords(compeletion: @escaping (Result<[Record], Error>) -> Void)
}

public final class StorageManager: StorageManagerProtocol {
    enum Defaults {
        static let maxCount = 1000
    }
    
    public static let shared = StorageManager()
    
    private init() {}
    
    private let name: String = "Model"
    
    private let rootQueue: DispatchQueue = DispatchQueue(label: "com.instabug.session.rootQueue", qos: .background)
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                
                print(error)
            }
        }
        return container
    }()
    
    func performOnRootQueue(_ completion: (NSManagedObjectContext) -> Void) {
        rootQueue.sync{
            completion(persistentContainer.viewContext)
        }
    }
}

// MARK: - Save Record
//
extension StorageManager {
    
    public func saveRecord(with record: RecordModel) {
        performPreRecordInsertion {
            self.saveRecord(record, on: persistentContainer.viewContext)
        }
    }
    
    private func createRecordFromModel(_ viewContext: NSManagedObjectContext, _ record: RecordModel) {
        let newItem = Record(context: viewContext)
        newItem.createAt = record.creationDate
        newItem.errorDomain = record.errorDomain
        newItem.method = record.method
        newItem.requestPayload = record.requestPayload
        newItem.responsePayload = record.responsePayload
        newItem.statusCode = Int64(record.statusCode ?? 200)
        newItem.url = record.url
    }
    
    private func saveRecord(_ record: RecordModel, on viewContext: NSManagedObjectContext) {
        createRecordFromModel(viewContext, record)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            }
            catch {
                print(error)
            }
        }
    }
    
    func performPreRecordInsertion(_ completion: () -> Void) {
        performOnRootQueue { viewContext in
            do {
                let count = try viewContext.count(for: Record.fetchRequest())
                guard count < Defaults.maxCount else {
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
        
        let context = persistentContainer.viewContext
        do {
            let items = try context.fetch(request) as [NSManagedObject]
            if let firstItem = items.first {
                if let item = firstItem as? Record {
                    print(item.statusCode)
                }
                context.delete(firstItem)
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
            persistentContainer.persistentStoreCoordinator
            
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
            persistentContainer = NSPersistentContainer(
                name: name // the name of
                // a .xcdatamodeld file
            )
            
            // Calling loadPersistentStores will re-create the
            // persistent stores
            persistentContainer.loadPersistentStores {
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
                
                let items = try self.persistentContainer.viewContext.fetch(Record.fetchRequest())
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


