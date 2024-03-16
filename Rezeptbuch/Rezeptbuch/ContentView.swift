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

    var body: some View {
        TabView {
            RecipeListView(modelView: modelView)
                .tabItem {
                    Label("Rezepte", systemImage: "list.bullet")
                }

            RecipeCreationView(modelView: modelView)
                .tabItem {
                    Label("Rezept erstellen", systemImage: "plus.circle")
                }
        }
        .onChange(of: recipesChanged) { _ in
            // Force update the view when recipes change
        }
        .onReceive(modelView.$recepis) { _ in
            print ("View2",modelView.recepis)
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



