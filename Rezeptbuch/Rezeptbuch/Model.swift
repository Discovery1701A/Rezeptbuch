//
//  Model.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 29.03.24.
//

import Foundation

struct Model {
    
    func roundToRect(diameter: Double, length: Double) -> Double {
        let area = pow(diameter/2,2)*Double.pi
        let width = area / length
        return width
    }
    
    func rectToRound(length: Double, width: Double) -> Double {
        let area = length * width
        let diameter = sqrt(area / Double.pi)*2
        return diameter
    }
    
    func roundScale(diameterOrigin: Double, diameterNew: Double, foodItems: [FoodItem]) -> [FoodItem] {
        let scale = (pow(diameterOrigin/2,2)*Double.pi) / (pow(diameterNew/2,2)*Double.pi)
        print(diameterOrigin,diameterNew)
        var scaledItems: [FoodItem] = []
        for i in 0..<foodItems.count {
            let item = foodItems[i]
            scaledItems.append(item)
            scaledItems[i].quantity /= scale
            print( scaledItems[i].quantity, item.quantity, scale)
        }
        return scaledItems
    }
    
    func rectScale(lengthOrigin: Double, widthOrigin: Double, lengthNew: Double, widthNew: Double, foodItems: [FoodItem]) -> [FoodItem] {
        let scale = (lengthOrigin * widthOrigin) / (lengthNew * widthNew)
        var scaledItems: [FoodItem] = []
        for i in 0..<foodItems.count {
            var item = foodItems[i]
            item.quantity /= scale
            scaledItems.append(item)
        }
        return scaledItems
    }
    
   public func portionScale(portionOrigin: Double, portionNew: Double, foodItems: [FoodItem]) -> [FoodItem] {
        let scale = portionOrigin / portionNew
        var scaledItems: [FoodItem] = []
        for i in 0..<foodItems.count {
            var item = foodItems[i]
            item.quantity /= scale
            scaledItems.append(item)
        }
        return scaledItems
    }
    
    public func itemScale(foodItemsOrigin: [FoodItem], foodItemsNew: [FoodItem]) -> [FoodItem] {
        var scale: Double = 1.0
        var scaledItems: [FoodItem] = []
        for i in 0..<foodItemsOrigin.count {
            if foodItemsOrigin[i].quantity != foodItemsNew[i].quantity {
                scale = foodItemsOrigin[i].quantity / foodItemsNew[i].quantity
            }
        }
        for i in 0..<foodItemsOrigin.count {
            var item = foodItemsOrigin[i]
            item.quantity *= scale
            scaledItems.append(item)
        }
        return scaledItems
    }
    
}
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
