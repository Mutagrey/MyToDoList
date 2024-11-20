//
//  TodoService.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import Foundation
import CoreData

final class TodoService: APIService {
    
    private let baseURL = "https://dummyjson.com/todos"
    
    func fetchData() async throws -> [TodoServiceItem] {
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(TodoJSON.self, from: data).todos
    }
    
    func fetchData(_ completion: @escaping (Result<[TodoServiceItem], TodoError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.unexpectedError(error: URLError(.badURL))))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.errorMessage(msg: error.localizedDescription)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.missingData))
                }
                return
            }
            
            do {
                let todos = try JSONDecoder().decode(TodoJSON.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(todos.todos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.wrongDataFormat(error: error)))
                }
            }
        }
        
        task.resume()
    }
}
