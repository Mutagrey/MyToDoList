//
//  TodoItem.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 18.11.2024.
//

import CoreData

extension TodoItem {
    
    convenience init(serviceItem: TodoServiceItem, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = serviceItem.todo
        self.taskDescription = ""
        self.isCompleted = serviceItem.completed
        self.createdAt = .now
    }
    
    /// TodoItem for use with canvas previews.
    @MainActor
    static var preview: TodoItem {
        let viewContext = CoreDataManager.preview.container.viewContext
        let todos = TodoItem.makePreviews(count: 1, context: viewContext)
        return todos[0]
    }

    @discardableResult
    @MainActor
    static func makePreviews(count: Int, context: NSManagedObjectContext) -> [TodoItem] {
        var todos = [TodoItem]()
        let viewContext = context
        for index in 0..<count {
            let todo = TodoItem(context: viewContext)
            todo.title = "Some title for TodoItem\(index)"
            todo.createdAt = Date()
            todo.isCompleted = Bool.random()
            todo.taskDescription = "Some description for TodoItem\(index)"
            todos.append(todo)
        }
        return todos
    }
}

