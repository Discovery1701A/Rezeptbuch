//
//  CardView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import SwiftUI
/// Eine wiederverwendbare Card-Ansicht, um Inhalte in einem stilisierten Rahmen darzustellen.
struct CardView<Content: View>: View {
    let content: Content

    /// Initialisiert die CardView mit einem SwiftUI-View als Inhalt.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content  // Der übergebene Inhalt wird hier angezeigt.
        }
        .padding()  // Abstand innerhalb der Card
        .frame(maxWidth: .infinity)  // Die Karte füllt den verfügbaren Platz aus
        .background(Color(.systemGray6))  // Hintergrundfarbe für bessere Sichtbarkeit
        .cornerRadius(12)  // Abgerundete Ecken für ein modernes Design
        .shadow(radius: 3)  // Leichter Schatten für Tiefeneffekt
        .padding(.horizontal)  // Abstand an den Seiten für bessere Optik
    }
}
