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
    private let queue = DispatchQueue(label: "TodoService.queue", qos: .background)

    func fetchData(_ completion: @escaping (Result<[TodoServiceItem], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        queue.async {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No data returned", code: 0, userInfo: nil)))
                    }
                    return
                }
                
                do {
                    let todos = try JSONDecoder().decode(TodoServiceItems.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(todos.todos))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            
            task.resume()
        }
        
    }
}
