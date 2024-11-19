//
//  TodoListView.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 18.11.2024.
//

import SwiftUI

struct TodoListView: View {
    
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var vm: TodoViewModel
    
    var body: some View {
        List {
            ForEach(vm.todos) { todo in
                TodoItemView(todo: todo) { action in
                    switch action {
                    case .edit:
                        router.push(route: .taskDetail(todo: todo))
                    case .delete:
                        vm.deleteTodo(todo)
                    case .completed:
                        todo.isCompleted.toggle()
                        vm.save()
                    }
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if vm.todos.isEmpty {
                ContentUnavailableView("No todos available", systemImage: "tray.fill", description: Text("Add new todo or refresh"))
            }
        }
    }
}

#Preview {
    @Previewable @State var router = Router()
    return NavigationStack(path: $router.path) {
        TodoListView()
            .navigationTitle("Todos")
            .environmentObject(TodoViewModel(dataManager: CoreDataManager.preview, apiService: TodoService()))
            .environmentObject(router)
    }
}