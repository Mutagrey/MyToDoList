//
//  MyToDoListTests.swift
//  MyToDoListTests
//
//  Created by Sergey Petrov on 15.11.2024.
//

import CoreData
import XCTest
@testable import MyToDoList

final class MyToDoListTests: XCTestCase {

    var viewModel: TodoViewModel!
    var dataManager: CoreDataManager!
    var apiService: APIService!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let container = NSPersistentContainer(name: TodoEntityModel.main.rawValue)
//        container.loadPersistentStores { (storeDescription, error) in
//            if let error = error as NSError? {
//                XCTFail("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
        dataManager = CoreDataManager.inMemoryInstance()
        apiService = TodoService()
        viewModel = TodoViewModel(dataManager: dataManager, apiService: apiService)
        // Wait for fetching data
        wait(for: [], timeout: 5)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dataManager = nil
        apiService = nil
        viewModel = nil
        try super.tearDownWithError()
    }
    
    func testDataManagerAddTodo() throws {
        let addExpectation = XCTestExpectation(description: "Add todo")
        dataManager.addNew { result in
            addExpectation.fulfill()
            switch result {
            case .success(_):
                XCTAssert(true, "Todo added")
            case .failure(let failure):
                XCTFail(failure.localizedDescription)
            }
        }
        wait(for: [addExpectation], timeout: 10.0)
    }
    
    func testDataManagerFetchTodos() throws {
        // Add new item
        let context = dataManager.container.viewContext
        _ = TodoItem(context: context)
        XCTAssertNoThrow(try context.save())
        // fetch
        let fetchExpectation = XCTestExpectation(description: "Fetch data")
        dataManager.fetchData(sortDescriptor: TodoItem.sortDescriptor(by: .date, order: .descending), predicate: TodoItem.predicate(text: nil)) { result in
            fetchExpectation.fulfill()
            switch result {
            case .success(let data):
                XCTAssertGreaterThan(data.count, 0)
                XCTAssertEqual(data.count, 1)
            case .failure(let failure):
                XCTFail(failure.localizedDescription)
            }
        }
        wait(for: [fetchExpectation], timeout: 10.0)
    }
    
    func testDataManagerDeleteTodos() throws {
        let context = dataManager.container.viewContext
        // add new todo
        let todo = TodoItem(context: context)
        todo.title = "Test todo"
        todo.taskDescription = "Test task description"
        todo.createdAt = Date()
        XCTAssertNoThrow(try context.save())
        // fetch todos
        let request = NSFetchRequest<TodoItem>(entityName: "TodoItem")
        let todos = try context.fetch(request)
        XCTAssertGreaterThan(todos.count, 0)
        // Delete todos
        try dataManager.delete(todos)
        wait(for: [], timeout: 5.0)
        // refetch to check deletion
        let todosAfterDeletion = try context.fetch(request)
        XCTAssertEqual(todosAfterDeletion.count, 0)
    }
    
    func testViewModelAddTodo() throws {
        let initialCount = viewModel.todos.count
        let expectation = XCTestExpectation(description: "Add todo")
        viewModel.addNewTodo { todo in
            expectation.fulfill()
            self.wait(for: [], timeout: 5.0)
            XCTAssertEqual(self.viewModel.todos.count, initialCount + 1)
        }
        wait(for: [expectation], timeout: 5.0)
        XCTAssertNil(self.viewModel.error)
        XCTAssertEqual(self.viewModel.showError, false)
        XCTAssertEqual(self.viewModel.todos.count, initialCount + 1)
    }
    
    func testViewModelFetchTodos() throws {
        let initialCount = viewModel.todos.count
        viewModel.fetchTodos(forceToUpdate: false)
        wait(for: [], timeout: 5.0)
        XCTAssertNil(self.viewModel.error)
        XCTAssertEqual(self.viewModel.showError, false)
        XCTAssertGreaterThanOrEqual(self.viewModel.todos.count, initialCount)
    }
    
    func testViewModelDeleteTodo() throws {
        let initialCount = viewModel.todos.count
        for _ in (0..<2) {
            let expectation = XCTestExpectation(description: "Add todo")
            viewModel.addNewTodo { todo in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
        XCTAssertNil(self.viewModel.error)
        XCTAssertEqual(self.viewModel.showError, false)
        XCTAssertEqual(self.viewModel.todos.count, initialCount + 2)
        // delete
        viewModel.deleteTodos(self.viewModel.todos)
        wait(for: [], timeout: 5.0)
        XCTAssertEqual(self.viewModel.todos.count, 0)
    }
    
    func testAPIService() throws {
        let expectation = XCTestExpectation(description: "Fetch data")
        apiService.fetchData { result in
            expectation.fulfill()
            switch result {
            case .success(let data):
                XCTAssertGreaterThan(data.count, 0)
                XCTAssertEqual(data.count, 30)
            case .failure(let failure):
                XCTFail(failure.localizedDescription)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

}
