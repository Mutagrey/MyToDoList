//
//  MyToDoListTests.swift
//  MyToDoListTests
//
//  Created by Sergey Petrov on 15.11.2024.
//

import XCTest
@testable import MyToDoList

final class MyToDoListTests: XCTestCase {

    var viewModel: TodoViewModel!
    var dataManager: DataManager!
    var apiService: APIService!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataManager = CoreDataManager.preview
        apiService = TodoService()
        viewModel = TodoViewModel(dataManager: dataManager, apiService: apiService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dataManager = nil
        apiService = nil
        viewModel = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        XCTAssertEqual(viewModel.todos.count, 0)
//        XCTAssertEqual(viewModel.fetchFromService, true)
        
        viewModel.fetchTodos()

        XCTAssertEqual(viewModel.showError, false)
        
        viewModel.addNewTodo { todo in
//            XCTAssertEqual(viewModel.todos.count, 31)
//            viewModel.deleteTodo([todo])
//            XCTAssertEqual(viewModel.todos.count, 30)
        }
//        XCTAssertNoThrow
    }
    
    func testAPIService() throws {
        apiService.fetchData { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data.count, 30)
            case .failure(let failure):
                XCTAssertNoThrow(failure)
            }
        }
    }
    
    func testDataMAnager() throws {
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            viewModel.fetchTodos()
        }
    }

}
