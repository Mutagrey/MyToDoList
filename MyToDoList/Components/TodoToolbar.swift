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

struct TodoSetting {
    var sortBy: SortByMenu = .date
    var order: Order = .descending
    var editMode: EditMode = .inactive
}

struct TodoToolbar: ToolbarContent {
    
    enum ToolbarAction {
        case remove
    }
    
    @Binding var setting: TodoSetting
    var action: ((ToolbarAction)->Void)?
    
    private var isEditing: Bool {
        setting.editMode.isEditing
    }
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
                                setting.editMode = .active
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
            .environment(\.editMode, $setting.editMode)
        }
    }
    
    
    private func sortButton(_ sortBy: SortByMenu) -> some View {
        Button(sortBy.rawValue, systemImage: self.setting.sortBy == sortBy ? "checkmark" : "") {
            self.setting.sortBy = sortBy
        }
    }
    
    private func ordeButton(_ order: Order) -> some View {
        Button(order.rawValue, systemImage: self.setting.order == order ? "checkmark" : "") {
            self.setting.order = order
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
