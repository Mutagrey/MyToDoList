//
//  MyToDoListApp.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import SwiftUI

@main
struct MyToDoListApp: App {

    @StateObject private var vm = TodoViewModel(dataManager: CoreDataManager.shared,
                                                apiService: TodoService())
    @StateObject private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
                .environmentObject(vm)
                .environmentObject(router)
        }
    }
}
