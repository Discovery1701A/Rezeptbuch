//
//  DatenbankeApp.swift
//  Datenbanke
//
//  Created by Anna Rieckmann on 15.11.24.
//

import SwiftUI

@main
struct DatenbankeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
