//
//  RecipeBookSectionView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 25.04.25.
//


import SwiftUI
// Diese View stellt einen Abschnitt zur Auswahl und Verwaltung von Rezeptbüchern dar.
struct RecipeBookSectionView: View {
    // Auswahl der aktuell zugeordneten Rezeptbuch-IDs
    @Binding var selectedRecipeBookIDs: Set<UUID>

    // Eingabe für neues Rezeptbuch
    @Binding var newRecipeBookName: String

    // Suchtext für Rezeptbuchsuche
    @Binding var recipeBookSearchText: String

    // Gefilterte Liste der anzeigbaren Rezeptbücher
    @Binding var filteredRecipeBooks: [RecipebookStruct]

    // Status, ob das Eingabefeld für ein neues Rezeptbuch angezeigt wird
    @Binding var showingNewRecipeBookDialog: Bool

    // Dummy-ID zur Auslösung einer View-Aktualisierung nach Neuerstellung
    @Binding var newRecipeBookDummyID: UUID

    // Zugriff auf das globale Datenmodell (z. B. alle Rezeptbücher)
    var modelView: ViewModel

    var body: some View {
        // Abschnitts-Container mit Überschrift
        Section(header: Text("Rezeptbücher")) {
            // Wenn noch keine Bücher existieren
            if modelView.recipeBooks.isEmpty {
                Button("Neues Rezeptbuch erstellen") {
                    self.showingNewRecipeBookDialog = true
                }
            } else {
                // Auswahlansicht für vorhandene Bücher
                recipeBookPicker
            }
        }
        // Sheet für das Eingabeformular eines neuen Rezeptbuchs
        .sheet(isPresented: $showingNewRecipeBookDialog) {
            newRecipeBookView
        }
    }

    // Picker-Komponente zur Auswahl von Rezeptbüchern (inkl. Suche und Erstellung)
    private var recipeBookPicker: some View {
        VStack {
            // Textfeld für die Suchfunktion
            TextField("Rezeptbuch suchen...", text: $recipeBookSearchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: recipeBookSearchText) { newValue in
                    if newValue.isEmpty {
                        filteredRecipeBooks = modelView.recipeBooks
                    } else {
                        // Filtert Bücher, deren Name den Suchtext enthält (nicht case-sensitiv)
                        filteredRecipeBooks = modelView.recipeBooks.filter {
                            $0.name.lowercased().contains(newValue.lowercased())
                        }
                    }
                }
                .onAppear {
                    // Setzt anfänglich alle Bücher in die gefilterte Liste
                    filteredRecipeBooks = modelView.recipeBooks
                }

            // Horizontale Scrollansicht der gefilterten Bücher
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filteredRecipeBooks, id: \.id) { book in
                        Text(book.name)
                            .padding()
                            .background(
                                selectedRecipeBookIDs.contains(book.id) ? Color.blue : Color.gray
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .onTapGesture {
                                // Fügt das Buch zur Auswahl hinzu oder entfernt es
                                if selectedRecipeBookIDs.contains(book.id) {
                                    selectedRecipeBookIDs.remove(book.id)
                                } else {
                                    selectedRecipeBookIDs.insert(book.id)
                                }
                            }
                    }
                }
            }

            // Button zum Öffnen des Dialogs für ein neues Buch
            Button("Neues Rezeptbuch hinzufügen") {
                showingNewRecipeBookDialog = true
            }
        }
    }

    // Sheet-Ansicht zur Erstellung eines neuen Rezeptbuchs
    private var newRecipeBookView: some View {
        VStack {
            Text("Neues Rezeptbuch erstellen")
            TextField("Name des Rezeptbuchs", text: $newRecipeBookName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Hinzufügen") {
                addNewRecipeBook()
            }
            // Button nur aktiv, wenn Eingabe nicht leer
            .disabled(newRecipeBookName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }

    // Funktion zur Erstellung eines neuen Buchs und Hinzufügen zu CoreData + Anzeige
    private func addNewRecipeBook() {
        let newBook = RecipebookStruct(name: newRecipeBookName, recipes: [])
        
        // In ViewModel speichern (temporär)
        modelView.recipeBooks.append(newBook)
        
        // Direkt zur Auswahl hinzufügen
        selectedRecipeBookIDs.insert(newBook.id)
        
        // Eingabe zurücksetzen
        newRecipeBookName = ""
        
        // Persistente Speicherung via CoreDataManager
        CoreDataManager.shared.createNewRecipeBook(recipeBookStruct: newBook)
        
        // Liste im Model aktualisieren
        modelView.updateBooks()
        
        // Aktualisierung der Suchergebnisse
        filteredRecipeBooks = modelView.recipeBooks

        // Dialog schließen
        showingNewRecipeBookDialog = false

        // Dummy-ID ändern zur optionalen UI-Aktualisierung
        newRecipeBookDummyID = UUID()
    }
}
