//
//  APIService.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 18.11.2024.
//

import Foundation

protocol APIService {
    func fetchData() async throws -> [TodoServiceItem]
    func fetchData(_ completion: @escaping (Result<[TodoServiceItem], TodoError>) -> Void)
}
