//
//  TodoItem+.swift
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
}

