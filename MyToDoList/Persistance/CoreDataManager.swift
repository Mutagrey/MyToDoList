//
//  CoreDataManager.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 19.11.2024.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer

    @MainActor
    static let preview: CoreDataManager = {
        let result = CoreDataManager(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newItem = TodoItem(context: viewContext)
            newItem.title = "Some title \(i)"
            newItem.createdAt = Date()
            newItem.isCompleted = Bool.random()
            newItem.taskDescription = "Some description \(i)"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MyToDoList")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores{ (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
}

extension CoreDataManager: DataManager {

    func fetchData(sortDescriptor: NSSortDescriptor?, predicate: NSPredicate?, _ completion: @escaping (Result<[TodoItem], any Error>) -> Void) {
        let context = self.container.viewContext
        // Perform async code on the Main Thread
        context.perform {
            let request = TodoItem.fetchRequest()
            request.sortDescriptors = sortDescriptor.map { [$0] } ?? []
            request.predicate = predicate
            do {
                let data = try context.fetch(request)
                completion(.success(data))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    func addNew(_ completion: @escaping (TodoItem) -> Void) {
        self.container.performBackgroundTask { context in
            let newItem = TodoItem(context: context)
            self.saveData(context: context)
            DispatchQueue.main.async {
                if let object = context.object(with: newItem.objectID) as? TodoItem {
                    completion(object)
                }
            }
        }
    }

    private func saveData(context: NSManagedObjectContext) {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Failed to save item: \(error)")
        }
    }
    
    func saveData() {
        let context = self.container.viewContext
        context.perform {
            self.saveData(context: context)
        }
    }
    
    func save(_ apiData: [TodoServiceItem]) {
        self.container.performBackgroundTask { context in
            for todo in apiData {
                _ = TodoItem(serviceItem: todo, context: context)
            }
            self.saveData(context: context)
        }
    }
    
    func delete(_ data: TodoItem) {
        let context = self.container.viewContext
        // Perform async code on the Main Thread
        context.performAndWait {
            // Safely fetch the object to delete using its object ID
            let deleteItem = context.object(with: data.objectID)
            context.delete(deleteItem)
            self.saveData(context: context)
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
