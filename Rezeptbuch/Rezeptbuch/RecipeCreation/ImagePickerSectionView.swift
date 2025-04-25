//
//  ImagePickerSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 25.04.25.
//

import AVFoundation
import SwiftUI
// Diese View stellt eine Sektion zur Auswahl eines Rezeptbildes bereit.
// Unterstützt Kamera, Fotogalerie und Drag & Drop.

struct ImagePickerSectionView: View {
    // Bild, das im Rezept gespeichert wird
    @Binding var recipeImage: UIImage?

    // Steuert, ob der Galerie-Picker angezeigt wird
    @Binding var showingImagePicker: Bool

    // Steuert, ob der Kamera-Picker angezeigt wird
    @Binding var showingCameraPicker: Bool

    // Zeigt einen Hinweis, wenn keine Kameraberechtigung vorliegt
    @Binding var showingPermissionAlert: Bool

    // Markierung, ob aktuell ein Drag & Drop über dem Dropbereich stattfindet
    @Binding var isTargeted: Bool

    // Quelle für das Bild: Kamera oder Galerie
    @Binding var sourceType: UIImagePickerController.SourceType

    var body: some View {
        VStack {
            Text("Bild auswählen")
                .font(.headline)
                .padding()

            // Auswahlbereich: Kamera oder Galerie
            HStack {
                // Kamera-Auswahl
                Label("Kamera", systemImage: "camera")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        self.sourceType = .camera
                        closeOtherPicker(except: "camera") // Öffnet Kamera
                        checkCameraPermissions() // Prüft Berechtigung
                    }
                    // Zeigt Hinweis, wenn Berechtigung fehlt
                    .alert(isPresented: $showingPermissionAlert) {
                        Alert(
                            title: Text("Zugriff verweigert"),
                            message: Text("Bitte erlaube den Zugriff auf die Kamera in den Einstellungen deines Geräts."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    // Präsentiert Kamera-Picker
                    .sheet(isPresented: $showingCameraPicker) {
                        ImagePicker(image: $recipeImage, sourceType: .camera)
                    }

                Spacer()

                // Galerie-Auswahl
                Label("Galerie", systemImage: "photo.on.rectangle")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        self.sourceType = .photoLibrary
                        closeOtherPicker(except: "gallery") // Öffnet Galerie
                    }
                    // Präsentiert Galerie-Picker
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: $recipeImage, sourceType: self.sourceType)
                    }
            }
            .padding()

            // Unterstützt Drag & Drop eines Bildes aus anderen Quellen (z. B. Finder)
            .onDrop(of: ["public.image"], isTargeted: $isTargeted) { providers, _ in
                providers.first?.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self.recipeImage = image
                        }
                    }
                }
                return true
            }

            // Vorschau des gewählten Bildes oder Platzhaltertext
            if let image = recipeImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            } else {
                Text("Kein Bild ausgewählt")
            }
        }
    }

    // Wird nach Auswahl aus der Galerie aufgerufen – aktuell leer,
    // kann genutzt werden für z. B. Bildkomprimierung oder Analyse
    private func loadImage() {
        guard let inputImage = recipeImage else { return }
        // Weitere Bildverarbeitung bei Bedarf
    }

    // Stellt sicher, dass immer nur ein Picker gleichzeitig aktiv ist
    private func closeOtherPicker(except picker: String) {
        switch picker {
        case "camera":
            showingImagePicker = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingCameraPicker = true
            }
        case "gallery":
            showingCameraPicker = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingImagePicker = true
            }
        default:
            break
        }
    }

    // Prüft, ob Kamera-Zugriff erlaubt ist und fordert ggf. Erlaubnis an
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCameraPicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? (showingCameraPicker = true) : (showingPermissionAlert = true)
                }
            }
        case .denied, .restricted:
            showingPermissionAlert = true
        @unknown default:
            break
        }
    }
}
