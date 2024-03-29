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
    var modelView : ViewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
//            contentListView(recipes: [brownie, pastaRecipe])
            ContentView(modelView: modelView)
        }
    }
}
