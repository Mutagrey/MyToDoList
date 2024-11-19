//
//  MyToDoListApp.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 15.11.2024.
//

import SwiftUI

@main
struct MyToDoListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
