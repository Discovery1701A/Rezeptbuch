//
//  textFieldArlert.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.04.24.
//

import SwiftUI

// SwiftUI-kompatibler Wrapper für ein UIAlertController mit Textfeld.
// Damit kannst du einen klassischen iOS-Alert mit Eingabe in einer SwiftUI-View verwenden.
struct TextFieldAlert: UIViewControllerRepresentable {
    
    // Titel und Nachricht für den Alert
    var title: String
    var message: String?

    // Bindung zum Textfeldwert (Rückgabe)
    @Binding var text: String

    // Steuert, ob der Alert angezeigt wird
    var isPresented: Binding<Bool>

    // Erstellt einen leeren UIViewController, auf dem später der Alert präsentiert wird
    func makeUIViewController(context: Context) -> some UIViewController {
        return UIViewController()
    }

    // Wird aufgerufen, wenn sich der Zustand ändert (z. B. `isPresented`)
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Prüfe, ob bereits ein Alert angezeigt wird (nur einer gleichzeitig)
        guard context.coordinator.alert == nil else { return }

        // Wenn der Alert angezeigt werden soll
        if self.isPresented.wrappedValue {
            // Erstelle UIAlertController mit Titel und Nachricht
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            context.coordinator.alert = alert // Merke dir den Alert, um doppelte Anzeige zu vermeiden

            // Füge ein Textfeld hinzu und initialisiere es mit dem gebundenen Text
            alert.addTextField { textField in
                textField.text = self.text
            }

            // Cancel-Button: schließt den Alert ohne Änderungen
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.isPresented.wrappedValue = false
                context.coordinator.alert = nil
            })

            // Submit-Button: übernimmt den eingegebenen Text und schließt den Alert
            alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
                if let textField = alert.textFields?.first, let text = textField.text {
                    self.text = text
                }
                self.isPresented.wrappedValue = false
                context.coordinator.alert = nil
            })

            // Zeige den Alert auf dem ViewController an (nachdem er vollständig geladen ist)
            DispatchQueue.main.async {
                uiViewController.present(alert, animated: true, completion: {
                    // (Optionales Sicherheitsnetz – kann auch entfernt werden)
                    self.isPresented.wrappedValue = false
                    context.coordinator.alert = nil
                })
            }
        }
    }

    // Erstellt den Coordinator (verwaltet UIAlertController-Referenz)
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator verwaltet die Lebensdauer des AlertControllers
    class Coordinator: NSObject {
        var alert: UIAlertController?
        var control: TextFieldAlert

        init(_ control: TextFieldAlert) {
            self.control = control
        }
    }
}
