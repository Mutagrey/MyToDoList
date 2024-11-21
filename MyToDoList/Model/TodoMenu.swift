//
//  TodoMenu.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 21.11.2024.
//

import Foundation

enum TodoSorting: String, CaseIterable, Identifiable, Codable {
    case date = "Date"
    case title = "Title"
    
    var id: Self { self }
    
    var imageName: String {
        switch self {
        case .date: "calendar"
        case .title: "note.text"
        }
    }
}

enum TodoSortOrder: String, CaseIterable, Identifiable, Codable {
    case ascending = "Ascending"
    case descending = "Descending"
    
    var id: Self { self }

    var imageName: String {
        switch self {
        case .ascending: "arrowshape.down"
        case .descending: "arrowshape.up"
        }
    }
}

enum TodoFiltering: String, CaseIterable, Identifiable, Codable {
    case all = "All"
    case done = "Done"
    case undone = "Undone"

    var id: Self { self }
}
