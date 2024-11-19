//
//  TodoServiceItem.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import Foundation

// MARK: - TodoServiceItems
struct TodoServiceItems: Codable {
    let todos: [TodoServiceItem]
    let total, skip, limit: Int
}

// MARK: - TodoServiceItem
struct TodoServiceItem: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case id, todo, completed
        case userID = "userId"
    }
}
