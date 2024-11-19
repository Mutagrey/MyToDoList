//
//  DataManager.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 18.11.2024.
//

import CoreData

//protocol DataManager {
//    associatedtype Item
//    func fetchData(_ completion: @escaping (Result<[Item], Error>) -> Void)
//    func addNew(_ completion: @escaping (Result<Item, Error>) -> Void)
//    func save()
//    func delete(_ data: Item)
//}

protocol DataManager {
    func fetchData(sortDescriptor: NSSortDescriptor?, predicate: NSPredicate?, _ completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func addNew(_ completion: @escaping (TodoItem) -> Void)
    func save(_ apiData: [TodoServiceItem])
    func delete(_ data: TodoItem)
}
