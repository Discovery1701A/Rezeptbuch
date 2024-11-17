//
//  Persistence.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 07.03.24.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Preview Setup für SwiftUI Previews
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            setupPreloadedDatabase()  // Hier wird die vorgefertigte Datenbank verwendet
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Funktion zum Laden der vorgefertigten Datenbank aus dem Bundle
    private func setupPreloadedDatabase() {
        let fileManager = FileManager.default
        let containerURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbURL = containerURL.appendingPathComponent("Rezeptbuch.sqlite")
        
        // Prüfen, ob die Datenbank bereits im Zielverzeichnis existiert
        if fileManager.fileExists(atPath: dbURL.path) {
            return  // Datenbank existiert bereits, keine Aktion erforderlich
        }

        // Pfad zur vorgefertigten SQLite-Datei im Bundle
        if let preloadedDBURL = Bundle.main.url(forResource: "Rezeptbuch", withExtension: "sqlite") {
            do {
                // Kopiere die .sqlite-Datei ins Zielverzeichnis
                try fileManager.copyItem(at: preloadedDBURL, to: dbURL)
                print("Vorgefertigte SQLite-Datenbank erfolgreich kopiert.")
            } catch {
                print("Fehler beim Kopieren der SQLite-Datenbank: \(error)")
            }
        } else {
            print("SQLite-Datei im Bundle nicht gefunden.")
        }
    }
}
