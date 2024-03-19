//
//  ContentView.swift
//  TestVonCode
//
//  Created by Anna Rieckmann on 19.03.24.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedOption: String?
    @State private var filteredOptions: [String] = []
    @State private var isTyping = false
    
    let options = ["Apple", "Banana", "Orange", "Pineapple", "Strawberry"]
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText, onEditingChanged: { editing in
                isTyping = editing
            })
            .padding()
            .onChange(of: searchText) { newValue in
                filteredOptions = options.filter { $0.localizedCaseInsensitiveContains(newValue) }
            }
            
            if let selectedOption = selectedOption {
                Text("Selected option: \(selectedOption)")
            }
            
            Spacer() // Push the options view to the bottom
        }
        //.padding()
        .popover(isPresented: Binding<Bool>(
            get: { !filteredOptions.isEmpty && isTyping },
            set: { _ in }
        )) {
            OptionsListView(options: filteredOptions, selectedOption: $selectedOption, searchText: $searchText)
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
              
                .padding()
        }.frame(maxWidth: .infinity, maxHeight: 200)
    }
}

struct OptionsListView: View {
    let options: [String]
    @Binding var selectedOption: String?
    @Binding var searchText: String
    
    var body: some View {
        List(options, id: \.self) { option in
            Button(action: {
                selectedOption = option
                searchText = option // Set the searchText to the selected option
            }) {
                Text(option)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
