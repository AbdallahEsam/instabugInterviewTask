//
//  CoreDataStack.swift
//  InstabugNetworkClient
//
//  Created by Abdallah Essam on 16/04/2022.
//

import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    var persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    private init() {
        persistentContainer = NSPersistentContainer(name:  CoreDataStack.Defaults.coreDataName)
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = NSSQLiteStoreType
        
        persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError("was unable to load store \(error!)")
            }
        }
        
        mainContext = persistentContainer.viewContext
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.parent = self.mainContext
    }
}

extension CoreDataStack {
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
