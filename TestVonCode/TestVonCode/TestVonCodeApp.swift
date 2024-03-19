//
//  TestVonCodeApp.swift
//  TestVonCode
//
//  Created by Anna Rieckmann on 19.03.24.
//

import SwiftUI

@main
struct TestVonCodeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
