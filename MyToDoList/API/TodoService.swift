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
        guard let url = URL(string: baseURL) else { throw APIError.invalidURL }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(TodoJSON.self, from: data).todos
        } catch let error as DecodingError {
            throw APIError.decodeError(error: error)
        } catch {
            throw APIError.requestError(error: error)
        }
    }
    
    func fetchData(_ completion: @escaping (Result<[TodoServiceItem], APIError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.requestError(error: error)))
            }
            
            guard let data = data else {
                completion(.failure(.missingData))
                return
            }
            
            do {
                let todos = try JSONDecoder().decode(TodoJSON.self, from: data)
                completion(.success(todos.todos))
            } catch {
                completion(.failure(.decodeError(error: error)))
            }
        }.resume()
    }
}
