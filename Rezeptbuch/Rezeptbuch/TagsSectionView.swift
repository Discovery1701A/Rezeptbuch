//
//  TagsSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 08.12.24.
//

import SwiftUI

struct TagsSectionView: View {
    // Immer notwendig
    @Binding var allTags: [TagStruct]
    @Binding var selectedTags: Set<UUID>
    
    // Optional, wenn du alles extern verwalten willst
    var tagSearchText: Binding<String>? = nil
    var filteredTags: Binding<[TagStruct]>? = nil
    var showingAddTagField: Binding<Bool>? = nil
    var newTagName: Binding<String>? = nil

    // Interne State-Fallbacks
    @State private var internalSearchText = ""
    @State private var internalFilteredTags: [TagStruct] = []
    @State private var internalShowAdd = false
    @State private var internalNewTag = ""

    var body: some View {
        let searchText = tagSearchText ?? $internalSearchText
        let filtered = filteredTags ?? $internalFilteredTags
        let showAdd = showingAddTagField ?? $internalShowAdd
        let newTag = newTagName ?? $internalNewTag

        Section(header: Text("Tags")) {
            TextField("Tag suchen...", text: searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText.wrappedValue) { newValue in
                    if newValue.isEmpty {
                        filtered.wrappedValue = allTags
                    } else {
                        filtered.wrappedValue = allTags.filter {
                            $0.name.lowercased().contains(newValue.lowercased())
                        }
                    }
                }
                .onAppear {
                    filtered.wrappedValue = allTags
                }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filtered.wrappedValue, id: \.id) { tag in
                        Text(tag.name)
                            .padding()
                            .background(selectedTags.contains(tag.id) ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .onTapGesture {
                                if selectedTags.contains(tag.id) {
                                    selectedTags.remove(tag.id)
                                } else {
                                    selectedTags.insert(tag.id)
                                }
                            }
                    }
                }
            }

            Button("Neuen Tag hinzufügen") {
                showAdd.wrappedValue = true
            }
        }
        .sheet(isPresented: showAdd) {
            VStack {
                TextField("Neuen Tag eingeben", text: newTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Tag hinzufügen") {
                    let tag = TagStruct(name: newTag.wrappedValue, id: UUID())
                    allTags.append(tag)
                    selectedTags.insert(tag.id)
                    newTag.wrappedValue = ""
                    filtered.wrappedValue = allTags
                    showAdd.wrappedValue = false
                }
                .disabled(newTag.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }
}
