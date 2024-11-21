//
//  TodoSetting.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 21.11.2024.
//

import CoreData

struct TodoSetting: Codable, Equatable {
    var sortBy: TodoSorting = .date
    var order: TodoSortOrder = .descending
    var filter: TodoFiltering = .all
}
