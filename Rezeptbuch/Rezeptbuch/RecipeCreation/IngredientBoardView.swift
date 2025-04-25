//
//  IngredientBoardView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 24.04.25.
//

//import SwiftUI
//struct IngredientComponent: Identifiable, Equatable {
//    var id = UUID()
//    var name: String
//    var ingredients: [EditableIngredient]
//}
//struct IngredientBoardView: View {
//    @State private var allIngredients: [EditableIngredient] = []
//    @State private var components: [IngredientComponent] = []
//    @State private var newComponentName: String = ""
//    @FocusState private var isComponentNameFieldFocused: Bool
//    @State private var draggedIngredient: EditableIngredient? = nil
//
//    @State private var isDropTargeted: Bool = false
//
//    var modelView: ViewModel
//
//    var body: some View {
//        let sorted = allIngredients.sorted(by: { ($0.number ?? 0) < ($1.number ?? 0) })
//
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//
//                HStack {
//                    TextField("Name der Komponente", text: $newComponentName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .frame(minWidth: 150)
//                        .focused($isComponentNameFieldFocused)
//
//                    Button(action: {
//                        let trimmed = newComponentName.trimmingCharacters(in: .whitespaces)
//                        guard !trimmed.isEmpty else { return }
//                        components.append(IngredientComponent(name: trimmed, ingredients: []))
//
//                        let maxNumber = (allIngredients.map { $0.number ?? 0 }.max() ?? 0)
//                        var newIngredient = EditableIngredient()
//                        newIngredient.component = trimmed
//                        newIngredient.number = maxNumber + 10
//                        allIngredients.append(newIngredient)
//
//                        newComponentName = ""
//                        isComponentNameFieldFocused = false
//                    }) {
//                        Label("Komponente hinzufügen", systemImage: "plus.rectangle.on.rectangle")
//                    }
//                }
//                .padding(.horizontal)
//
//                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, ingredient in
//                    let currentComponent = ingredient.component
//                    let previousComponent = index > 0 ? sorted[index - 1].component : nil
//                    let showHeader = currentComponent != previousComponent
//
//                    VStack(alignment: .leading, spacing: 4) {
//                        if showHeader {
//                            if let name = currentComponent {
//                                HStack {
//                                    Text(name)
//                                        .font(.headline)
//                                    Spacer()
//                                    Button(role: .destructive) {
//                                        components.removeAll { $0.name == name }
//                                        allIngredients.removeAll { $0.component == name }
//                                    } label: {
//                                        Image(systemName: "trash")
//                                    }
//                                }
//                                .padding(.top, 8)
//                            }
//                        }
//
////                        Rectangle()
////                            .fill(isDropTargeted ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.15))
////                            .frame(height: 12)
////                            .cornerRadius(4)
////                            .onDrop(of: [.text], isTargeted: $isDropTargeted) { _ in
////                                if let dragged = draggedIngredient {
////                                    print(dragged.food.name)
////                                    moveIngredient(dragged, toComponent: currentComponent, at: index)
////                                    draggedIngredient = nil
////                                    return true
////                                }
////                                return false
////                            }
//
//                        IngredientRow(
//                           
//
//                            index: index,
//                            food: Binding(get: {
//                                ingredient.food
//                            }, set: { new in
//                                if let i = allIngredients.firstIndex(where: { $0.id == ingredient.id }) {
//                                    allIngredients[i].food = new
//                                }
//                            }),
//                            quantity: Binding(get: {
//                                ingredient.quantity
//                            }, set: { new in
//                                if let i = allIngredients.firstIndex(where: { $0.id == ingredient.id }) {
//                                    allIngredients[i].quantity = new
//                                }
//                            }),
//                            selectedUnit: Binding(get: {
//                                ingredient.unit
//                            }, set: { new in
//                                if let i = allIngredients.firstIndex(where: { $0.id == ingredient.id }) {
//                                    allIngredients[i].unit = new
//                                }
//                            }),
//                            allFoods: modelView.foods,
//                            modelView: modelView,
//                            onDelete: {
//                                allIngredients.removeAll { $0.id == ingredient.id }
//                            },
//                            draggedIngredient: $draggedIngredient,
//                            ingredient: Binding(get: {
//                                allIngredients.first(where: { $0.id == ingredient.id }) ?? ingredient
//                            }, set: { new in
//                                if let i = allIngredients.firstIndex(where: { $0.id == ingredient.id }) {
//                                    allIngredients[i] = new
//                                }
//                            })
//                        )
//                    }
//                }
//
////                Rectangle()
////                    .fill(isDropTargeted ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.15))
////                    .frame(height: 12)
////                    .cornerRadius(4)
////                    .onDrop(of: [.text], isTargeted: $isDropTargeted) { _ in
////                        if let dragged = draggedIngredient {
////                            let maxNumber = (allIngredients.map { $0.number ?? 0 }.max() ?? 0)
////                            moveIngredient(dragged, toComponent: nil, at: Int(maxNumber + 10))
////                            draggedIngredient = nil
////                            return true
////                        }
////                        return false
////                    }
//
//                Button {
//                    let maxNumber = (allIngredients.map { $0.number ?? 0 }.max() ?? 0)
//                    var new = EditableIngredient()
//                    new.number = maxNumber + 10
//                    allIngredients.append(new)
//                } label: {
//                    Label("Zutat hinzufügen", systemImage: "plus.circle")
//                }
//                .padding(.top, 8)
//            }
//            .padding()
//        }
////        .gesture(DragGesture(minimumDistance: 9999)) // verschluckt Drag
//    }
//
//    private func moveIngredient(_ ingredient: EditableIngredient, toComponent: String?, at index: Int) {
//        withAnimation {
//            allIngredients.removeAll { $0.id == ingredient.id }
//
//            var newIngredient = ingredient
//            newIngredient.component = toComponent
//
//            let sameComponent = allIngredients
//                .filter { $0.component == toComponent }
//                .sorted(by: { ($0.number ?? 0) < ($1.number ?? 0) })
//
//            let before = index > 0 ? sameComponent[safe: index - 1]?.number : nil
//            let after = sameComponent[safe: index]?.number
//
//            let newNumber: Int64
//            switch (before, after) {
//            case let (a?, b?): newNumber = (a + b) / 2
//            case let (a?, nil): newNumber = a + 10
//            case let (nil, b?): newNumber = b - 10
//            default: newNumber = 0
//            }
//
//            newIngredient.number = newNumber
//            allIngredients.append(newIngredient)
//        }
//    }
//}
//
//
//
////
////struct ComponentColumnView: View {
////    @Binding var title: String
////    @Binding var ingredients: [EditableIngredient]
////    var modelView: ViewModel
////    var onDeleteComponent: (() -> Void)?
////    @Binding var draggedIngredient: EditableIngredient?
////    var onDropIngredient: (EditableIngredient, Int) -> Void
////
////    var body: some View {
////        VStack(alignment: .leading, spacing: 8) {
////            if !title.trimmingCharacters(in: .whitespaces).isEmpty || onDeleteComponent != nil {
////                HStack {
////                    TextField("Komponentenname", text: $title)
////                        .font(.headline)
////                    Spacer()
////                    if let onDelete = onDeleteComponent {
////                        Button(role: .destructive, action: onDelete) {
////                            Image(systemName: "trash")
////                        }
////                    } else {
////                        Image(systemName: "line.3.horizontal")
////                    }
////                }
////                .padding(.vertical, 4)
////            }
////
////            ForEach(Array(ingredients.enumerated()), id: \.element.id) { index, ingredient in
////                VStack(spacing: 4) {
////                    Rectangle()
////                        .fill(Color.gray.opacity(0.15))
////                        .frame(height: 8)
////                        .cornerRadius(4)
////                        .onDrop(of: [.text], isTargeted: nil) { _ in
////                            if let dragged = draggedIngredient {
////                                onDropIngredient(dragged, index)
////                                draggedIngredient = nil
////                                return true
////                            }
////                            return false
////                        }
////
////                    IngredientRow(
////                        index: index,
////                        food: Binding(get: {
////                            ingredient.food
////                        }, set: { new in
////                            if let i = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
////                                ingredients[i].food = new
////                            }
////                        }),
////                        quantity: Binding(get: {
////                            ingredient.quantity
////                        }, set: { new in
////                            if let i = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
////                                ingredients[i].quantity = new
////                            }
////                        }),
////                        selectedUnit: Binding(get: {
////                            ingredient.unit
////                        }, set: { new in
////                            if let i = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
////                                ingredients[i].unit = new
////                            }
////                        }),
////                        allFoods: modelView.foods,
////                        modelView: modelView,
////                        onDelete: {
////                            ingredients.removeAll { $0.id == ingredient.id }
////                        }
////                    )
////                    .onDrag {
////                        draggedIngredient = ingredient
////                        return NSItemProvider(object: NSString(string: ingredient.id.uuidString))
////                    }
////                }
////            }
////            .onDelete { indexSet in
////                ingredients.remove(atOffsets: indexSet)
////            }
////
////            // Dropzone am Ende
////            Rectangle()
////                .fill(Color.gray.opacity(0.15))
////                .frame(height: 8)
////                .cornerRadius(4)
////                .onDrop(of: [.text], isTargeted: nil) { _ in
////                    if let dragged = draggedIngredient {
////                        onDropIngredient(dragged, ingredients.count)
////                        draggedIngredient = nil
////                        return true
////                    }
////                    return false
////                }
////
////            Button(action: {
////                ingredients.append(EditableIngredient())
////            }) {
////                Label("Zutat hinzufügen", systemImage: "plus.circle")
////            }
////            .padding(.top, 4)
////        }
////        .padding()
////        .background(
////            RoundedRectangle(cornerRadius: 20)
////                .fill(Color.white)
////                .shadow(radius: 4)
////        )
////    }
////}
