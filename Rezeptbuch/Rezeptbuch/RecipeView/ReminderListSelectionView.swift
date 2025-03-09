//
//  ReminderListSelectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 09.03.25.
//

import SwiftUICore
import EventKit
import SwiftUI


struct ReminderListSelectionView: View {
  
    @Binding var availableLists: [EKCalendar] // 🔄 Jetzt als Binding, damit die Änderungen im Haupt-View übernommen werden
    @Binding var selectedList: EKCalendar?
    @Binding var newListName: String
    let eventStore : EKEventStore
    var onConfirm: () -> Void
    var fetchReminderLists: () -> Void  // 🔄 Funktion wird übergeben, um die Listen zu aktualisieren
    @Environment(\.presentationMode) var presentationMode
       @State private var showOpenRemindersAlert = false  // 🔄 State für Alert-Steuerung
       
       var body: some View {
           NavigationView {
               VStack {
                   Text("Einkaufsliste auswählen")
                       .font(.headline)
                       .padding()

                   Picker("Liste auswählen", selection: $selectedList) {
                       ForEach(availableLists, id: \.self) { list in
                           Text(list.title).tag(list as EKCalendar?)
                       }
                   }
                   .pickerStyle(WheelPickerStyle())

                   TextField("Neue Liste erstellen", text: $newListName)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding()
                   
                   Button("Neue Liste hinzufügen") {
                       createNewReminderList()
                   }
                   .padding()
                   .disabled(newListName.isEmpty)

                   Spacer()

                   Button("Bestätigen") {
//                       onConfirm()
                       showOpenRemindersAlert = true // 🔄 Nach Bestätigung soll Alert erscheinen
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
                           presentationMode.wrappedValue.dismiss()
                           onConfirm()
                       },
                       secondaryButton: .cancel {
                           presentationMode.wrappedValue.dismiss()
                           onConfirm()
                       }
                   )
               }
           }
       }
       
       func createNewReminderList() {
           let newList = EKCalendar(for: .reminder, eventStore: eventStore)
           newList.title = newListName
           
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
                   self.fetchReminderLists()
               }
               print("✅ Neue Liste erstellt: \(newListName)")
           } catch {
               print("❌ Fehler beim Erstellen der Liste: \(error.localizedDescription)")
           }
       }

    func openRemindersApp() {
        guard let selectedList = selectedList else {
            print("⚠️ Keine Liste ausgewählt!")
            return
        }

        // Versuche, die Liste direkt zu öffnen
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

    /// Falls die spezifische Liste nicht geöffnet werden kann, öffne einfach die Erinnerungen-App
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
