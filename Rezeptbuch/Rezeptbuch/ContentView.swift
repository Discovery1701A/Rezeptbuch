//
//  ContentView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 07.03.24.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @ObservedObject var modelView: ViewModel
    @State private var recipesChanged = false
    @State private var selectedTab = 0
    @State private var selectedRecipe: UUID? = nil  // Rezept, das nach dem Speichern geöffnet werden soll


    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeListView(modelView: modelView, selectedTab: $selectedTab,UUIDOfSelectedRecipe: $selectedRecipe)
                .tabItem {
                    Label("Rezepte", systemImage: "list.bullet")
                }
                .tag(0)

            RecipeCreationView(modelView: modelView, selectedTab: $selectedTab, selectedRecipe: $selectedRecipe, onSave: {})
                .tabItem {
                    Label("Rezept erstellen", systemImage: "plus.circle")
                }
                .tag(1)
        
//            FoodCreationView(modelView: modelView)
//                .tabItem {
//                    Label("Lebensmittel erstellen", systemImage: "plus.circle")
//                }
        }
        .onChange(of: recipesChanged) { _ in
            // Force update the view when recipes change
        }
        .onReceive(modelView.$recipes) { _ in
//              print ("View2",modelView.recipes)
            recipesChanged.toggle()
        }
    }
}



    struct ContenteView_Previews: PreviewProvider {
        
        static var previews: some View {
            let modelView : ViewModel = ViewModel()
            ContentView(modelView: modelView)
        }
    }



