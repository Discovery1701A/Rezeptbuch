//
//  RezeptView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 10.03.24.
//

import SwiftUI

struct RecipeView: View {
    var recipe: Recipe

    var body: some View {
        GeometryReader { geometry in
        ScrollView {
            

                VStack(alignment: .center, spacing: 10) {
                    Text(recipe.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if let imageName = recipe.image {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text("Zutaten:")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                                .frame(minHeight: 30)
                                .overlay(
                                    Text("• \(ingredient)")
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 10)
                                        .fixedSize(horizontal: false, vertical: true)
                                )
                                .padding(.vertical, 5)
                        }
                    }
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text("Anleitung:")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        ForEach(recipe.instructions, id: \.self) { instruction in
                            
                            Text("\(instruction)")
                                .foregroundColor(.green)
                                .padding(.horizontal)
                                .padding(.vertical,10)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width : geometry.size.width*0.9)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 1))
                                    
                                
                                    
                            
                                .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }
    }
}

// Beispiel für die Verwendung
struct contentView: View {
    var body: some View {
        RecipeView(recipe: brownie)
            .padding()
            .frame(maxWidth: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        contentView()
    }
}
