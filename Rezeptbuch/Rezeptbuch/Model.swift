//
//  Model.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 29.03.24.
//

import Foundation

struct Model {
    
    func roundtorect(diameter:Double,lenght : Double) -> Double{
        var flaeche = diameter * Double.pi
        var width = flaeche / lenght
        return width
    }
    
    func rectToRound(lenght:Double,width:Double)->Double{
        var flaeche = lenght * width
        var diameter = flaeche / Double.pi
        return diameter
    }
    
    func roundScale(diameterOrigin:Double,diameterNew:Double,foodItems: [FoodItem]) -> [FoodItem]{
        var scale = diameterOrigin / diameterNew
        var Items : [FoodItem] = []
        for i in 0 ..< foodItems.count {
            Items.append(foodItems[i])
            Items[i].quantity = foodItems[i].quantity*scale
        }
        return Items
    }
    
    func  rectScale(lenghtOrigin:Double,widthOrigin:Double, lenghtNew:Double ,widthNew : Double,foodItems: [FoodItem]) -> [FoodItem]{
        
        var scale = (lenghtOrigin * widthOrigin) / (lenghtNew * widthNew)
        var Items : [FoodItem] = []
        for i in 0 ..< foodItems.count {
            Items.append(foodItems[i])
            Items[i].quantity = foodItems[i].quantity*scale
        }
        return Items
    }
    
    func portionScale(portionOrigin:Double,portionNew:Double,foodItems: [FoodItem]) -> [FoodItem]{
        var scale = portionOrigin / portionNew
        var Items : [FoodItem] = []
        for i in 0 ..< foodItems.count {
            Items.append(foodItems[i])
            Items[i].quantity = foodItems[i].quantity*scale
        }
        return Items
    }
    
    func itemScale(foodItemsOrigin:[FoodItem], foodItemsNew:[FoodItem])-> [FoodItem]{
        var scale: Double = 1.0
        var Items : [FoodItem] = []
        for i in 0 ..< foodItemsOrigin.count{
            if foodItemsOrigin[i].quantity != foodItemsNew[i].quantity {
                scale = foodItemsOrigin[i].quantity / foodItemsNew[i].quantity
            }
        }
        for i in 0 ..< foodItemsOrigin.count{
            Items.append(foodItemsOrigin[i])
            Items[i].quantity = foodItemsOrigin[i].quantity * scale
        }
        return Items
    }
    
    
}
