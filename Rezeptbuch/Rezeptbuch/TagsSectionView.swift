//
//  TagsSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 08.12.24.
//


import SwiftUI

struct TagsSectionView: View {
    @State private var tagSearchText: String = ""
    @Binding var allTags: [TagStruct]
    @Binding var selectedTags: Set<UUID>
    
    @State private var filteredTags: [TagStruct] = []
    @State private var showingAddTagField = false
    @State private var newTagName = ""

    var body: some View {
        Section(header: Text("Tags")) {
            TextField("Tag suchen...", text: $tagSearchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: tagSearchText) { newValue in
                    if newValue.isEmpty {
                        filteredTags = allTags
                    } else {
                        filteredTags = allTags.filter { $0.name.lowercased().contains(newValue.lowercased()) }
                    }
                }
                .onAppear {
                    filteredTags = allTags // Initialfüllung beim Erscheinen der Ansicht
                }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filteredTags, id: \.id) { tag in
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
                showingAddTagField = true
            }
        }
        .sheet(isPresented: $showingAddTagField) {
            VStack {
                TextField("Neuen Tag eingeben", text: $newTagName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Tag hinzufügen") {
                    let newTag = TagStruct(name: newTagName, id: UUID())
                    allTags.append(newTag)
                    selectedTags.insert(newTag.id)
                    newTagName = ""
                    filteredTags = allTags
                    showingAddTagField = false
                }
                .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }
}

