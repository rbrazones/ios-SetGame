//
//  setGameModel.swift
//  setGame
//
//  Created by Ryan Brazones on 9/5/18.
//  Copyright © 2018 greenred. All rights reserved.
//

import Foundation

class setGameModel {
    
    var gameCards = [setCard]()
    var currentCards = [Int]()
    var availableCards = [Int]()
    var matchedCards = [Int]()
    var selectedCards = [Int]()
    private(set) var score: Int = 0
    
    private func createDeckOfCards() {
        // fill deck with cards
        // cycle through all shape/color/shade combinations
        for shape in setCard.shapeOptions.allValues {
            for color in setCard.colorOptions.allValues {
                for shade in setCard.shadeOptions.allValues {
                    for number in setCard.numberOptions.allValues {
                        let card = setCard(shape: shape, color: color, shading: shade, number: number)
                        gameCards += [card]
                    }
                }
            }
        }
        // initially mark all cards as available
        for index in gameCards.indices {
            availableCards += [index]
        }
    }
    
    // Go through each of the 4 categories: number, shape, shade, color
    // For a set to be matched, each category must be
    // (1) all the same
    // (2) or all different
    func checkIfCardsMatched() -> Bool {
        
        assert(selectedCards.count == 3, "setGameModel.checkIfCardsMatched: invalid number of cards to compare")
        
        let card1 = gameCards[selectedCards[0]]
        let card2 = gameCards[selectedCards[1]]
        let card3 = gameCards[selectedCards[2]]
        
        return setCard.formsSet(cardA: card1, cardB: card2, cardC: card3)
        //return true // temporary for now while we test out animations
    }
    
    func clearMatchedCards() {
        assert(selectedCards.count == 3, "setGameModel.clearMatchedCards: Matched set must contain 3 cards")
        for _ in selectedCards.indices {
            let matchedCard = selectedCards.remove(at: 0)
            let removeIndex = currentCards.index(of: matchedCard)!
            currentCards.remove(at: removeIndex)
            matchedCards += [matchedCard]
        }
        
        score += 100
        //matchedCards += selectedCards
        //selectedCards.removeAll()
    }
    
    func dealMoreCards() {
        func actuallyDealThisMany(of cards: Int){
            for _ in 1...cards {
                let randomIndex = Int(arc4random_uniform(UInt32(availableCards.count)))
                let tempInt = availableCards.remove(at: randomIndex)
                currentCards += [tempInt]
            }
        }
        
        // deal 3 more cards
        var numberOfCardsToDeal = 3
        if availableCards.count < 3 {
            numberOfCardsToDeal = availableCards.count
        }
        if numberOfCardsToDeal > 0 {
            actuallyDealThisMany(of: numberOfCardsToDeal)
        }
        
        print("Current cards = \(currentCards)")
        print("Available cards = \(availableCards)")
        print("Matched cards = \(matchedCards)")
        print("Selected cards = \(selectedCards)")
    }
    
    func attemptToSelect(on card: Int){
        if selectedCards.contains(card) {
            let removeIndex = selectedCards.index(of: card)!
            selectedCards.remove(at: removeIndex)
        } else {
            selectedCards += [card]
        }
    }
    
    func startNewGame() {
        
        // clear out arrays from past games
        gameCards.removeAll()
        currentCards.removeAll()
        availableCards.removeAll()
        matchedCards.removeAll()
        selectedCards.removeAll()
        score = 0
        
        // restart things
        createDeckOfCards()
        
        // select 12 initial cards to start the game
        for _ in 1...12 {
            let randomIndex = Int(arc4random_uniform(UInt32(availableCards.count)))
            let tempInt = availableCards.remove(at: randomIndex)
            currentCards += [tempInt]
        }
        
        print("Current cards = \(currentCards)")
        print("Available cards = \(availableCards)")
        print("Matched cards = \(matchedCards)")
        print("Selected cards = \(selectedCards)")
    }
    
    init() {
        startNewGame()
    }
}
