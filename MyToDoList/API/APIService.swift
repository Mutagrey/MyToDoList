//
//  APIService.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 18.11.2024.
//

import Foundation

//protocol AnyAPIService {
//    associatedtype Item: Decodable
//    func fetchData(_ completion: @escaping (Result<[Item], Error>) -> Void)
//}

protocol APIService {
    func fetchData(_ completion: @escaping (Result<[TodoServiceItem], Error>) -> Void)
}
