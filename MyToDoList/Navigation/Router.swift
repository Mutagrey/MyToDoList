//
//  Router.swift
//  DIetDiary
//
//  Created by Sergey Petrov on 15.01.2024.
//

import SwiftUI

@Observable
final class Router {
    
    var path = NavigationPath()
    var sheet: Route?
    
    func reset() {
        path.removeLast(path.count)
    }
    
    func gotoLink(route: Route) {
        path.append(route)
    }
    
    func gotoSheet(route: Route) {
        sheet = route
    }
    
    func gotoSheet(note: Note) {
        sheet = getRoute(note: note)
    }
    
    func gotoNewSheet(noteType: NoteType) {
        switch noteType {
            case .food:
                sheet = .foodNote(nil)
            case .weight:
                sheet = .weightNote(nil)
            case .activity:
                sheet = .activityNote(nil)
            case .diabet:
                sheet = .diabetNote(nil)
        }
    }
    
    private func getRoute(note: Note) -> Route? {
        switch note {
            case let food as FoodNote:
                Route.foodNote(food)
            case let weight as WeightNote:
                Route.weightNote(weight)
            case let activity as ActivityNote:
                Route.activityNote(activity)
            case let diabet as DiabetNote:
                Route.diabetNote(diabet)
            default: nil
        }
    }
}
