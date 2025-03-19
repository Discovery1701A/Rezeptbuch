//
//  Persistence.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 07.03.24.
//
import CoreData
import CoreData

/// `PersistenceController` verwaltet die Core Data-Persistenz für die Anwendung.
struct PersistenceController {
    /// Singleton-Instanz für die Verwendung in der App.
    static let shared = PersistenceController()

    /// Erstellt eine Vorschauversion der `PersistenceController`, die im Speicher läuft,
    /// um sie in SwiftUI-Previews zu verwenden.
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true) // Instanz im Speicher erstellen
        let viewContext = result.container.viewContext

        // Erzeuge 10 Beispiel-Elemente für die Vorschau
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save() // Speichert die Beispiel-Daten
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    /// `NSPersistentContainer` verwaltet die Core Data-Datenbank und das Modell.
    let container: NSPersistentContainer

    /// Initialisiert den `PersistenceController`.
    /// - Parameter inMemory: Wenn `true`, wird die Datenbank nur im Speicher gehalten
    ///   und nicht dauerhaft gespeichert (z. B. für Previews oder Tests).
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model") // Lade das Core Data-Modell

        if inMemory {
            // Falls die Datenbank nur im Speicher existieren soll, wird sie auf `/dev/null` umgeleitet.
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Falls die App regulär läuft, wird eine vorgefertigte Datenbank geladen, falls vorhanden.
            setupPreloadedDatabase()
        }

        // Lade die Persistent Stores (Datenbanken)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Ermöglicht automatische Synchronisation von Änderungen zwischen mehreren Contexts.
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Kopiert eine vorgefertigte SQLite-Datenbank aus dem App-Bundle ins Anwendungs-Support-Verzeichnis.
    private func setupPreloadedDatabase() {
        let fileManager = FileManager.default
        let containerURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbURL = containerURL.appendingPathComponent("Rezeptbuch.sqlite") // Zielpfad der SQLite-Datenbank

        // Prüfe, ob die Datenbank bereits im Anwendungs-Support-Verzeichnis existiert
        if fileManager.fileExists(atPath: dbURL.path) {
            return  // Falls sie bereits existiert, ist keine Aktion notwendig
        }

        // Suche nach der vorgefertigten Datenbank im App-Bundle
        if let preloadedDBURL = Bundle.main.url(forResource: "Rezeptbuch", withExtension: "sqlite") {
            do {
                // Kopiere die Datenbank aus dem Bundle ins Anwendungs-Support-Verzeichnis
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
