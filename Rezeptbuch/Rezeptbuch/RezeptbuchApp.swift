//
//  RezeptbuchApp.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 07.03.24.
//
import SwiftUI

@main
struct RezeptbuchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var modelView: ViewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(modelView: modelView)
        }
    }
}
