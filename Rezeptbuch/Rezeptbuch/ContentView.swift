//
//  ContentView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 07.03.24.
//

import SwiftUI
import CoreData


    struct ContentView: View {
        var body: some View {
            TabView {
                RecipeListView(recipes: [brownie,pastaRecipe]) // Beispiel für eine vorhandene Ansicht
                    .tabItem {
                        Label("Rezepte", systemImage: "list.bullet")
                    }

                RecipeCreationView() // Hier fügst du die RecipeCreationView ein
                    .tabItem {
                        Label("Rezept erstellen", systemImage: "plus.circle")
                    }
            }
        }
    }

    struct ContenteView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }



