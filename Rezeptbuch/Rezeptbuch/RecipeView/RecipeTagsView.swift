//
//  RecipeTagsView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 27.04.25.
//

import SwiftUI
/// Stellt die Tags eines Rezepts in einer horizontalen Scroll-Ansicht dar.
/// Jeder Tag wird als hervorgehobener Text dargestellt.
struct RecipeTagsView: View {
    var tags: [TagStruct] // Liste der Tags, die angezeigt werden sollen

    var body: some View {
        // Horizontal scrollbare Ansicht
        ScrollView(.horizontal) {
            HStack {
                // Iteriert über alle Tags
                ForEach(tags, id: \.self) { tag in
                    Text(tag.name)
                        .font(.headline)    // Hebt die Tags leicht hervor
                        .padding()          // Sorgt für Abstand um den Text
                }
            }
        }
    }
}
