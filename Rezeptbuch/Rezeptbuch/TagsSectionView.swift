//
//  TagsSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 08.12.24.
//

import SwiftUI
/// Eine Ansicht zur Verwaltung und Auswahl von Tags (Suchfunktion + Hinzufügen möglich).
struct TagsSectionView: View {
    // MARK: - Pflicht-Properties
    @Binding var allTags: [TagStruct]        // Alle vorhandenen Tags
    @Binding var selectedTags: Set<UUID>      // Aktuell ausgewählte Tags

    // MARK: - Optionale externe Steuerung
    var tagSearchText: Binding<String>? = nil   // Optional: Textfeld für Suche
    var filteredTags: Binding<[TagStruct]>? = nil // Optional: Gefilterte Tag-Liste
    var showingAddTagField: Binding<Bool>? = nil  // Optional: Sichtbarkeit neues Tag
    var newTagName: Binding<String>? = nil        // Optional: Name des neuen Tags

    // MARK: - Interne Fallbacks, falls keine externen Bindings übergeben werden
    @State private var internalSearchText = ""
    @State private var internalFilteredTags: [TagStruct] = []
    @State private var internalShowAdd = false
    @State private var internalNewTag = ""

    var body: some View {
        // MARK: - Dynamische Auswahl, je nachdem ob externe Bindings vorhanden sind
        let searchText = tagSearchText ?? $internalSearchText
        let filtered = filteredTags ?? $internalFilteredTags
        let showAdd = showingAddTagField ?? $internalShowAdd
        let newTag = newTagName ?? $internalNewTag

        Section(header: Text("Tags")) {
            // MARK: - Tag-Suchfeld
            TextField("Tag suchen...", text: searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText.wrappedValue) { newValue in
                    // Suche aktualisiert die Filterliste
                    if newValue.isEmpty {
                        filtered.wrappedValue = allTags
                    } else {
                        filtered.wrappedValue = allTags.filter {
                            $0.name.lowercased().contains(newValue.lowercased())
                        }
                    }
                }
                .onAppear {
                    // Beim ersten Erscheinen alle Tags anzeigen
                    filtered.wrappedValue = allTags
                }

            // MARK: - Horizontales ScrollView für Tag-Auswahl
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filtered.wrappedValue, id: \.id) { tag in
                        Text(tag.name)
                            .padding()
                            .background(selectedTags.contains(tag.id) ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .onTapGesture {
                                // Tag an- oder abwählen
                                if selectedTags.contains(tag.id) {
                                    selectedTags.remove(tag.id)
                                } else {
                                    selectedTags.insert(tag.id)
                                }
                            }
                    }
                }
            }

            // MARK: - Button "Neuen Tag hinzufügen"
            Button("Neuen Tag hinzufügen") {
                showAdd.wrappedValue = true
            }
        }
        // MARK: - Sheet für neues Tag
        .sheet(isPresented: showAdd) {
            VStack {
                // Eingabefeld für neuen Tag
                TextField("Neuen Tag eingeben", text: newTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Speichern-Button
                Button("Tag hinzufügen") {
                    let tag = TagStruct(name: newTag.wrappedValue, id: UUID())
                    allTags.append(tag)                 // Tag zur Liste hinzufügen
                    selectedTags.insert(tag.id)          // Direkt auswählen
                    newTag.wrappedValue = ""             // Eingabefeld zurücksetzen
                    filtered.wrappedValue = allTags      // Filter zurücksetzen
                    showAdd.wrappedValue = false         // Sheet schließen
                }
                .disabled(newTag.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Button deaktiviert bei leerem Feld
            }
            .padding()
        }
    }
}
