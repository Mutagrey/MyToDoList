//
//  DataManager.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 18.11.2024.
//

import CoreData

// MARK: - GCD
protocol DataManager {
    func fetchData(sortDescriptor: NSSortDescriptor?, predicate: NSPredicate?, _ completion: @escaping (Result<[TodoItem], TodoError>) -> Void)
    func addNew(_ completion: @escaping (Result<TodoItem, TodoError>) -> Void)
    func importData(from serviceItems: [TodoServiceItem]) throws
    func update() throws
    func delete(_ items: [TodoItem]) throws
}

// MARK: - Async/await
//protocol DataManager {
//    func fetchData() async throws -> [TodoItem]
//    func addNew() async throws -> TodoItem
//    func delete(_ items: [TodoItem]) async throws
//}
