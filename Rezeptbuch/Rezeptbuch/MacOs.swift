//
//  MacOs.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 16.03.24.
//

import SwiftUI
#if os(macOS)
import AppKit
import Cocoa
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

struct ImagePicker: NSViewRepresentable {
    @Binding var image: NSImage?
    @Environment(\.presentationMode) var presentationMode

    func makeNSView(context: Context) -> NSView {
        NSView(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func openPanel() {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.allowedFileTypes = ["png", "jpg", "jpeg"]
            panel.begin { response in
                if response == .OK, let url = panel.url, let image = NSImage(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.parent.image = image
                        self.parent.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}



extension NSImage {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
}


extension Image {
    static func loadImageFromPath(_ path: String) -> Image? {
        if let img = NSImage(contentsOfFile: path) {
            return Image(nsImage: img)
        }
        return nil
    }
}
#endif
