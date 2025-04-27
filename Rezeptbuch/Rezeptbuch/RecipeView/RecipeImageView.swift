//
//  RecipeImageView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import SwiftUI


/// Zeigt das Bild eines Rezepts an, entweder aus dem Dateisystem oder als Asset.
struct RecipeImageView: View {
    var imagePath: String?  // Der Pfad zum gespeicherten Bild

    var body: some View {
        if let fileName = imagePath {  // fileName ist die Rezept-ID oder der Bildname
            let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let fileURL = applicationSupport.appendingPathComponent(fileName)  // Bildpfad zusammenstellen

            if FileManager.default.fileExists(atPath: fileURL.path),  // Prüfen, ob das Bild existiert
               let uiImage = UIImage(contentsOfFile: fileURL.path) {  // Bild laden
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .onAppear {
                        print("✅ Bild geladen: \(fileURL.path)")
                    }
            } else {
                if let imageName = imagePath {  // Falls kein Bild im Dateisystem existiert, versuche ein Asset zu laden
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                } else {  // Falls kein Bild verfügbar ist, zeige eine Fehlermeldung an
                    Text("Bild nicht gefunden!")
                        .foregroundColor(.red)
                        .padding()
                        .onAppear {
                            print("❌ Bild nicht gefunden: \(fileURL.path)")
                        }
                }
            }
        } else {
            Text("Bild nicht verfügbar")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

