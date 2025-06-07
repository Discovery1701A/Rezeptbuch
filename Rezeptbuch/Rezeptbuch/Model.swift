//
//  Model.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 29.03.24.
//

import Foundation
/// Modell für Skalierungen und Umrechnungen bei Rezepten (z.B. Größenänderungen von Kuchenformen, Portionen, etc.).
struct Model {
    
    /// Berechnet die Breite eines rechteckigen Kuchens basierend auf dem Durchmesser eines runden Kuchens mit gleicher Fläche.
    func roundToRect(diameter: Double, length: Double) -> Double {
        let area = pow(diameter / 2, 2) * Double.pi  // Fläche des runden Kuchens
        let width = area / length  // Breite berechnen
        return width
    }
    
    /// Berechnet den Durchmesser eines runden Kuchens basierend auf den Maßen eines rechteckigen Kuchens mit gleicher Fläche.
    func rectToRound(length: Double, width: Double) -> Double {
        let area = length * width  // Fläche des Rechtecks
        let diameter = sqrt(area / Double.pi) * 2  // Durchmesser berechnen
        return diameter
    }
    
    /// Skaliert die Zutaten eines runden Kuchens auf einen neuen Durchmesser.
    func roundScale(diameterOrigin: Double, diameterNew: Double, foodItems: [FoodItemStruct]) -> [FoodItemStruct] {
        let scale = (pow(diameterOrigin / 2, 2) * Double.pi) / (pow(diameterNew / 2, 2) * Double.pi)  // Verhältnis der Flächen
        var scaledItems: [FoodItemStruct] = []
        for i in 0..<foodItems.count {
            let item = foodItems[i]
            var scaledItem = item
            scaledItem.quantity /= scale  // Menge skalieren
            scaledItems.append(scaledItem)
        }
        return scaledItems.sorted { $0.number ?? 0 < $1.number ?? 1 }
    }
    
    /// Skaliert die Zutaten eines rechteckigen Kuchens auf neue Längen- und Breitenwerte.
    func rectScale(lengthOrigin: Double, widthOrigin: Double, lengthNew: Double, widthNew: Double, foodItems: [FoodItemStruct]) -> [FoodItemStruct] {
        let scale = (lengthOrigin * widthOrigin) / (lengthNew * widthNew)  // Verhältnis der Flächen
        var scaledItems: [FoodItemStruct] = []
        for i in 0..<foodItems.count {
            var item = foodItems[i]
            item.quantity /= scale  // Menge skalieren
            scaledItems.append(item)
        }
        return scaledItems.sorted { $0.number ?? 0 < $1.number ?? 1 }
    }
    
    /// Skaliert die Zutaten basierend auf der Anzahl der Portionen (z.B. von 4 auf 8 Portionen verdoppeln).
    public func portionScale(portionOrigin: Double, portionNew: Double, foodItems: [FoodItemStruct]) -> [FoodItemStruct] {
        let scale = portionOrigin / portionNew
        var scaledItems: [FoodItemStruct] = []
        for i in 0..<foodItems.count {
            var item = foodItems[i]
            item.quantity /= scale  // Menge skalieren
            scaledItems.append(item)
        }
        
        return scaledItems.sorted { $0.number ?? 0 < $1.number ?? 1 }
    }
    
    /// Skaliert die Zutaten automatisch, indem die Änderung an einer einzelnen Zutat auf alle übertragen wird.
    /// Praktisch, wenn ein Benutzer eine Zutat manuell verändert und der Rest angepasst werden soll.
    public func itemScale(foodItemsOrigin: [FoodItemStruct], foodItemsNew: [FoodItemStruct]) -> [FoodItemStruct] {
        var scale: Double = 1.0
        var scaledItems: [FoodItemStruct] = []

        for i in 0..<foodItemsOrigin.count {
            if foodItemsOrigin[i].quantity != foodItemsNew[i].quantity {
                scale = foodItemsOrigin[i].quantity / foodItemsNew[i].quantity  // Skala basierend auf erster geänderter Zutat finden
            }
        }

        for i in 0..<foodItemsOrigin.count {
            var item = foodItemsOrigin[i]
            item.quantity *= scale  // Alle Mengen anpassen
            scaledItems.append(item)
        }
        return scaledItems.sorted { $0.number ?? 0 < $1.number ?? 1 }
    }
}

/// Erweiterung für `Double`, um Zahlen auf eine bestimmte Anzahl von Nachkommastellen zu runden.
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
