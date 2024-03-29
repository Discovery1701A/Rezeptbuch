//
//  RezeptListView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import SwiftUI


struct RecipeListView: View {
//    var recipes: [Recipe]
    @ObservedObject var modelView : ViewModel

    var body: some View {
       
            #if os(iOS)
        NavigationView {
            List {
                Text(String(modelView.recepis.count))
                ForEach(modelView.recepis, id: \.id) { recipe in
                    NavigationLink(destination: RecipeView(recipe: recipe)) {
                        HStack {
                            Text(recipe.title)
                            if let imageName = recipe.image {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .padding(.top, 10)
                                    .frame(maxWidth: .infinity, maxHeight: 200)
                            }
                        }
                    }
                }
            }
            
            .navigationBarTitle("Alle Rezepte")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
      
            #elseif os(macOS)
            NavigationView {
                VStack {
                    // Text view for navigation title on macOS
                    Text("Alle Rezepte")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.controlBackgroundColor))
                    
                    List(modelView.recepis, id: \.id) { recipe in
                        NavigationLink(destination: RecipeView(recipe: recipe)) {
                            Text(recipe.title)
                        }
                    }
                    .frame(minWidth: 200, idealWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            #endif
            
        }
        
       
       
    
}

// ... rest of the code remains unchanged

//// Beispiel für die Verwendung
//struct contentListView: View {
//    var recipes: [Recipe]
//
//    var body: some View {
//        RecipeListView(recipes: recipes)
//    }
//}
//
//struct ContentListView_Previews: PreviewProvider {
//    static var previews: some View {
//        contentListView(recipes: [brownie, pastaRecipe])
//    }
//}
