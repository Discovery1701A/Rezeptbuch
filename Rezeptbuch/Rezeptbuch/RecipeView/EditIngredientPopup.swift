//
//  EditIngredientPopup.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 09.03.25.
//

import SwiftUI
import SwiftUICore

/// Ein Popup zur Bearbeitung der Menge und Einheit einer Zutat.
struct EditIngredientPopup: View {
    @Binding var ingredient: FoodItemStruct  // Die zu bearbeitende Zutat
    @Binding var editedQuantity: String  // Die aktuell bearbeitete Menge als Zeichenkette
    @Binding var selectedUnit: Unit  // Die aktuell gewählte Einheit
    @State private var temporaryUnit: Unit  // Temporäre Einheit für Umrechnungen
    var onClose: () -> Void  // Callback zum Schließen des Popups
    var onSave: (Double, Unit) -> Void  // Callback zum Speichern der Änderungen
    
    /// Initialisiert das Popup mit den gegebenen Bindings und Callback-Funktionen.
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
        self._temporaryUnit = State(initialValue: selectedUnit.wrappedValue)  // Initialisiere die temporäre Einheit
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Menge bearbeiten")
                .font(.headline)
            
            // Zeigt den Namen der Zutat an
            Text(ingredient.food.name)
                .font(.title2)
            
            // Falls die Einheit "Stück" ist, kann sie nicht geändert werden
            if ingredient.unit == .piece {
                Text("Einheit kann nicht geändert werden, da es sich um eine Stückanzahl handelt.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            HStack {
                // Eingabefeld für die Menge
                TextField("Menge", text: $editedQuantity)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                // Einheitenauswahl (nur wenn nicht "Stück")
                Picker("Einheit", selection: $selectedUnit) {
                    ForEach(getAllowedUnits(), id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .disabled(ingredient.unit == .piece)  // Deaktiviert Picker für "Stück"
                .onChange(of: selectedUnit) { newUnit in
                    if ingredient.unit != .piece {
                        // Falls eine Umrechnung möglich ist, wird die Menge entsprechend angepasst
                        if let newQuantity = convertUnit(
                            value: Double(editedQuantity) ?? 0,
                            from: temporaryUnit,
                            to: newUnit,
                            density: ingredient.food.density
                        ) {
                            editedQuantity = String(format: "%.2f", newQuantity)
                        }
                        temporaryUnit = newUnit  // Aktualisiert die temporäre Einheit
                    }
                }
            }
            .padding()
            
            HStack {
                // Abbrechen-Button
                Button("Abbrechen") {
                    onClose()  // Popup schließen ohne Änderungen
                }
                .padding()
                
                // Speichern-Button
                Button("Speichern") {
                    if let newQuantity = Double(editedQuantity) {
                        onSave(newQuantity, selectedUnit)  // Speichert die Änderungen
                    }
                    onClose()  // Schließt das Popup nach dem Speichern
                }
                .disabled(Double(editedQuantity) ?? 0 <= 0)  // Deaktiviert Button, falls die Menge ungültig ist
                .padding()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    /// Gibt die erlaubten Einheiten basierend auf der vorhandenen Dichte zurück.
    private func getAllowedUnits() -> [Unit] {
        if ingredient.unit == .piece {
            return [selectedUnit]  // Falls die Einheit "Stück" ist, bleibt sie unverändert
        }
        
        if ingredient.food.density == nil || ingredient.food.density ?? 0 <= 0 {
            // Falls keine Dichte vorhanden ist, erlaube nur Umrechnungen innerhalb von Masse oder Volumen
            if ingredient.unit == .gram || ingredient.unit == .kilogram {
                return [.gram, .kilogram]
            } else if ingredient.unit == .milliliter || ingredient.unit == .liter {
                return [.milliliter, .liter]
            } else {
                return [ingredient.unit]  // Keine Umrechnung möglich
            }
        }
        
        // Falls eine Dichte vorhanden ist, erlaube alle Einheiten außer "Stück"
        return Unit.allCases.filter { $0 != .piece }
    }
    
    /// Wandelt eine Einheit in eine andere um, falls erlaubt.
    private func convertUnit(value: Double, from: Unit, to: Unit, density: Double?) -> Double? {
        // Definiere Umrechnungen innerhalb von Massen- und Volumeneinheiten
        let weightConversions: [Unit: Double] = [
            .gram: 1.0,
            .kilogram: 1000.0
        ]
        let volumeConversions: [Unit: Double] = [
            .milliliter: 1.0,
            .liter: 1000.0
        ]
        
        // Falls Umrechnung innerhalb von Massen- oder Volumeneinheiten möglich ist, wende sie an
        if let fromFactor = weightConversions[from], let toFactor = weightConversions[to] {
            return value * (fromFactor / toFactor)
        }
        if let fromFactor = volumeConversions[from], let toFactor = volumeConversions[to] {
            return value * (fromFactor / toFactor)
        }
        
        // Falls eine Dichte vorhanden ist, nutze sie für die Umrechnung zwischen Masse und Volumen
        if let density = density, density > 0 {
            return Unit.convert(value: value, from: from, to: to, density: density)
        }
        
        return nil  // Rückgabe nil, falls keine gültige Umrechnung gefunden wurde
    }
}
