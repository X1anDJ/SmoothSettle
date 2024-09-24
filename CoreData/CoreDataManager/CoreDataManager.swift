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
}
