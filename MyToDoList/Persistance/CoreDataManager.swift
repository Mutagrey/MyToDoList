//
//  CoreDataManager.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 19.11.2024.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    /// A persistent container to set up the Core Data stack.
    let container: NSPersistentContainer
    
    private let inMemory: Bool

    private init(inMemory: Bool = false, container: NSPersistentContainer) {
        self.inMemory = inMemory
        self.container = container
        
        guard let _ = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        // viewContext properties for refreshing UI.
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.name = "viewContext"
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    private init(inMemory: Bool = false, model: TodoEntityModel = .main) {
        self.inMemory = inMemory
        self.container = NSPersistentContainer(name: model.rawValue)

        guard let _ = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        // viewContext properties for refreshing UI.
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.name = "viewContext"
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    /// Creates and configures a private queue context.
    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = container.newBackgroundContext()
        taskContext.automaticallyMergesChangesFromParent = true
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }
}

// MARK: - In memory CoreDataManager instance.
extension CoreDataManager {
    
    /// Create empty CoreDataManager in memory
    /// - For preview
    static let preview: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true)
        TodoItem.makePreviews(count: 10, context: manager.container.viewContext)
        return manager
    }()
    
    /// Create empty CoreDataManager in memory
    /// - For testing purposes
    static func inMemoryInstance(feedMockData: Bool = false, container: NSPersistentContainer? = nil) -> CoreDataManager {
        let manager: CoreDataManager
        if let container {
            manager = CoreDataManager(inMemory: true, container: container)
        } else {
            manager = CoreDataManager(inMemory: true)
        }
        if feedMockData {
            TodoItem.makePreviews(count: 10, context: manager.container.viewContext)
        }
        return manager
    }
}

// MARK: - DataManager implementation
extension CoreDataManager: DataManager {

    func fetchData(sortDescriptor: NSSortDescriptor?, predicate: NSPredicate?, _ completion: @escaping (Result<[TodoItem], DataManagerError>) -> Void) {
        let context = container.viewContext
        // Perform async code on the Main Thread
        context.perform {
            let request = NSFetchRequest<TodoItem>(entityName: "TodoItem")
            request.sortDescriptors = sortDescriptor.map { [$0] } ?? []
            request.predicate = predicate
            do {
                let data = try context.fetch(request)
                completion(.success(data))
            } catch {
                completion(.failure(.fetchError(error: error)))
            }
        }
    }
    
    /// Add new TodoItem
    func addNew(_ completion: @escaping (Result<TodoItem, DataManagerError>) -> Void) {
        let context = container.viewContext
        context.performAndWait {
            let newItem = TodoItem(context: context)
            newItem.createdAt = .now
            do {
                try context.save()
                completion(.success(newItem))
            } catch {
                completion(.failure(.creationError))
            }
        }
    }
    
    func update() throws {
        let context = container.viewContext
        try context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    throw DataManagerError.unexpectedError(error: error)
                }
            }
        }
    }
    
    /// Import service items to Core Data
    /// - Tag: Perform on background Thread
    func importData(from serviceItems: [TodoServiceItem]) throws {
        let context = newTaskContext()
        try context.performAndWait {
            for item in serviceItems {
                _ = TodoItem(serviceItem: item, context: context)
            }
            do {
                try context.save()
            } catch {
                throw DataManagerError.insertError
            }
        }
    }
    
    /// Delete Items
    func delete(_ items: [TodoItem]) throws {
        let objectIDs = items.map(\.objectID)
        let backgroundContext = newTaskContext()
        let context = container.viewContext
        try backgroundContext.performAndWait {
            do {
                // batch deletion
                let batchRequest = NSBatchDeleteRequest(objectIDs: objectIDs)
                let result = try backgroundContext.execute(batchRequest) as? NSBatchDeleteResult
                // merge changes to the context to reflect deletions
                if let deletedIDs = result?.result as? [NSManagedObjectID] {
                    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: deletedIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
            } catch {
                throw DataManagerError.deleteError
            }
        }
//        let objectIDs = items.map(\.objectID)
//        let context = newTaskContext()
//        try context.performAndWait {
//            // Execute the batch delete.
//            let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: objectIDs)
//            guard let fetchResult = try? context.execute(batchDeleteRequest),
//                  let batchDeleteResult = fetchResult as? NSBatchDeleteResult,
//                  let success = batchDeleteResult.result as? Bool, success
//            else {
//                throw DataManagerError.deleteError
//            }
//        }
    }
}
