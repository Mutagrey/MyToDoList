//
//  SearchableModifier.swift
//  DIetDiary
//
//  Created by Sergey Petrov on 18.01.2024.
//

import Combine
import SwiftUI

struct SearchableModifier: ViewModifier {

    @Binding var searchText: String
    @Binding var isPresentedSearch: Bool
    let prompt: String?
    let displayMode: SearchFieldPlacement.NavigationBarDrawerDisplayMode
    private let searchPublisher = PassthroughSubject<String, Never>()

    func body(content: Content) -> some View {
        content
            .searchable(text: $searchText,
                        isPresented: $isPresentedSearch,
                        placement: .navigationBarDrawer(displayMode: displayMode),
                        prompt: prompt != nil ? Text(prompt ?? "") : nil)
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    searchText = ""
                }
                searchPublisher.send(newValue)
            }
            .onReceive(searchPublisher.debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)) { text in
                searchText = text
            }
    }
}

extension View {
    
    /// Searchable with debounce
    func searchableWithDebounce(text: Binding<String>, isPresentedSearch: Binding<Bool>, prompt: String? = nil, displayMode: SearchFieldPlacement.NavigationBarDrawerDisplayMode = .automatic) -> some View {
        self
            .modifier(SearchableModifier(searchText: text, isPresentedSearch: isPresentedSearch, prompt: prompt, displayMode: displayMode))
    }
}
