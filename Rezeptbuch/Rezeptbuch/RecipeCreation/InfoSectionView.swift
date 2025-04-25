//
//  InfoSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 25.04.25.
//


import SwiftUI
// Diese View stellt einen Abschnitt zur Eingabe allgemeiner Zusatzinformationen zum Rezept dar.
struct InfoSectionView: View {
    // Binding zur externen Variable, die den Infotext speichert
    @Binding var info: String

    var body: some View {
        // Formular-Section mit Überschrift „Info“
        Section(header: Text("Info")) {
            // Einfaches einzeiliges Textfeld zur Eingabe von Informationen
            TextField("Infos zum Rezept", text: $info)
                .textFieldStyle(RoundedBorderTextFieldStyle())  // Visueller Stil mit abgerundeten Ecken
                .autocapitalization(.none)                      // Keine automatische Großschreibung
        }
    }
}
