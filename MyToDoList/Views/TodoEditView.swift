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
    
    enum FocusedField: Hashable {
        case title, taskDescription
    }
    @FocusState var focusedField: FocusedField?
    
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
            .focused($focusedField, equals: .title)
            
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
            .focused($focusedField, equals: .taskDescription)

        }
        .padding(.top)
        .padding(.horizontal)
        .onAppear {
            focusedField = (todo.title ?? "").isEmpty ? .taskDescription : .title
        }
        .toolbar {
            KeyboardToolbar { vm.save() }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoViewModel(dataManager: CoreDataManager.preview, apiService: TodoService()))
}
