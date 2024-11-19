//
//  ContentView.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TodoItem.createdAt, ascending: true)],
        animation: .default)
    private var items: FetchedResults<TodoItem>
    @State private var searchText = ""
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(items) { todo in
                    TodoItemView(todo: todo) { action in
                        switch action {
                        case .edit:
                            path.append(todo)
                        case .share:
                            break
                        case .delete:
                            viewContext.delete(todo)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(.plain)
            .navigationTitle("Tasks")
            .navigationDestination(for: TodoItem.self) {
                TodoEditView(todo: $0)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Text("\(items.count) tasks")
                        Spacer()
                        Button {
                            let newItem = TodoItem(context: viewContext)
                            path.append(newItem)
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "task...")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = TodoItem(context: viewContext)
            newItem.createdAt = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
