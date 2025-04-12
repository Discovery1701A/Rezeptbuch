//
//  ContentView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 07.03.24.
//

import CoreData
import SwiftUI

/// Die `ContentView` stellt die Hauptansicht der App dar und verwaltet die Tab-Navigation.
struct ContentView: View {
    @ObservedObject var modelView: ViewModel // ViewModel zur Verwaltung der Daten
    @State private var selectedTab = 0 // Aktuell ausgewähltes Tab-Element
    @State private var selectedRecipe: UUID? = nil // Speichert die UUID des geöffneten Rezepts
    @State private var importedRecipe: Recipe? = nil // Temporär importiertes Rezept
    @State private var showDuplicateAlert = false
    @State private var pendingRecipe: Recipe? = nil

    var body: some View {
        // Tab-Ansicht für die Navigation zwischen den Hauptbereichen
        TabView(selection: $selectedTab) {
            // Rezeptliste-Ansicht
            RecipeListView(modelView: modelView, selectedTab: $selectedTab, UUIDOfSelectedRecipe: $selectedRecipe)
                .tabItem {
                    Label("Rezepte", systemImage: "list.bullet") // Tab-Icon und -Titel
                }
                .tag(0) // Identifikator für das Tab

            // Rezept-Erstellen-Ansicht
            RecipeCreationView(modelView: modelView, selectedTab: $selectedTab, selectedRecipe: $selectedRecipe, onSave: {})
                .tabItem {
                    Label("Rezept erstellen", systemImage: "plus.circle") // Tab-Icon und -Titel
                }
                .tag(1) // Identifikator für das Tab
        }
        // Modal-Fenster für importierte Rezepte
        .sheet(item: $importedRecipe) { recipe in
            RecipePreviewView(recipe: recipe, onSave: {
                
                if CoreDataManager.shared.recipeExists(id: recipe.id) {
                    pendingRecipe = recipe
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showDuplicateAlert = true
                    }
                    print("bfnbjfdnkbjfdnbjkfdnkbnfbjfd")
                } else {
                    print("jnknknjknnkjnkjn")
                    CoreDataManager.shared.saveRecipe(recipe)
                    modelView.updateAll()
                    selectedRecipe = recipe.id
                }
                importedRecipe = nil
            }, onCancel: {
                deleteImage(id: "\(recipe.id)_import")
                importedRecipe = nil
            })
        }
        .alert(isPresented: $showDuplicateAlert) {
            Alert(
                title: Text("Rezept bereits vorhanden"),
                message: Text("Es existiert bereits ein Rezept mit dieser ID. Möchtest du es überschreiben oder als neues speichern?"),
                primaryButton: .destructive(Text("Überschreiben")) {
                    if let recipe = pendingRecipe {
                        CoreDataManager.shared.saveRecipe(recipe, overwrite: true)
                        modelView.updateAll()
                        selectedRecipe = recipe.id
                        deleteImage(id: "\(recipe.id)_import")
                    }
                },
                secondaryButton: .default(Text("Als neues speichern")) {
                    if let recipe = pendingRecipe {
                        let savedRecipe = CoreDataManager.shared.saveRecipe(recipe, overwrite: false)
                           modelView.updateAll()
                           selectedRecipe = savedRecipe.id
                           deleteImage(id: "\(recipe.id)_import")
                        print(modelView.recipes.count)
                       }
                }
            )
        }
        // Behandelt das Öffnen von Rezept-Dateien über eine externe URL
        .onOpenURL { url in
            print("📂 Datei-Öffnen-Event über onOpenURL erhalten: \(url)")
            openRecipeFile(at: url)
        }
        // Reagiert auf eine Benachrichtigung, wenn ein Rezept geöffnet wird
        .onReceive(NotificationCenter.default.publisher(for: .recipeOpened)) { notification in
            if let recipe = notification.object as? Recipe {
                importedRecipe = recipe
                print("📂 Rezept über Notification erhalten: \(recipe.title)")
            }
        }
    }

    /// Verarbeitet eine Rezept-Datei, die über eine externe Quelle geöffnet wurde.
    /// - Parameter url: Die URL der Datei
    private func openRecipeFile(at url: URL) {
        print("📂 Datei wird verarbeitet: \(url)")

        // Versucht Zugriff auf die Datei zu erhalten (Security-Scoped Resource für Sandbox-Zugriff)
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() } // Zugriff nach der Verarbeitung beenden

            do {
                let fileManager = FileManager.default
                let tempDirectory = FileManager.default.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)

                // Falls die Datei bereits existiert, wird sie zuerst gelöscht
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                // Kopiert die Datei ins temporäre Verzeichnis
                try fileManager.copyItem(at: url, to: destinationURL)
                print("✅ Datei erfolgreich nach: \(destinationURL) kopiert")

                // Datei als `Data` einlesen
                let data = try Data(contentsOf: destinationURL)
                print("📂 Dateigröße: \(data.count) Bytes")

                // Versucht, das Rezept aus der Datei zu deserialisieren
                if let recipe = deserializePlistToRecipe(plistData: data) {
                    print("🎉 Rezept erfolgreich geladen: \(recipe.title)")

                    // Rezept wird temporär im Modal-Fenster geöffnet
                    DispatchQueue.main.async {
                        importedRecipe = recipe
                        print(importedRecipe?.ingredients.count)
                    }
                } else {
                    print("❌ Fehler: Konnte Rezept nicht deserialisieren.")
                }
            } catch {
                print("❌ Fehler beim Kopieren oder Öffnen der Datei: \(error)")
            }
        } else {
            print("❌ Fehler: Kein Zugriff auf die Datei möglich (Security-Scoped Resource)")
        }
    }
}
