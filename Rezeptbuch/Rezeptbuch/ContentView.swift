//
//  ContentView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 07.03.24.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @ObservedObject var modelView: ViewModel
    @State private var selectedTab = 0
    @State private var selectedRecipe: UUID? = nil // Rezept, das nach dem Öffnen angezeigt wird
    @State private var importedRecipe: Recipe? = nil // Temporär geöffnetes Rezept

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeListView(modelView: modelView, selectedTab: $selectedTab, UUIDOfSelectedRecipe: $selectedRecipe)
                .tabItem {
                    Label("Rezepte", systemImage: "list.bullet")
                }
                .tag(0)

            RecipeCreationView(modelView: modelView, selectedTab: $selectedTab, selectedRecipe: $selectedRecipe, onSave: {})
                .tabItem {
                    Label("Rezept erstellen", systemImage: "plus.circle")
                }
                .tag(1)
        }
        .sheet(item: $importedRecipe) { recipe in
            RecipePreviewView(recipe: recipe, onSave: {
                CoreDataManager().saveRecipe(recipe)
                modelView.updateRecipe()
                modelView.updateFood()
                modelView.updateBooks()
                modelView.updateTags()
            }, onCancel:
            { deleteImage(id: recipe.id) }) // Zeigt das importierte Rezept in einem Modal-Fenster an
        }
        .onOpenURL { url in
            print("📂 Datei-Öffnen-Event über onOpenURL erhalten: \(url)")
            openRecipeFile(at: url)
        }
        .onReceive(NotificationCenter.default.publisher(for: .recipeOpened)) { notification in
            if let recipe = notification.object as? Recipe {
                importedRecipe = recipe
                print("📂 Rezept über Notification erhalten: \(recipe.title)")
            }
        }
    }

    private func openRecipeFile(at url: URL) {
        print("📂 Datei wird verarbeitet: \(url)")

        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let fileManager = FileManager.default
                let tempDirectory = FileManager.default.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)

                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                try fileManager.copyItem(at: url, to: destinationURL)
                print("✅ Datei erfolgreich nach: \(destinationURL) kopiert")

                let data = try Data(contentsOf: destinationURL)
                print("📂 Dateigröße: \(data.count) Bytes")

                if let recipe = deserializePlistToRecipe(plistData: data) {
                    print("🎉 Rezept erfolgreich geladen: \(recipe.title)")

                    // 📌 Rezept NUR temporär speichern
                    DispatchQueue.main.async {
                        importedRecipe = recipe // Öffnet das Rezept in einem Modal
                        print(recipe)
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
