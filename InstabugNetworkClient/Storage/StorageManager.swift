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
    // MARK: Contexts
    
    public static let shared = StorageManager()
    private let type: String
    private let maxCount: Int
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Defaults.coreDataName)
        let description = container.persistentStoreDescriptions.first
        description?.type = type
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
        }
        return container
    }()
    /*
     rootQueue to perform tasks in background thread
     */
    private let rootQueue: DispatchQueue = DispatchQueue(label: "com.instabug.session.rootQueue", qos: .background)

    /*
     Note: type is using for making data be is sqllite or memory.
     maxCount are passed in so they can be overridden via unit testing.
     */
    
    init(type: StorageManager.MemoryStorageType, maxCount: Int) {
        self.type = type.value
        self.maxCount = maxCount
    }
    
   
    /*
     Note: private init for singelton
     */
    private convenience init() {
        self.init(type: .disk, maxCount: Defaults.maxCount)
    }
    
    
    
    
     func performOnRootQueue(_ completion: (NSManagedObjectContext) -> Void) {
    
         rootQueue.sync{
             completion(persistentContainer.viewContext)
        }
    }
}

// MARK: - Save Record
//
extension StorageManager {
    
    public func saveRecord(with record: RecordModel, compeletion: @escaping (Result<Record, Error>) -> Void) {
        performPreInsertionRecord {
            self.saveRecord(record, on: persistentContainer.viewContext, compeletion: compeletion)
        }
    }
   ///    create a record
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
    
    ///    saveRecord
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
    /*
     Note: performPreInsertionRecord is called always before record new record for
     get count of entity
     check count
     delete first item
     */
    func performPreInsertionRecord(_ completion: () -> Void) {
        performOnRootQueue { viewContext in
            do {
                let count = try viewContext.count(for: Record.fetchRequest())
                guard count < maxCount else {
                    self.deleteFirstItem { _ in completion() }
                    return
                }
                
                completion()
            } catch {
                fatalError(error.localizedDescription)
            }
            
        }
    }
    
    ///    deleteFirstItem
    private func deleteFirstItem(_ completion: (Error?) -> Void) {
        let request = Record.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let items = try persistentContainer.viewContext.fetch(request) as [NSManagedObject]
            if let firstItem = items.first {
                if let item = firstItem as? Record {
                    print(item.statusCode)
                }
                persistentContainer.viewContext.delete(firstItem)
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
                name: Defaults.coreDataName // the name of
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



// MARK: - Defaults
extension StorageManager {
    enum Defaults {
        static let maxCount = 1000
        static let coreDataName = "Model"
    }
    
    enum MemoryStorageType {
        case memory
        case disk
        
        var value: String {
            switch self {
                
            case .memory:
                return NSInMemoryStoreType
            case .disk:
                return NSSQLiteStoreType
            }
        }
    }
    
}
