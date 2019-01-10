//
//  setCard.swift
//  setGame
//
//  Created by Ryan Brazones on 9/5/18.
//  Copyright © 2018 greenred. All rights reserved.
//

import Foundation

struct setCard {
    
    enum shapeOptions: String {
        case shapeA
        case shapeB
        case shapeC
        
        static let allValues = [shapeA, shapeB, shapeC]
    }
    
    enum colorOptions: String {
        case colorA
        case colorB
        case colorC
        
        static let allValues = [colorA, colorB, colorC]
    }
    
    enum shadeOptions: String {
        case shadeA
        case shadeB
        case shadeC
        
        static let allValues = [shadeA, shadeB, shadeC]
    }
    
    enum numberOptions: String{
        case numberA
        case numberB
        case numberC
        
        static let allValues = [numberA, numberB, numberC]
    }
    
    var shape: shapeOptions
    var color: colorOptions
    var shade: shadeOptions
    var number: numberOptions
    
    init(shape: shapeOptions, color: colorOptions, shading: shadeOptions, number: numberOptions) {
        self.shape = shape
        self.color = color
        self.shade = shading
        self.number = number
    }
    
    static func formsSet(cardA: setCard, cardB: setCard, cardC: setCard) -> Bool {
        
        func satisfiesSetCriteria(input1: String, input2: String, input3: String) -> Bool {
            if (input1 == input2) && (input2 == input3) {
                return true
            } else if (input1 != input2) && (input2 != input3) && (input1 != input3){
                return true
            } else {
                return false
            }
        }
        
        let shadeCheck = satisfiesSetCriteria(input1: cardA.shade.rawValue, input2: cardB.shade.rawValue, input3: cardC.shade.rawValue)
        let shapeCheck = satisfiesSetCriteria(input1: cardA.shape.rawValue, input2: cardB.shape.rawValue, input3: cardC.shape.rawValue)
        let numberCheck = satisfiesSetCriteria(input1: cardA.number.rawValue, input2: cardB.number.rawValue, input3: cardC.number.rawValue)
        let colorCheck = satisfiesSetCriteria(input1: cardA.color.rawValue, input2: cardB.color.rawValue, input3: cardC.color.rawValue)
        
        return (shadeCheck && shapeCheck) && (numberCheck && colorCheck)
    }
}
