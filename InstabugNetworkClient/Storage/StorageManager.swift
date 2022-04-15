//
//  StorageManager.swift
//  InstabugInterview
//
//  Created by Macintosh on 15/04/2022.
//

import UIKit
import CoreData

public protocol StorageManagerProtocol {
    func fetchRecords()
    func resetAllRecords()
    func saveRecord(with record: RecordModel)
}

public final class StorageManager{
    
    static let shared = StorageManager()
    
    private let name: String = "Model"
    private let maxCount: Int = 5
    private var items: [NSManagedObject] = []
    
    private let rootQueue: DispatchQueue = DispatchQueue(label: "com.instabug.session.rootQueue", qos: .background)
    public lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        return container
    }()
    
    private var count: Int {
        let context = persistentContainer.viewContext
        do {
            let count = try context.count(for: NSFetchRequest(entityName: "Record"))
            return count
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func saveContext(record: RecordModel) {
        rootQueue.sync {
            let newItem = Record(context: persistentContainer.viewContext)
            newItem.createAt = record.creationDate
            newItem.errorDomain = record.errorDomain
            newItem.method = record.method
            newItem.requestPayload = record.requestPayload
            newItem.responsePayload = record.responsePayload
            newItem.statusCode = Int64(record.statusCode ?? 200)
            newItem.url = record.url
            items.append(newItem)
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                }
                catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    private func validateIsNewItemCanBeSaved() -> Bool {
        if count == maxCount{
            return false
        }else{
            
            return true
        }
    }
    
    private func deleteFirstItem() {
        rootQueue.sync {
            let context = persistentContainer.viewContext
            let item = items[0]
            context.delete(item)
            items.removeFirst()
        }
    }
    
}

extension StorageManager: StorageManagerProtocol {
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
    
    public func fetchRecords() {
        rootQueue.async {
            do {
                let items = try self.persistentContainer.viewContext.fetch(Record.fetchRequest())
                self.items = items
                print(self.items)
            }
            catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func saveRecord(with record: RecordModel){
       
            if validateIsNewItemCanBeSaved(){
                saveContext(record: record)
            }else{
                deleteFirstItem()
                saveContext(record: record)
            }
            
    }
    
    
    
}
