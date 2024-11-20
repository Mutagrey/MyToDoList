//
//  ContentView.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @EnvironmentObject private var vm: TodoViewModel
    @EnvironmentObject private var router: Router
    @State private var selection: Set<TodoItem> = []
    
    var body: some View {
        NavigationStack(path: $router.path) {
            listView
                .environment(\.editMode, $vm.setting.editMode)
                .refreshable { vm.fetchTodos(forceToUpdate: true) }
                .searchable(text: $vm.searchText, isPresented: $vm.isPresentedSearchText)
                .navigationTitle("Tasks")
                .navigationDestination(for: Route.self) { $0 }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) { bottomBarView }
                    TodoToolbar(setting: $vm.setting) { action in
                        switch action {
                        case .remove:
                            vm.deleteTodo(Array(selection))
                        }
                    }
                }
                .alert(isPresented: $vm.showError, error: vm.error) { }
        }
    }
    
    private var bottomBarView: some View {
        HStack {
            Spacer()
            ProgressView()
                .opacity(vm.isLoading ? 1 : 0)
            Text("\(vm.todos.count) tasks")
                .font(.caption)
                .contentTransition(.numericText(value: Double(vm.todos.count)))
                .animation(.bouncy, value: vm.todos.count)
            Spacer()
            Button {
                vm.addNewTodo { todo in
                    router.push(route: .taskDetail(todo: todo))
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
        }
    }
    
    private var listView: some View {
        List(selection: $selection) {
            ForEach(vm.todos) { todo in
                TodoItemView(todo: todo) { action in
                    switch action {
                    case .edit:
                        router.push(route: .taskDetail(todo: todo))
                    case .delete:
                        vm.deleteTodo([todo])
                    case .completed:
                        todo.isCompleted.toggle()
                        vm.update()
                    }
                }
                .contentShape(.rect)
                .onTapGesture {
                    router.push(route: .taskDetail(todo: todo))
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
    @Previewable var manager = CoreDataManager.preview
    return  ContentView()
        .environmentObject(TodoViewModel(dataManager: manager, apiService: TodoService()))
        .environmentObject(Router())
}
