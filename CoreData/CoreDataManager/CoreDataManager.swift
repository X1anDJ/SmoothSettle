//
//  CoreDataManager.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager() // Singleton instance
    
    // Persistent container to manage the CoreData stack
    let persistentContainer: NSPersistentContainer
    
    // Private initializer to prevent creating multiple instances
    private init() {
        persistentContainer = NSPersistentContainer(name: "SmoothSettle")
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
//        resetPersistentStore() // Reset for testing
    }
    
    // Managed object context for performing operations
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Save changes in the context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func resetPersistentStore() {
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator

        if let storeURL = persistentContainer.persistentStoreDescriptions.first?.url {
            do {
                try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                // print("Persistent store reset successfully.")
            } catch {
                // print("Failed to reset persistent store: \(error)")
            }
        }
    }

}
