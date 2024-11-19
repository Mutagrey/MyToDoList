//
//  TodoEditView.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import SwiftUI

struct TodoEditView: View {
    
    @ObservedObject var todo: TodoItem

    var body: some View {
        VStack {
            TextField("Title", text: Binding(get: {
                todo.title ?? ""
            }, set: {
                todo.title = $0
            }))
            .font(.title)
            .fontWeight(.semibold)
            
            Text("\((todo.createdAt ?? .now).formatted())")
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: Binding(get: {
                todo.taskDescription ?? ""
            }, set: {
                todo.taskDescription = $0
            }))
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
