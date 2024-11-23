//
//  TodoItem.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 18.11.2024.
//

import CoreData

// MARK: - Core Data
//
///// Managed object subclass for the Todo entity.
//final public class TodoItem: NSManagedObject {
//    @NSManaged public var title: String?
//    @NSManaged public var taskDescription: String?
//    @NSManaged public var createdAt: Date?
//    @NSManaged public var isCompleted: Bool
//}
//
//extension TodoItem: Identifiable { }

extension TodoItem {
    
    convenience init(serviceItem: TodoServiceItem, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = serviceItem.todo
        self.taskDescription = ""
        self.isCompleted = serviceItem.completed
        self.createdAt = Date()
    }
    
    /// TodoItem for use with canvas previews.
    @MainActor
    static var preview: TodoItem {
        let viewContext = CoreDataManager.preview.container.viewContext
        let todos = TodoItem.makePreviews(count: 1, context: viewContext)
        return todos[0]
    }

    @discardableResult
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
        try? context.save()
        return todos
    }
    
    /// Predicate for filtering fetch request by given text
    static func predicate(text: String?, filter: TodoFiltering = .all) -> NSPredicate? {
        switch filter {
        case .all:
            if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return NSPredicate(format: "title contains [cd] %@ OR taskDescription contains [cd] %@", argumentArray: [text, text])
            }
            return nil
        case .done:
            if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return NSPredicate(format: "(title contains [cd] %@ OR taskDescription contains [cd] %@) AND isCompleted == %@", argumentArray: [text, text, NSNumber(value: true)])
            }
            return NSPredicate(format: "isCompleted == %@", NSNumber(value: true))
        case .undone:
            if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return NSPredicate(format: "(title contains [cd] %@ OR taskDescription contains [cd] %@) AND isCompleted == %@", argumentArray: [text, text, NSNumber(value: false)])
            }
            return NSPredicate(format: "isCompleted == %@", NSNumber(value: false))
        }
    }
    
    /// Sort descriptor by given settings
    static func sortDescriptor(by sorting: TodoSorting, order: TodoSortOrder) -> NSSortDescriptor {
        switch sorting {
        case .date:
            NSSortDescriptor(keyPath: \TodoItem.createdAt, ascending: order == .ascending)
        case .title:
            NSSortDescriptor(keyPath: \TodoItem.title, ascending: order == .ascending)
        }
    }
}

