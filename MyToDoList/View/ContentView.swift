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
    @State private var path = NavigationPath()
    @EnvironmentObject private var vm: TodoViewModel
    
    var body: some View {
        NavigationStack(path: $path) {
            TodoListView()
                .refreshable { vm.fetchTodos(forceToUpdate: true) }
                .searchable(text: $vm.searchText, isPresented: $vm.isPresentedSearchText)
                .navigationTitle("Tasks")
                .navigationDestination(for: TodoItem.self) {
                    TodoEditView(todo: $0)
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) { bottomBarView }
                }
                .alert(vm.errorMessage, isPresented: $vm.showError) { alertView }
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
                    path.append(todo)
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
        }
    }
    
    private var alertView: some View {
        VStack {
            Button("OK") {
                vm.showError = false
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(TodoViewModel(dataManager: CoreDataManager(inMemory: true), apiService: TodoService()))
}
