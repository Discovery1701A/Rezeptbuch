//
//  RezeptbuchApp.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 07.03.24.
//

import SwiftUI

@main
struct RezeptbuchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
