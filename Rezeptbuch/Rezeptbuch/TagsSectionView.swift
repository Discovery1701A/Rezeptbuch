//
//  TagsSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 08.12.24.
//

import SwiftUI

/// Ansicht zur Verwaltung und Auswahl von Tags in einer horizontal scrollbaren Liste.
struct TagsSectionView: View {
    @State private var tagSearchText: String = ""  // Suchfeld für Tags
    @Binding var allTags: [TagStruct]  // Alle verfügbaren Tags
    @Binding var selectedTags: Set<UUID>  // Die aktuell ausgewählten Tags

    @State private var filteredTags: [TagStruct] = []  // Gefilterte Tags basierend auf der Suche
    @State private var showingAddTagField = false  // Status, ob das Eingabefeld für neue Tags sichtbar ist
    @State private var newTagName = ""  // Name für einen neuen Tag

    var body: some View {
        Section(header: Text("Tags")) {
            // Suchfeld zur Filterung der Tags
            TextField("Tag suchen...", text: $tagSearchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: tagSearchText) { newValue in
                    if newValue.isEmpty {
                        filteredTags = allTags  // Wenn das Suchfeld leer ist, zeige alle Tags an
                    } else {
                        // Filtere Tags nach Name (Groß-/Kleinschreibung wird ignoriert)
                        filteredTags = allTags.filter { $0.name.lowercased().contains(newValue.lowercased()) }
                    }
                }
                .onAppear {
                    filteredTags = allTags  // Füllt die Liste beim Erscheinen der Ansicht
                }

            // Horizontale Liste mit Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filteredTags, id: \.id) { tag in
                        Text(tag.name)
                            .padding()
                            .background(selectedTags.contains(tag.id) ? Color.blue : Color.gray) // Markiert ausgewählte Tags
                            .foregroundColor(.white)
                            .clipShape(Capsule())  // Runde Kapsel-Form für die Tags
                            .onTapGesture {
                                // Fügt einen Tag hinzu oder entfernt ihn aus der Auswahl
                                if selectedTags.contains(tag.id) {
                                    selectedTags.remove(tag.id)
                                } else {
                                    selectedTags.insert(tag.id)
                                }
                            }
                    }
                }
            }

            // Button zum Hinzufügen eines neuen Tags
            Button("Neuen Tag hinzufügen") {
                showingAddTagField = true
            }
        }
        .sheet(isPresented: $showingAddTagField) {
            VStack {
                // Eingabefeld für neuen Tag
                TextField("Neuen Tag eingeben", text: $newTagName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Button zum Speichern des neuen Tags
                Button("Tag hinzufügen") {
                    let newTag = TagStruct(name: newTagName, id: UUID())
                    allTags.append(newTag)  // Fügt den neuen Tag zur Liste hinzu
                    selectedTags.insert(newTag.id)  // Markiert den neuen Tag als ausgewählt
                    newTagName = ""  // Setzt das Eingabefeld zurück
                    filteredTags = allTags  // Aktualisiert die gefilterte Liste
                    showingAddTagField = false  // Schließt das Eingabefeld
                }
                .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)  // Deaktiviert den Button, wenn das Eingabefeld leer ist
            }
            .padding()
        }
    }
}
