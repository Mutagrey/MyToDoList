//
//  CoreDataManager.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 19.11.2024.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let inMemory: Bool

    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }
    
    /// Create empty CoreDataManager in memory
    /// - For testing purposes
    static let mock: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true)
        return manager
    }()
    
    @MainActor
    static let preview: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true)
        TodoItem.makePreviews(count: 10, context: manager.container.viewContext)
        return manager
    }()
    
    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "MyToDoList")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
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
        return container
    }()
    
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

// MARK: - DataManager implementation
extension CoreDataManager: DataManager {

    func fetchData(sortDescriptor: NSSortDescriptor?, predicate: NSPredicate?, _ completion: @escaping (Result<[TodoItem], DataManagerError>) -> Void) {
        let context = container.viewContext
        // Perform async code on the Main Thread
        context.perform {
            let request = TodoItem.fetchRequest()
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
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                throw DataManagerError.unexpectedError(error: error)
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
        let context = newTaskContext()
        let deleteIDs = items.map(\.objectID)
        // Perform async code on the Main Thread
        try context.performAndWait {
            for id in deleteIDs {
                // Safely fetch the object to delete using its object ID. Because objectID is Sendable.
                let deleteItem = context.object(with: id)
                context.delete(deleteItem)
            }
            // Save changes
            do {
                try context.save()
            } catch {
                throw DataManagerError.deleteError
            }
        }
    }
}
