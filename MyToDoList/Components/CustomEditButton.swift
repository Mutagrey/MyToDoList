//
//  CustomEditButton.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 21.11.2024.
//

import SwiftUI

/// Creates a custom `EditButton` that displays a custom label.
///
/// - Parameters:
///   - action: The action to perform when the user triggers the button.
///   - label: A view that describes the purpose of the button's `action`.
struct CustomEditButton<Label: View>: View {

    var animation: Animation?
    @Binding var editMode: EditMode
    var action: (() -> Void)?
    var label: () -> Label
    @Environment(\.editMode) private var editModeEnv

    init(
        _ animation: Animation? = .default,
        editMode: Binding<EditMode>,
        action: (() -> Void)? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._editMode = editMode
        self.animation = animation
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button {
            withAnimation(animation) {
                if editMode.isEditing == true {
                    editMode = .inactive
                } else {
                    editMode = .active
                }
                action?()
            }
        } label: {
            label()
        }
    }
}

fileprivate struct HelperView: View {
    @State var selection = Set<Int>()
    @State private var editMode: EditMode = .inactive
//    @Environment(\.editMode) private var editMode
    var isEditing: Bool { (editMode.isEditing) }
    var body: some View {
        NavigationStack {
            List(selection: $selection) {
                Image(systemName: isEditing ? "bolt" : "tray.fill")
                    .font(.title)
                ForEach(0..<10) { i in
                    Text("Item\(i)")
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Edit button")
            .toolbar {
                ToolbarItem {
                    CustomEditButton(editMode: $editMode) {
                        //
                    } label: {
                        VStack {
                            Text(isEditing ? "Done_custom" : "Edit_custom")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HelperView()
}
