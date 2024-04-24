//
//  textFieldArlert.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.04.24.
//

import SwiftUI

struct TextFieldAlert: UIViewControllerRepresentable {
    var title: String
    var message: String?
    @Binding var text: String
    var isPresented: Binding<Bool>

    func makeUIViewController(context: Context) -> some UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard context.coordinator.alert == nil else { return }
        if self.isPresented.wrappedValue {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            context.coordinator.alert = alert

            alert.addTextField { textField in
                textField.text = self.text
            }

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.isPresented.wrappedValue = false
                context.coordinator.alert = nil
            })

            alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
                if let textField = alert.textFields?.first, let text = textField.text {
                    self.text = text
                }
                self.isPresented.wrappedValue = false
                context.coordinator.alert = nil
            })

            DispatchQueue.main.async { // Wait till the current view controller is completely presented
                uiViewController.present(alert, animated: true, completion: {
                    self.isPresented.wrappedValue = false
                    context.coordinator.alert = nil
                })
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var alert: UIAlertController?
        var control: TextFieldAlert

        init(_ control: TextFieldAlert) {
            self.control = control
        }
    }
}
