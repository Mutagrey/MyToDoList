//
//  Router.swift
//  DIetDiary
//
//  Created by Sergey Petrov on 15.01.2024.
//

import SwiftUI

final class Router: ObservableObject {
    
    @Published var path = NavigationPath()
    @Published var sheet: Route?
    
    func reset() {
        path.removeLast(path.count)
    }
    
    func push(route: Route) {
        path.append(route)
    }
}
