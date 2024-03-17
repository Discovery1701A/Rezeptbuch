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
                    Divider().padding(.horizontal, 16)
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
                        Divider().padding(.horizontal, 16)
                        
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                           
                               
                              
                            Text("\(ingredient.quantity)" + ingredient.unit.rawValue + " " + ingredient.food.name)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 10)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(minHeight: 30)
                                        .frame(width : geometry.size.width*0.6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                
                                .padding(.vertical, 5)
                            Divider().padding(.horizontal, 16)
                        }
                    }
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text("Anleitung:")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Divider().padding(.horizontal, 16)
                        
                        ForEach(recipe.instructions, id: \.self) { instruction in
                            
                            Text("\(instruction)")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                                .padding(.vertical,10)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width : geometry.size.width*0.9)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1))
                            
                                
                                    
                            
                                .padding(.vertical, 5)
                            Divider().padding(.horizontal, 16)
                        }
                    }
//                    Buttons.cookMode(<#T##self: Buttons##Buttons#>)
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
