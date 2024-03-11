//
//  Buttons.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 11.03.24.
//

import SwiftUI

struct Buttons{
    
    @ViewBuilder
    func cookMode() -> some View {
        Button(
            action: {
                print("Kochmodus")
            },
            label: {
                Text("Koch Modus")
            }
        )
       
    }
}

