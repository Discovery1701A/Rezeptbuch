//
//  InfoView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import SwiftUI

/// Zeigt eine Info-Box an, wenn ein Info-Text vorhanden ist.
struct InfoView: View {
    var info: String?  // Optionaler Info-Text

    var body: some View {
        // Nur anzeigen, wenn `info` vorhanden und nicht nur Leerzeichen ist
        if let info = info, !info.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                // Label mit Icon und Text
                Label {
                    Text(info) // Der eigentliche Info-Text
                } icon: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray) // Graues Icon
                }
                .font(.body) // Standard-Textgröße

            }
            .padding() // Innenabstand
            .frame(maxWidth: .infinity, alignment: .leading) // Ganze Breite nutzen, linksbündig
            .background(Color.white) // Weißer Hintergrund
            .cornerRadius(12) // Abgerundete Ecken
            .overlay(
                // Grauer Rand
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .shadow(
                color: Color(.black).opacity(0.05), // Sehr dezenter Schatten
                radius: 3,
                x: 0,
                y: 1
            )
            .padding(.horizontal, 16) // Äußerer Abstand links und rechts
            .padding(.vertical, 4)    // Äußerer Abstand oben und unten
        }
    }
}
