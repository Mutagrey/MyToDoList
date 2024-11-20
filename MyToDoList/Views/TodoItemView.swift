//
//  TodoItemView.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import SwiftUI

struct TodoItemView: View {
    
    @ObservedObject var todo: TodoItem
    var onAction: ((TodoAction) -> Void)?
    
    enum TodoAction {
        case edit, delete, completed
    }
    
    var body: some View {
        HStack(alignment: .top) {
            statusView
            VStack(alignment: .leading, spacing: 6) {
                titleView
                if let description = todo.taskDescription, !description.isEmpty {
                    descriptionView
                }
                createAtView
            }
            .opacity(todo.isCompleted ? 0.5 : 1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contextMenu { menuView }
        .swipeActions(edge: .trailing) {
            Button("", systemImage: "trash", role: .destructive) {
                onAction?(.delete)
            }
            let image = ImageRenderer(content: descriptionView).uiImage
            ShareLink(item: todo.taskDescription ?? "", preview:.init(todo.title ?? "Todo item", image: Image(uiImage: image ?? UIImage(systemName: "checkmark")!))) {
                Image(systemName: "square.and.arrow.up")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .leading) {
            Button("", systemImage: todo.isCompleted ? "xmark" : "checkmark") {
                onAction?(.completed)
            }
            .tint(todo.isCompleted ? .gray : .orange)
        }
    }
    
    private var statusView: some View {
        Image(systemName: todo.isCompleted ? "checkmark.circle" : "circle")
            .font(.title)
            .foregroundStyle(todo.isCompleted ? Color.accentColor : Color.secondary)
            .frame(maxHeight: .infinity, alignment: .top)
            .contentShape(.rect)
            .onTapGesture {
                withAnimation(.snappy) {
                    onAction?(.completed)
                }
            }
    }
    
    private var titleView: some View {
        Text(todo.title ?? "")
            .font(.headline)
            .foregroundStyle(todo.isCompleted ? Color.secondary : Color.primary)
            .strikethrough(todo.isCompleted, color: .secondary)
            .lineLimit(1)
    }
    
    private var descriptionView: some View {
        Text(todo.taskDescription ?? "")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(2)
    }
    
    private var createAtView: some View {
        Text("\((todo.createdAt ?? .now).formatted())")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    private var menuView: some View {
        VStack {
            Button("Edit", systemImage: "square.and.pencil") {
                onAction?(.edit)
            }
            ShareLink(item: todo.taskDescription ?? "", subject: Text(todo.title ?? "")) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Divider()
            Button("Delete", systemImage: "trash", role: .destructive) {
                onAction?(.delete)
            }
        }
    }
}
//
//#Preview {
//    ContentView()
//}
