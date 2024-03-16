//
//  MacOs.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 16.03.24.
//

import SwiftUI
#if os(macOS)
enum EditMode {
    case inactive
    case active
}

struct EditModeButton: View {
    @Binding var editMode: EditMode

    var body: some View {
        Button(action: {
            self.toggleEditMode()
        }) {
            Text(editMode == .active ? "Fertig" : "Bearbeiten")
        }
    }

    private func toggleEditMode() {
        if editMode == .active {
            editMode = .inactive
        } else {
            editMode = .active
        }
    }
}

#endif
