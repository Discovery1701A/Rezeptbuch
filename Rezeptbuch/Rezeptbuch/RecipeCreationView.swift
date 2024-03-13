//
//  RecipeCreationView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 13.03.24.
//

import SwiftUI

struct RecipeCreationView: View {
    @State private var recipeTitle = ""
    @State private var ingredients: [String] = []
    @State private var instructions: [String] = []
    
    var body: some View {
#if os(macOS)
        NavigationView {
            content
                .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
        }
#else
        content
#endif
    }
    
    var content: some View {
        Form {
            Section(header: Text("Allgemeine Informationen")) {
                TextField("Rezept-Titel", text: $recipeTitle)
            }
            
            Section(header: Text("Zutaten")) {
                ForEach(0..<ingredients.count, id: \.self) { index in
                    TextField("Zutat \(index + 1)", text: $ingredients[index])
                }
                Button(action: {
                    ingredients.append("")
                }) {
                    Label("Zutat hinzufügen", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("Anleitung")) {
                ForEach(0..<instructions.count, id: \.self) { index in
                    TextField("Schritt \(index + 1)", text: $instructions[index]) // Hier wurde Text durch TextField ersetzt
                }
                Button(action: {
                    instructions.append("")
                }) {
                    Label("Schritt hinzufügen", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("Rezept erstellen")
    }
}


struct RecipeCreationView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCreationView()
    }
}
