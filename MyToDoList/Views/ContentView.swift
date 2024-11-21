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
    @State private var editMode = EditMode.inactive
    private var isEditing: Bool { editMode.isEditing }
    @State private var selection = Set<TodoItem.ID>()

    var body: some View {
        NavigationStack(path: $router.path) {
            listView
                .environment(\.editMode, $editMode)
                .refreshable { vm.fetchTodos(forceToUpdate: true) }
                .searchableWithDebounce(text: $vm.searchText, isPresentedSearch: $vm.isPresentedSearchText)
                .navigationTitle("Tasks")
                .navigationDestination(for: Route.self) { $0 }
                .toolbar(content: toolbarContent)
                .alert(isPresented: $vm.showError, error: vm.error) { }
        }
    }
    
    private func deleteTodos() {
        let selectedTodos = vm.todos.filter({ selection.isEmpty || selection.contains($0.id) })
        vm.deleteTodos(selectedTodos)
        withAnimation {
            editMode = .inactive
        }
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        bottomToolbar()
        KeyboardToolbar { vm.save() }
        TodoToolbar(setting: $vm.setting, editMode: $editMode) { action in
            switch action {
            case .settingsChanged: vm.fetchTodos()
            case .remove: deleteTodos()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func bottomToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            HStack {
                if isEditing {
                    Button("", systemImage: "trash", role: .destructive) {
                        deleteTodos()
                    }
                    .tint(.red)
                    .disabled(selection.isEmpty)
                }
                Spacer()
                ProgressView()
                    .opacity(vm.isLoading ? 1 : 0)
                Text(isEditing ? "Selected \(selection.count) tasks" : "\(vm.todos.count) tasks")
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
                .disabled(isEditing)
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
                        vm.deleteTodos([todo])
                    case .completed:
                        if !isEditing {
                            todo.isCompleted.toggle()
                            vm.save()
                        }
                    }
                }
                .contentShape(.rect)
                .onTapGesture {
                    if !isEditing {
                        router.push(route: .taskDetail(todo: todo))
                    } else {
                        selection.insert(todo.id)
                    }
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if vm.todos.isEmpty && !vm.isPresentedSearchText {
                ContentUnavailableView("No todos available", systemImage: "tray.fill", description: Text("Add new todo or refresh"))
            } else if vm.isPresentedSearchText && vm.todos.isEmpty {
                ContentUnavailableView.search
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
