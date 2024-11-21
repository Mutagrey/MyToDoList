//
//  TodoToolbar.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 20.11.2024.
//

import SwiftUI

enum SortByMenu: String, CaseIterable {
    case date = "Date"
    case title = "Title"
    
    var imageName: String {
        switch self {
        case .date: "calendar"
        case .title: "rectangle.and.pencil.and.ellipsis"
        }
    }
}

enum Order: String, CaseIterable {
    case ascending = "ascending"
    case descending = "descending"
    
    var imageName: String {
        switch self {
        case .ascending: "arrowshape.up.fill"
        case .descending: "arrowshape.down.fill"
        }
    }
}


// MARK: - SwiftUI
struct TodoToolbar: ToolbarContent {
    
    enum ToolbarAction {
        case remove
    }
    
    @Environment(\.editMode) private var editMode
    @Binding var setting: TodoSetting
    var action: ((ToolbarAction)->Void)?
    
    private var isEditing: Bool { editMode?.wrappedValue.isEditing ?? false }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Group {
                if isEditing {
                    EditButton()
                        .contentTransition(.symbolEffect(.replace))
                } else {
                    Menu {
                        Button("Select tasks", systemImage: "checkmark.circle") {
                            withAnimation {
                                if !isEditing {
                                    editMode?.wrappedValue = .active
                                }
                            }
                        }
                        .contentTransition(.symbolEffect(.replace))
                        Menu {
                            ForEach(SortByMenu.allCases, id: \.self) {
                                sortButton($0)
                            }
                        } label: {
                            Text("Sort by")
                        }
                        
                        Menu {
                            ForEach(Order.allCases, id: \.self) {
                                ordeButton($0)
                            }
                        } label: {
                            Text("Order")
                        }
                        
                        Button("Remove", systemImage: "trash", role: .destructive) {
                            action?(.remove)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .animation(.smooth, value: isEditing)
        }
    }
    
    
    private func sortButton(_ sortBy: SortByMenu) -> some View {
        Button {
            self.setting.sortBy = sortBy
        } label: {
            if self.setting.sortBy == sortBy {
                Label(sortBy.rawValue, systemImage: "checkmark")
            } else {
                Text(sortBy.rawValue)
            }
        }
    }
    
    private func ordeButton(_ order: Order) -> some View {
        Button {
            self.setting.order = order
        } label: {
            if self.setting.order == order {
                Label(order.rawValue, systemImage: "checkmark")
            } else {
                Text(order.rawValue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            ForEach(0..<10) { id in
                Text("Item\(id)")
            }
        }
        .navigationTitle("Tasks")
        .toolbar { TodoToolbar(setting: .constant(.init())) { _ in } }
    }
}
