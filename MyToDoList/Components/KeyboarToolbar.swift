//
//  KeyboarToolbar.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 21.11.2024.
//

import SwiftUI

struct KeyboardToolbar: ToolbarContent {
    
    var onTap: (() -> ())?
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            Button {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                onTap?()
            } label: {
                Text("Done")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
