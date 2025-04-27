//
//  FilterSection.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import SwiftUI

/// Eine wiederverwendbare Filter-Ansicht für eine Liste auswählbarer Elemente (z.B. Zutaten, Tags, Rezeptbücher).
/// Unterstützt horizontales Scrollen und Suche innerhalb der Elemente.
struct FilterSection<Item: Hashable & Identifiable & Named>: View {
    var title: String  // Titel der Sektion
    var items: [Item]  // Alle verfügbaren Items
    @Binding var selectedItems: [Item]  // Die aktuell ausgewählten Items
    var clearAction: () -> Void  // Aktion zum Entfernen aller ausgewählten Items

    @State private var filterText = ""  // Textfeld für die lokale Suche

    /// Gefilterte Items basierend auf dem Suchtext
    var filteredItems: [Item] {
        if filterText.isEmpty {
            return items
        } else {
            return items.filter { $0.name.localizedCaseInsensitiveContains(filterText) }
        }
    }

    var body: some View {
        Section(header: HStack {
            Text(title)
            Spacer()
            Button("Alle entfernen", action: clearAction)
                .font(.caption)
                .foregroundColor(.red)
        }) {
            // 🔎 Suchfeld
            HStack {
                TextField("Suche...", text: $filterText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !filterText.isEmpty {
                    Button(action: {
                        filterText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }

            // 📜 Horizontale Liste der (gefilterten) Items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filteredItems, id: \.id) { item in
                        Text(item.name)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedItems.contains(item) ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(selectedItems.contains(item) ? .white : .primary)
                            .clipShape(Capsule())
                            .onTapGesture {
                                toggleSelection(for: item)
                            }
                    }
                }
            }
        }
    }

    /// Fügt ein Item zur Auswahl hinzu oder entfernt es bei erneutem Antippen.
    private func toggleSelection(for item: Item) {
        if let index = selectedItems.firstIndex(of: item) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }
}

/// Ein einfaches Protokoll, das verlangt, dass ein Typ einen `name`-String besitzt.
/// Ermöglicht die einheitliche Behandlung von z.B. Lebensmitteln, Tags oder Rezeptbüchern.
protocol Named {
    var name: String { get }
}

// 🔹 Erweiterungen, damit bestehende Strukturen `Named` erfüllen
extension FoodStruct: Named {}
extension TagStruct: Named {}
extension RecipebookStruct: Named {}
