//
//  TodoToolbar.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 20.11.2024.
//

import SwiftUI

struct TodoToolbar: ToolbarContent {
    
    enum ToolbarAction {
        case settingsChanged
        case remove
    }
    
    @Binding var setting: TodoSetting
    @Binding var editMode: EditMode

    var action: ((ToolbarAction)->Void)?
    
    private var isEditing: Bool { editMode.isEditing }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Group {
                if isEditing {
                    EditButton()
                } else {
                    Menu {
                        CustomEditButton(editMode: $editMode) {
                            Label("Select tasks", systemImage: "checkmark.circle")
                        }
                        sortByMenu
                        sortOrderMenu
                        filterMenu
//                        removeButton // TODO: - No need
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .onChange(of: setting) { oldValue, newValue in
                guard oldValue != newValue else { return }
                action?(.settingsChanged)
            }
        }
    }
    
    private var sortByMenu: some View {
        Picker(selection: $setting.sortBy) {
            ForEach(TodoSorting.allCases) {
                Label($0.rawValue, systemImage: $0.imageName).tag($0)
            }
        } label: {
            Label("Sort by", systemImage: "list.bullet")
        }
        .pickerStyle(.menu)
    }
    
    private var sortOrderMenu: some View {
        Picker(selection: $setting.order) {
            ForEach(TodoSortOrder.allCases) {
                Label($0.rawValue, systemImage: $0.imageName).tag($0)
            }
        } label: {
            Label("Order", systemImage: "arrow.up.arrow.down")
        }
        .pickerStyle(.menu)
    }
    
    private var filterMenu: some View {
        Picker(selection: $setting.filter) {
            ForEach(TodoFiltering.allCases) {
                Text($0.rawValue).tag($0)
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease")
        }
        .pickerStyle(.menu)
    }
    
    private var removeButton: some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            action?(.remove)
        }
        .disabled(!editMode.isEditing)
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
        .toolbar { TodoToolbar(setting: .constant(.init()), editMode: .constant(.inactive)) { _ in } }
    }
}
