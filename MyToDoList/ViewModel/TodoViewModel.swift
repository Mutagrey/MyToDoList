//
//  TodoViewModel.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 16.11.2024.
//

import SwiftUI
import Combine

final class TodoViewModel: ObservableObject {
    
    @AppStorage("fetchFromService") private(set) var fetchFromService = true
    @Published private(set) var todos: [TodoItem] = []
    @Published private var apiTodos: [TodoServiceItem] = []
    @Published private(set) var isLoading: Bool = false
    
    @Published private(set) var error: TodoError?
    @Published var showError: Bool = false

    @Published var searchText: String = ""
    @Published var isPresentedSearchText: Bool = false

    @Published var setting: TodoSetting = .init()

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
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text.isEmpty {
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
            .sink { [weak self] todos in
                if !todos.isEmpty {
                    do {
                        try self?.dataManager.importData(from: todos)
                        self?.fetchTodosWithDataManager()
                        self?.fetchFromService = false
                    } catch {
                        self?.error = .unexpectedError(error: error)
                        self?.showError = true
                    }
                }
            }
            .store(in: &cancellables)
        
//        $setting
//            .sink { [weak self] setting in
//                self?.fetchTodosWithDataManager()
//            }
//            .store(in: &cancellables)
    }
    
    /// Fetch Todos from DataManager
    private func fetchTodosWithDataManager() {
        isLoading = true
        // SortDescriptor and Predicate
        let sort = TodoItem.sortDescriptor(by: setting.sortBy, order: setting.order)
        let predicate = TodoItem.predicate(text: searchText, filter: setting.filter)
        // fetch data
        dataManager.fetchData(sortDescriptor: sort, predicate: predicate) { [weak self] result in
            switch result {
            case .success(let data):
                self?.todos = []
                self?.todos = data
            case .failure(let failure):
                self?.error = failure
                self?.showError = true
            }
            self?.isLoading = false
        }
    }
    
    /// Fetch Todos from API Service
    private func fetchTodosWithAPICall() {
        isLoading = true
        apiService.fetchData { [weak self] result in
            switch result {
            case .success(let data):
                self?.apiTodos = data
            case .failure(let failure):
                self?.error = .unexpectedError(error: failure)
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
        dataManager.addNew { [weak self] result in
            switch result {
            case .success(let data):
                self?.fetchTodosWithDataManager()
                completion(data)
            case .failure(let failure):
                self?.error = failure
                self?.showError = true
            }
        }
    }
    
    /// Delete Todo
    func deleteTodos(_ items: [TodoItem]) {
        do {
            try dataManager.delete(items)
            fetchTodosWithDataManager()
        } catch {
            self.error = error as? TodoError
            self.showError = true
        }
    }
    
    ///  Update
    func save() {
        do {
            try dataManager.update()
        } catch {
            self.error = error as? TodoError
            self.showError = true
        }
    }
}
