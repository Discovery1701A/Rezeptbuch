//
//  YouTubeSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 25.04.25.
//

import SwiftUI
// Diese View stellt eine Formular-Sektion dar, in der der Benutzer optional einen YouTube-Link zum Rezept eingeben kann.
struct YouTubeSectionView: View {
    // Binding zur übergeordneten Variable für den YouTube-Link
    @Binding var videoLink: String

    var body: some View {
        // Neue Formular-Sektion mit Überschrift
        Section(header: Text("YouTube_Link")) {
            // Einzeiliges Texteingabefeld für den YouTube-Link
            TextField("Geben Sie den YouTube-Link ein", text: $videoLink)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Abgerundeter Rahmen für bessere Optik
                .autocapitalization(.none) // Verhindert automatische Großschreibung
                .disableAutocorrection(true) // Kein Autokorrekturvorschlag (wichtig für URLs)
        }
    }
}
