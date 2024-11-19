//
//  CoreDataManager.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 19.11.2024.
//

import CoreData

final class CoreDataManager {
    
//    private let queue = DispatchQueue(label: "CoreDataManager.queue", qos: .userInitiated)
    private let backgroundContext: NSManagedObjectContext
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
        backgroundContext = container.newBackgroundContext()
//        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//        backgroundContext.automaticallyMergesChangesFromParent = true
    }
}

extension CoreDataManager: DataManager {

    func fetchData(sortDescriptor: NSSortDescriptor?, predicate: NSPredicate?, _ completion: @escaping (Result<[TodoItem], any Error>) -> Void) {
        self.backgroundContext.perform { [weak self] in
            let request = TodoItem.fetchRequest()
            if let sortDescriptor {
                request.sortDescriptors = [sortDescriptor]
            }
            request.predicate = predicate
            do {
                let data = try self?.backgroundContext.fetch(request)
                DispatchQueue.main.async {
                    completion(.success(data ?? []))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func addNew(_ completion: @escaping (TodoItem) -> Void) {
        self.backgroundContext.perform { [weak self] in
            guard let self else { return }
            let newItem = TodoItem(context: self.backgroundContext)
            self.saveData {
                DispatchQueue.main.async {
                    completion(newItem)
                }
            }
        }
    }

    private func saveData(completion: (() -> Void)? = nil) {
        backgroundContext.perform { [weak self] in
            do {
                try self?.backgroundContext.save()
                DispatchQueue.main.async {
                    completion?()
                }
            } catch {
                print("Failed to save item: \(error)")
            }
        }
    }
    
    func save(_ apiData: [TodoServiceItem]) {
        backgroundContext.perform { [weak self] in
            for todo in apiData {
                _ = TodoItem(serviceItem: todo, context: self?.backgroundContext ?? NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType))
            }
            self?.saveData()
        }
    }
    
    func delete(_ data: TodoItem) {
        let id = data.objectID
        backgroundContext.perform { [weak self] in
            if let deleteItem = self?.backgroundContext.object(with: id) {
                self?.backgroundContext.delete(deleteItem)
                self?.saveData()
            }
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
