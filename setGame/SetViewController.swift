//
//  ViewController.swift
//  setGame
//
//  Created by Ryan Brazones on 9/3/18.
//  Copyright © 2018 greenred. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    private var gameModel = setGameModel()
    
    @IBOutlet weak var setCardGridView: SetCardGridView! {
        didSet {
            
            let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipDown(byReactingTo:)))
            swipeDownRecognizer.direction = .down
            setCardGridView.addGestureRecognizer(swipeDownRecognizer)
            
            let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(byReactingTo:)))
            setCardGridView.addGestureRecognizer(rotateRecognizer)
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
        setCardGridView.delegate = self
        setCardGridView.dealDelegate = self
    }

    @objc func handleSwipDown(byReactingTo swipeRecognizer: UISwipeGestureRecognizer){
        if swipeRecognizer.state == .ended {
            gameModel.dealMoreCards()
            updateViewFromModel()
        }
    }
    
    @objc func handleRotationGesture(byReactingTo rotationRecgonizer: UIRotationGestureRecognizer){
        if rotationRecgonizer.state == .ended {
            print("rotation gesture ended")
            setCardGridView.shuffleCards()
        }
    }
    
    private var mapGameCardToSetCardViews = Dictionary<Int, SetCardView>()
}

extension SetViewController: TouchSetCardDelegate {
    func touchedSetCard(with currentCardIndex: Int) {
        let card = setCardGridView.currentCards[currentCardIndex]
        let mapGameCardIndex = mapGameCardToSetCardViews.keysForValues(value: card)
        for cardIndex in mapGameCardIndex {
            if gameModel.selectedCards.count == 3 && !gameModel.selectedCards.contains(cardIndex) {
                return // do nothing
            } else {
                gameModel.attemptToSelect(on: cardIndex)
            }
        }
        
        // check if cards are matched when we select 3
        if gameModel.selectedCards.count == 3, gameModel.checkIfCardsMatched() {
            for card in gameModel.selectedCards {
                let removeCardView = mapGameCardToSetCardViews[card]!
                mapGameCardToSetCardViews.removeValue(forKey: card)
                setCardGridView.removeCard(card: removeCardView)
            }
            gameModel.clearMatchedCards()
        }
        
        updateViewFromModel()
    }
}

extension SetViewController: DealSetCardDelegate {
    func dealSetCard() {
        print("deal set card from view controller")
        gameModel.dealMoreCards()
        updateViewFromModel()
    }
}

extension SetViewController {
    
    private func updateViewFromModel() {
        
        func updateScore() {
            scoreLabel.text = "Score: \(gameModel.score)"
        }
        
        for card in gameModel.currentCards {
            if !mapGameCardToSetCardViews.keys.contains(card) {
                let newCardView = SetCardView()
                newCardView.shape = constantValues.cardShapes[gameModel.gameCards[card].shape]!
                newCardView.shade = constantValues.cardShades[gameModel.gameCards[card].shade]!
                newCardView.color = constantValues.cardColors[gameModel.gameCards[card].color]!
                newCardView.number = constantValues.cardNumbers[gameModel.gameCards[card].number]!
                mapGameCardToSetCardViews[card] = newCardView
                setCardGridView.currentCards += [newCardView]
            }
            if gameModel.selectedCards.contains(card){
                mapGameCardToSetCardViews[card]!.isSelected = true
            } else {
                mapGameCardToSetCardViews[card]!.isSelected = false
            }
        }
        
        updateScore()
    }
    
    // constant for drawing cards
    private struct constantValues {
        static let cardShapes = [setCard.shapeOptions.shapeA: SetCardView.withShape.oval,
                                 setCard.shapeOptions.shapeB: SetCardView.withShape.diamond,
                                 setCard.shapeOptions.shapeC: SetCardView.withShape.squiggle]
        static let cardNumbers = [setCard.numberOptions.numberA: 1,
                                  setCard.numberOptions.numberB: 2,
                                  setCard.numberOptions.numberC: 3]
        static let cardColors = [setCard.colorOptions.colorA: UIColor.red,
                                 setCard.colorOptions.colorB: UIColor.purple,
                                 setCard.colorOptions.colorC: UIColor.green]
        static let cardShades = [setCard.shadeOptions.shadeA: SetCardView.withShade.solid,
                                 setCard.shadeOptions.shadeB: SetCardView.withShade.striped,
                                 setCard.shadeOptions.shadeC: SetCardView.withShade.unfilled]
        static let buttonOutlineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        static let matchButtonColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let dealCardsButtonColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
    }
}

// https://ijoshsmith.com/2016/04/14/find-keys-by-value-in-swift-dictionary/
extension Dictionary where Value: Equatable {
    func keysForValues(value: Value) -> [Key] {
        return compactMap {(key: Key, val: Value) -> Key? in
            value == val ? key : nil
        }
    }
}

protocol TouchSetCardDelegate {
    func touchedSetCard(with currentCardIndex: Int)
}

protocol DealSetCardDelegate {
    func dealSetCard()
}

