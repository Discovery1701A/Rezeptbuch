//
//  EditIngredientPopup.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 09.03.25.
//


import SwiftUI
import SwiftUICore

struct EditIngredientPopup: View {
    @Binding var ingredient: FoodItemStruct
    @Binding var editedQuantity: String
    @Binding var selectedUnit: Unit
    @State private var temporaryUnit: Unit // Temporäre Einheit für Berechnungen
    var onClose: () -> Void // Callback zum Schließen des Popups
    var onSave: (Double, Unit) -> Void // Callback zum Speichern und Anpassen der anderen Zutaten
    
    init(
        ingredient: Binding<FoodItemStruct>,
        editedQuantity: Binding<String>,
        selectedUnit: Binding<Unit>,
        onSave: @escaping (Double, Unit) -> Void,
        onClose: @escaping () -> Void
    ) {
        self._ingredient = ingredient
        self._editedQuantity = editedQuantity
        self._selectedUnit = selectedUnit
        self.onClose = onClose
        self.onSave = onSave
        self._temporaryUnit = State(initialValue: selectedUnit.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Menge bearbeiten")
                .font(.headline)
            
            Text(ingredient.food.name)
                .font(.title2)
            
            if ingredient.unit == .piece {
                Text("Einheit kann nicht geändert werden, da es sich um eine Stückanzahl handelt.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            HStack {
                TextField("Menge", text: $editedQuantity)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Picker("Einheit", selection: $selectedUnit) {
                    ForEach(getAllowedUnits(), id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .disabled(ingredient.unit == .piece)
                .onChange(of: selectedUnit) { newUnit in
                    if ingredient.unit != .piece {
                        if let newQuantity = convertUnit(
                            value: Double(editedQuantity) ?? 0,
                            from: temporaryUnit,
                            to: newUnit,
                            density: ingredient.food.density
                        ) {
                            editedQuantity = String(format: "%.2f", newQuantity)
                        }
                        temporaryUnit = newUnit
                    }
                }
            }
                
                .padding()
                
                HStack {
                    Button("Abbrechen") {
                        onClose() // Popup schließen ohne Änderungen
                    }
                    .padding()
                    
                    Button("Speichern") {
                        if let newQuantity = Double(editedQuantity) {
                            onSave(newQuantity, selectedUnit) // Rückgabe an die übergeordnete Ansicht
                        }
                        onClose() // Schließt das Popup
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        
    }
    
    /// Gibt die erlaubten Einheiten basierend auf der vorhandenen Dichte zurück
    private func getAllowedUnits() -> [Unit] {
        if ingredient.unit == .piece {
            return [selectedUnit] // Wenn die Einheit "Stück" ist, bleibt sie unverändert
        }
        
        if ingredient.food.density == nil || ingredient.food.density ?? 0 <= 0 {
            // Falls keine Dichte vorhanden ist, nur Gramm ↔ Kilogramm und Milliliter ↔ Liter erlauben
            if ingredient.unit == .gram || ingredient.unit == .kilogram {
                return [.gram, .kilogram]
            } else if ingredient.unit == .milliliter || ingredient.unit == .liter {
                return [.milliliter, .liter]
            } else {
                return [ingredient.unit] // Keine Umrechnung möglich
            }
        }
        
        // Falls eine Dichte vorhanden ist und die Einheit nicht "Stück" ist, entfernen wir ".piece"
        return Unit.allCases.filter { $0 != .piece }
    }
    
    /// Wandelt eine Einheit in eine andere um, falls erlaubt
    private func convertUnit(value: Double, from: Unit, to: Unit, density: Double?) -> Double? {
        // Erlaubt Umrechnung nur zwischen g/kg und ml/l ohne Dichte
        let weightConversions: [Unit: Double] = [
            .gram: 1.0,
            .kilogram: 1000.0
        ]
        let volumeConversions: [Unit: Double] = [
            .milliliter: 1.0,
            .liter: 1000.0
        ]
        
        if let fromFactor = weightConversions[from], let toFactor = weightConversions[to] {
            return value * (fromFactor / toFactor)
        }
        if let fromFactor = volumeConversions[from], let toFactor = volumeConversions[to] {
            return value * (fromFactor / toFactor)
        }
        
        // Falls eine Dichte vorhanden ist, nutze sie für Umrechnungen zwischen Volumen und Gewicht
        if let density = density, density > 0 {
            return Unit.convert(value: value, from: from, to: to, density: density)
        }
        return nil
    }
}
