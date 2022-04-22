//
//  RecordManager.swift
//  InstabugNetworkClient
//
//  Created by Abdallah Essam on 16/04/2022.
//

import Foundation
import CoreData

public protocol RecordManagerProtocol {
    func createRecord(_ record: RecordModel, completion: @escaping (Record) -> Void)
    func deleteFirstRecord()
    func fetchRecords() -> [Record]?
    func getCount() -> Int
    func resetAll()
}

class RecordManager: RecordManagerProtocol{
    
    // MARK: Contexts
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    /*
     Note: All fetches. Updates, creates, deletes can be background.
     Contexts are passed in so they can be overridden via unit testing.
     */
    
    // MARK: - Init
    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext,
         backgroundContext: NSManagedObjectContext = CoreDataStack.shared.backgroundContext) {
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
    }
}

// MARK: - Create
extension RecordManager {
    
    func createRecord(_ record: RecordModel, completion: @escaping (Record) -> Void) {
        backgroundContext.performAndWait {
            let newRecord = NSEntityDescription.insertNewObject(forEntityName: "Record", into: backgroundContext) as! Record
            newRecord.createAt = record.creationDate
            newRecord.errorDomain = record.errorDomain
            newRecord.method = record.method
            newRecord.requestPayload = record.requestPayload
            newRecord.responsePayload = record.responsePayload
            newRecord.statusCode = Int64(record.statusCode ?? 200)
            newRecord.url = record.url
            saveChanges()
            completion(newRecord)
        }
        
    }
    
    func saveChanges() {
        backgroundContext.performAndWait {
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                }
                catch {
                    print(error)
                }
            }
        }
    }
}

// MARK: - Delete
extension RecordManager {
    
    func deleteFirstRecord() {
        guard let record = fetchFirstRecords() else{return}
        deleteRecord(record)
    }
    
    func fetchFirstRecords() -> Record? {
        let fetchRequest = Record.fetchRequest()
        var records: [Record]?
        backgroundContext.performAndWait {
            do {
                records = try backgroundContext.fetch(fetchRequest)
            } catch let error {
                print("Failed to fetch Record: \(error)")
            }
        }
        return records?.last
    }
    
    func deleteRecord(_ record: Record) {
        let objectID = record.objectID
        backgroundContext.performAndWait {
            if let employeeInContext = try? backgroundContext.existingObject(with: objectID) {
                backgroundContext.delete(employeeInContext)
                try? backgroundContext.save()
            }
        }
    }
}

// MARK: - Fetch
extension RecordManager {
    
    func fetchRecords() -> [Record]? {
        let fetchRequest = Record.fetchRequest()
        var records: [Record]?
        backgroundContext.performAndWait {
            do {
                records = try backgroundContext.fetch(fetchRequest)
            } catch let error {
                print("Failed to fetch Record: \(error)")
            }
        }
        return records
    }
    
    func getCount() -> Int {
        var count: Int = 0
        backgroundContext.performAndWait {
            do {
                count = try backgroundContext.count(for: Record.fetchRequest())
            }catch {
                print("Failed to fetch RecordCount: \(error)")
            }
        }
        
        return count
    }
}
// MARK: - Reset
extension RecordManager {
    func resetAll() {
        backgroundContext.performAndWait {
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
                name: CoreDataStack.Defaults.coreDataName // the name of
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


