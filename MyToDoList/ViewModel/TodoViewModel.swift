//
//  TodoViewModel.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 16.11.2024.
//

import SwiftUI
import Combine

final class TodoViewModel: ObservableObject {
    
    @AppStorage("fetchFromService") private var fetchFromService = true
    @Published private(set) var todos: [TodoItem] = []
    @Published private var apiTodos: [TodoServiceItem] = []
    @Published private(set) var isLoading: Bool = false
    
    @Published private(set) var errorMessage: String = ""
    @Published var showError: Bool = false

    @Published var searchText: String = ""
    @Published var isPresentedSearchText: Bool = false

    private let dataManager: DataManager
    private let apiService: APIService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager, apiService: APIService) {
        self.dataManager = dataManager
        self.apiService = apiService
        addObservers()
        fetchTodos()
    }
    
    /// Add Observers
    private func addObservers() {
        $searchText
            .debounce(for: .milliseconds(75), scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self else { return }
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.fetchTodosWithDataManager()
                }
            }
            .store(in: &cancellables)
        
        $isPresentedSearchText
            .sink { [weak self] isPresented in
                guard let self else { return }
                if !isPresented {
                    self.searchText = ""
                    self.fetchTodosWithDataManager()
                }
            }
            .store(in: &cancellables)
        
        $apiTodos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] todos in
                if !todos.isEmpty {
                    self?.dataManager.save(todos)
                    self?.fetchTodosWithDataManager()
                    self?.fetchFromService = false
                }
            }
            .store(in: &cancellables)
    }
    
    /// Fetch Todos from DataManager
    private func fetchTodosWithDataManager() {
        isLoading = true
        errorMessage = ""
        showError = false
        
        // SortDescriptor and Predicate
        let sort = NSSortDescriptor(keyPath: \TodoItem.createdAt, ascending: true)
        let predicate: NSPredicate
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSPredicate(format: "title contains [cd] %@ OR taskDescription contains [cd] %@", argumentArray: [searchText, searchText])
        }
        
        // fetch data
        dataManager.fetchData(sortDescriptor: sort, predicate: predicate) { [weak self] result in
            switch result {
            case .success(let data):
                self?.todos = data
            case .failure(let failure):
                self?.todos = []
                self?.errorMessage = "Error to fetch data from DataManager: \n\(failure.localizedDescription)"
                self?.showError = true
            }
            self?.isLoading = false
        }
    }
    
    /// Fetch Todos from API Service
    private func fetchTodosWithAPICall() {
        isLoading = true
        errorMessage = ""
        showError = false
        apiService.fetchData { [weak self] result in
            switch result {
            case .success(let data):
                self?.apiTodos = data
            case .failure(let failure):
                self?.errorMessage = "Error to fetch data from API Service: \n\(failure.localizedDescription)"
                self?.showError = true
            }
            self?.isLoading = false
        }
    }
 
}

// MARK: - Intent`s
extension TodoViewModel {
    
    /// Fetch Todos
    func fetchTodos(forceToUpdate: Bool = false) {
        if fetchFromService || forceToUpdate {
            fetchTodosWithAPICall()
        } else {
            fetchTodosWithDataManager()
        }
    }
    
    /// Add new Todo
    func addNewTodo(_ completion: @escaping (TodoItem) -> Void) {
        dataManager.addNew { [weak self] data in
//            self.todos.insert(data, at: 0)
            self?.fetchTodosWithDataManager()
            completion(data)
        }
    }
    
    /// Delete Todo
    func deleteTodo(_ item: TodoItem) {
//        if let index = self.todos.firstIndex(where: { $0.objectID == item.objectID }) {
//            self.todos.remove(at: index)
//        }
        dataManager.delete(item)
        fetchTodosWithDataManager()
    }
    
    ///  Update
    func save() {
        dataManager.save([])
    }
    
    ///  Update
    func update() {
        dataManager.save([])
        fetchTodosWithDataManager()
    }
}
