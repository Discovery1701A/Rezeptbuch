//
//  ReminderListSelectionView.swift
//  Rezeptbuch
// https://medium.com/@rohit.jankar/using-swift-a-guide-to-adding-reminders-in-the-ios-reminder-app-with-the-eventkit-api-020b2e6b38bb
//  Created by Anna Rieckmann on 09.03.25.
//

import SwiftUICore
import EventKit
import SwiftUI

/// Eine Ansicht zur Auswahl einer Erinnerungs-Liste oder zum Erstellen einer neuen Liste in der Erinnerungen-App.
struct ReminderListSelectionView: View {
  
    @Binding var availableLists: [EKCalendar]  // Verfügbare Listen als Binding, damit Änderungen übernommen werden
    @Binding var selectedList: EKCalendar?  // Die aktuell ausgewählte Liste
    @Binding var newListName: String  // Name für eine neu zu erstellende Liste
    let eventStore: EKEventStore  // Der EventStore für den Zugriff auf Erinnerungen
    var onConfirm: () -> Void  // Callback-Funktion für die Bestätigung
    var fetchReminderLists: () -> Void  // Funktion zum erneuten Laden der Erinnerungslisten
    
    @Environment(\.presentationMode) var presentationMode  // Steuerung der Darstellung
    @State private var showOpenRemindersAlert = false  // Status für das Anzeigen eines Alerts

    var body: some View {
        NavigationView {
            VStack {
                Text("Einkaufsliste auswählen")
                    .font(.headline)
                    .padding()

                // Picker zur Auswahl einer bestehenden Erinnerungsliste
                Picker("Liste auswählen", selection: $selectedList) {
                    ForEach(availableLists, id: \.self) { list in
                        Text(list.title).tag(list as EKCalendar?)
                    }
                }
                .pickerStyle(WheelPickerStyle())

                // Eingabefeld zum Erstellen einer neuen Liste
                TextField("Neue Liste erstellen", text: $newListName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Button zum Erstellen einer neuen Liste
                Button("Neue Liste hinzufügen") {
                    createNewReminderList()
                }
                .padding()
                .disabled(newListName.isEmpty)  // Deaktiviert den Button, wenn das Feld leer ist

                Spacer()

                // Button zum Bestätigen der Auswahl
                Button("Bestätigen") {
                    showOpenRemindersAlert = true  // Zeigt den Alert an
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
           
            .padding()
            .alert(isPresented: $showOpenRemindersAlert) {
                Alert(
                    title: Text("Erinnerungen öffnen?"),
                    message: Text("Möchtest du die Erinnerungen-App jetzt öffnen?"),
                    primaryButton: .default(Text("Ja")) {
                        openRemindersApp()
                        presentationMode.wrappedValue.dismiss()  // Schließt die Ansicht
                        onConfirm()  // Ruft die Bestätigung auf
                    },
                    secondaryButton: .cancel {
                        presentationMode.wrappedValue.dismiss()
                        onConfirm()
                    }
                )
            }
        }
    }
    
    /// Erstellt eine neue Erinnerungs-Liste im Event Store.
    func createNewReminderList() {
        let newList = EKCalendar(for: .reminder, eventStore: eventStore)
        newList.title = newListName  // Setzt den Titel der neuen Liste
        
        // Wählt die Quelle für die Liste (Cloud oder lokal)
        if let defaultSource = eventStore.sources.first(where: { $0.sourceType == .calDAV }) {
            newList.source = defaultSource
        } else if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newList.source = localSource
        } else {
            print("⚠️ Keine gültige Quelle für den neuen Kalender gefunden!")
            return
        }
        
        do {
            try eventStore.saveCalendar(newList, commit: true)
            DispatchQueue.main.async {
                self.selectedList = newList
                self.fetchReminderLists()  // Aktualisiert die Liste der Erinnerungen
            }
            print("✅ Neue Liste erstellt: \(newListName)")
        } catch {
            print("❌ Fehler beim Erstellen der Liste: \(error.localizedDescription)")
        }
    }

    /// Öffnet die Erinnerungen-App mit der ausgewählten Liste.
    func openRemindersApp() {
        guard let selectedList = selectedList else {
            print("⚠️ Keine Liste ausgewählt!")
            return
        }

        // Versucht, die spezifische Liste direkt zu öffnen
        let calendarID = selectedList.calendarIdentifier
        let remindersURL = "x-apple-reminderkit://list/\(calendarID)"
        
        if let url = URL(string: remindersURL) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("✅ Erinnerungen-App mit Liste \(selectedList.title) geöffnet")
                } else {
                    print("⚠️ Konnte spezifische Liste nicht öffnen, versuche allgemeine Erinnerungen-App")
                    openRemindersFallback()
                }
            }
        } else {
            print("⚠️ Ungültige URL für Erinnerungen-Liste, öffne stattdessen Erinnerungen-App")
            openRemindersFallback()
        }
    }

    /// Falls die spezifische Liste nicht geöffnet werden kann, öffnet einfach die Erinnerungen-App.
    func openRemindersFallback() {
        if let url = URL(string: "x-apple-reminderkit://") {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    print("❌ Konnte Erinnerungen-App nicht öffnen!")
                }
            }
        }
    }
}
