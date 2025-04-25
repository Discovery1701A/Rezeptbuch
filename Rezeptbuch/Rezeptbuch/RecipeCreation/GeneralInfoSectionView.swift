//
//  GeneralInfoSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 25.04.25.
//

import SwiftUI
// Diese View zeigt einen Formularabschnitt für allgemeine Rezeptinformationen an.
struct GeneralInfoSectionView: View {
    // Bindings zu den übergebenen Werten
    @Binding var recipeTitle: String // Titel des Rezepts
    @Binding var isCake: Bool // Ob es sich um einen Kuchen handelt
    @Binding var cakeForm: Formen // Gewählte Kuchenform (enum: rund, eckig, ...)
    @Binding var size: [String] // Maße: [0] = Durchmesser, [1] = Länge, [2] = Breite
    @Binding var portionValue: String // Portionenanzahl (wenn kein Kuchen)

    var body: some View {
        // Section mit Titel
        Section(header: Text("Allgemeine Informationen")) {
            VStack {
                // Eingabefeld für den Rezepttitel
                TextField("Rezept-Titel", text: $recipeTitle)

                // Umschalter für Kuchen ja/nein – mit Animation bei Zustandsänderung
                Toggle("Ist es ein Kuchen?", isOn: $isCake.animation())

                // Falls es ein Kuchen ist, zeige zusätzliche Felder
                if isCake {
                    // Auswahl der Kuchenform (rund, eckig, usw.)
                    Picker("Kuchenform", selection: $cakeForm) {
                        ForEach(Formen.allCases, id: \.self) { form in
                            Text(form.rawValue) // Name der Form anzeigen
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Als Segmente dargestellt

                    // Abhängig von der Kuchenform: andere Maße
                    if cakeForm == .rund {
                        // Rund: Eingabe des Durchmessers
                        HStack {
                            Text("Durchmesser (cm):")
                            TextField("Durchmesser (cm)", text: $size[0])
                                .keyboardType(.decimalPad) // Nur Zahlen
                        }
                    } else {
                        // Eckig: Eingabe von Länge und Breite
                        HStack {
                            Text("Länge (cm):")
                            TextField("Länge (cm)", text: $size[1])
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()

                            Text("Breite (cm):")
                            TextField("Breite (cm)", text: $size[2])
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        }
                    }
                } else {
                    // Kein Kuchen: Eingabe der Portionenanzahl
                    TextField("Portion (Anzahl)", text: $portionValue)
                        .keyboardType(.decimalPad)
                }
            }
        }
    }
}
