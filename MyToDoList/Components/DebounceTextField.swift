//
//  DebounceTextField.swift
//  MyToDoList
//
//  Created by Sergey Petrov on 19.11.2024.
//

import Combine
import SwiftUI

struct DebounceTextField: View {
    
    enum TextFieldType {
        case textfield
        case securefield
        case textEditor
    }
    
    var titleKey: LocalizedStringKey
    @Binding var text: String
    var axis: Axis = .vertical
    var type: TextFieldType = .textfield
    var debounceTime: TimeInterval = 0.75
    var onSave: ((String) -> Void)?
    
    @StateObject private var vm: ViewModel
    
    init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        axis: Axis = .vertical,
        type: TextFieldType = .textfield,
        debounceTime: TimeInterval = 0.75,
        onSave: ((String) -> Void)? = nil
    ) {
        self._vm = StateObject(wrappedValue: ViewModel(debounceTime: debounceTime))
        self.titleKey = titleKey
        self._text = text
        self.axis = axis
        self.type = type
        self.debounceTime = debounceTime
        self.onSave = onSave
    }
    
    var body: some View {
        Group {
            switch type {
            case .textfield:
                TextField(titleKey, text: $vm.text, axis: axis)
            case .securefield:
                SecureField(titleKey, text: $vm.text)
            case .textEditor:
                TextEditor(text: $vm.text)
            }
        }
        .onReceive(vm.saveRequest) { text in
            self.text = text
            onSave?(text)
        }
    }
}

extension DebounceTextField {
    final class ViewModel: ObservableObject {
        @Published var text = ""
        
        private var debounceTime: TimeInterval = 0.75
        private var cancellables = Set<AnyCancellable>()
        let saveRequest = PassthroughSubject<String, Never>()
        
        init(
            debounceTime: TimeInterval
        ) {
            self.debounceTime = debounceTime
            addObservers()
        }
        
        private func addObservers() {
            $text
                .debounce(for: .seconds(debounceTime), scheduler: RunLoop.main)
                .sink { [weak self] text in
                    self?.saveRequest.send(text)
                }
                .store(in: &cancellables)
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    DebounceTextField("", text: $text) { text in
        print("Save: \(text)")
    }
    .padding()
    .background(.ultraThinMaterial)
    
}
