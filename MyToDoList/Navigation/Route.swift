//
//  Route.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 18.11.2024.
//

import SwiftUI

enum Route: Hashable, Identifiable, View {
    var id: Self { self }
    
    case main
    case taskDetail(todo: TodoItem)
    
    var body: some View {
        switch self {
        case .main:
            ContentView()
        case .taskDetail(let todo):
            TodoEditView(todo: todo)
        }
    }
}
