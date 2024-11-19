//
//  TodoEditView.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import SwiftUI

struct TodoEditView: View {
    
    @EnvironmentObject private var vm: TodoViewModel
    @ObservedObject var todo: TodoItem
    
    init(todo: TodoItem) {
        self.todo = todo
    }
    
    var body: some View {
        VStack(spacing: 6) {
            DebounceTextField(
                "",
                text: Binding(get: { todo.title ?? "" }, set: { todo.title = $0 }),
                type: .textfield
            ) { text in
                vm.save()
            }
            .font(.title)
            .fontWeight(.semibold)
            
            Text((todo.createdAt ?? .now).formatted())
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DebounceTextField(
                "",
                text: Binding(get: { todo.taskDescription ?? "" }, set: { todo.taskDescription = $0 }),
                type: .textEditor
            ) { text in
                vm.save()
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoViewModel(dataManager: CoreDataManager(inMemory: true), apiService: TodoService()))
}
