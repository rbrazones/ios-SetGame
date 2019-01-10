//
//  SetCardGridView.swift
//  setGame
//
//  Created by Ryan Brazones on 9/16/18.
//  Copyright © 2018 greenred. All rights reserved.
//

import UIKit

class SetCardGridView: UIView, UIGestureRecognizerDelegate {

    var currentCards = [SetCardView]() { didSet{ setNeedsLayout(); setNeedsDisplay() }}
    var discardPile = SetCardView()
    var drawCardPile = SetCardView()
    var delegate: TouchSetCardDelegate?
    var dealDelegate: DealSetCardDelegate?
    
    var globalDiscardPoint: CGPoint?
    var globalCardSize: CGSize?
    
    lazy var animator = UIDynamicAnimator(referenceView: self)
    lazy var cardBehavior = CardBehavior(in: animator)
        
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCards()
        print("current number of cards = \(currentCards.count)")
    }
    
    // send the cardIndex to parent ViewController to be dealt with
    @objc func handleTapOnCard(_ sender: AnyObject){
        if let test = sender.view?.tag { delegate?.touchedSetCard(with: test) }
    }
    
    // deal cards
    @ objc func handleTapOnDealCards(_ sender: AnyObject){
        dealDelegate?.dealSetCard()
        print("handleTaponDealCards")
    }
}

extension SetCardGridView {
    
    func removeCard(card: SetCardView) {
        let removeIndex = currentCards.index(of: card)!
        currentCards.remove(at: removeIndex)
        card.isSelected = false
        cardBehavior.addItem(card)
        card.gestureRecognizers?.forEach(card.removeGestureRecognizer(_:))
        
        // put the card in the discard pile
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [weak self] in
            self?.cardBehavior.removeItem(card)
            self?.discardPileAnimation(on: card)
        })
        
        setNeedsLayout()
    }
    
    func shuffleCards() {
        let numberOfCards = currentCards.count
        for index in currentCards.indices {
            var swapIndex = Int(arc4random_uniform(UInt32(numberOfCards - index)))
            swapIndex += index
            currentCards.swapAt(index, swapIndex)
        }
        setNeedsLayout()
    }
    
    private func layoutCards() {
        
        if currentCards.count == 0 { return }
        
        let (rows, columns) = determineOptimalRowsColumnsWithExtraRowAdded()
        let (cardWidth, cardHeight) = determineCardDimensions(rows: rows, columns: columns)
        let (horinzontalSpacing, verticalSpacing) = determineBestSpacingBetweenCards(for: cardWidth, and: cardHeight, rows: rows, cols: columns)
        
        globalCardSize = CGSize(width: cardWidth, height: cardHeight)
        
        // layout points to place cards in advance based on how many
        // cards we have to layout, and the determined spacing between
        // those cards
        
        var points = [CGPoint]()
        for j in 0..<(rows - 1) {
            for i in 0..<columns {
                points += [CGPoint(x: CGFloat(i) * (cardWidth + horinzontalSpacing),
                                   y: CGFloat(j) * (cardHeight + verticalSpacing))]
            }
        }
        
        // determine the points where the discard pile and draw new
        // card pile need to be placed
        // [Draw] - [Discard]
        
        let centerCardsOffset = (bounds.size.width - (2 * cardWidth + horinzontalSpacing)) / 2
        
        let drawNewCardPoint = CGPoint(x: centerCardsOffset,
                                       y: CGFloat(rows - 1) * (cardHeight + verticalSpacing))
        
        let discardPilePoint = CGPoint(x: centerCardsOffset + cardWidth + horinzontalSpacing,
                                       y: CGFloat(rows - 1) * (cardHeight + verticalSpacing))
        
        globalDiscardPoint = discardPilePoint
        
        // place the discard and draw new card piles first
        discardPile.isFaceUp = false
        drawCardPile.isFaceUp = false
        
        print("bounds is \(bounds.size)")
        print("point is \(discardPilePoint)")
        print("point is \(drawNewCardPoint)")
        
        if (!subviews.contains(discardPile)) {
            discardPile.frame.size = CGSize(width: cardWidth, height: cardHeight)
            discardPile.isHidden = false
            discardPile.isOpaque = false
            discardPile.frame.origin = discardPilePoint
            addSubview(discardPile)
        } else {
            animateCardObject(on: discardPile, to: discardPilePoint, with: cardWidth, and: cardHeight, with: 0)
        }
        
        if (!subviews.contains(drawCardPile)) {
            drawCardPile.frame.size = CGSize(width: cardWidth, height: cardHeight)
            drawCardPile.isHidden = false
            drawCardPile.isOpaque = false
            drawCardPile.frame.origin = drawNewCardPoint
            addSubview(drawCardPile)
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnDealCards(_:)))
            gestureRecognizer.delegate = self
            drawCardPile.addGestureRecognizer(gestureRecognizer)
        } else {
            animateCardObject(on: drawCardPile, to: drawNewCardPoint, with: cardWidth, and: cardHeight, with: 0)
        }
        
        // layout the cards on the pre-determined points
        var temp = 0
        for card in currentCards {
            if subviews.contains(card){
                card.frame.size = CGSize(width: cardWidth, height: cardHeight)
                if card.frame.origin != points[temp] {
                    animateCardObject(on: card, to: points[temp], with: cardWidth, and: cardHeight, with: 0)
                }
                //card.frame.origin = points[temp]
                card.tag = currentCards.index(of: card)!
                card.isOpaque = false
                temp += 1
            }
        }
        
        // deal new cards afterwards
        var baseCardDealDelay = constants.cardReorderAnimationTime
        for card in currentCards {
            if !subviews.contains(card) {
                
                // initially place the cards on the draw pile
                card.frame.size = CGSize(width: cardWidth, height: cardHeight)
                card.frame.origin = drawNewCardPoint
                addSubview(card)
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnCard))
                gestureRecognizer.delegate = self
                card.addGestureRecognizer(gestureRecognizer)
                card.tag = currentCards.index(of: card)!
                card.isOpaque = false
                card.isFaceUp = false
                
                // deal it to the new location
                dealNewCardsAnimations(on: card, to: points[temp], width: cardWidth, height: cardHeight, duration: constants.cardDealAnimationTime, delay: baseCardDealDelay)
                baseCardDealDelay += constants.cardDealAnimationTime
                
                temp += 1
            }
        }
    }
    
    // used for moving cards from one point to another
    private func animateCardObject(on card: SetCardView, to point: CGPoint, with width: CGFloat, and height: CGFloat,
                                   with delay: Double) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: constants.cardReorderAnimationTime,
                                                       delay: delay,
                                                       options: [],
                                                       animations: {
                                                           card.frame.origin = point
                                                           card.frame.size = CGSize(width: width, height: height)
                                                       },
                                                       completion: nil)
    }
    
    // used for dealing cards from deck to the playing field
    private func dealNewCardsAnimations(on card: SetCardView, to point: CGPoint, width: CGFloat, height: CGFloat,
                                        duration: Double, delay: Double) {
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration,
                                                       delay: delay,
                                                       options: [],
                                                       animations: {
                                                           card.frame.origin = point
                                                           card.frame.size = CGSize(width: width, height: height)
                                                        },
                                                       completion: { finished in
                                                        UIView.transition(with: card,
                                                                          duration: constants.cardFlipTransitionTime,
                                                                          options: .transitionFlipFromLeft,
                                                                          animations: {card.isFaceUp = true},
                                                                          completion: nil)
        })
        
    }
    
    // used for discard cards after matches
    private func discardPileAnimation(on card: SetCardView) {
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [], animations: { [weak self] in
            if self?.globalDiscardPoint != nil {
                card.transform = CGAffineTransform.identity
                card.frame.origin = self!.globalDiscardPoint!
            }
            if self?.globalCardSize != nil {
                card.frame.size = self!.globalCardSize!
            }
        }, completion: { finished in
            UIView.transition(with: card, duration: 0.5, options:.transitionFlipFromLeft, animations: {card.isFaceUp = false}, completion: { finished in
                card.removeFromSuperview()
            })
        })
    }
    
    private func determineBestSpacingBetweenCards(for width: CGFloat, and height: CGFloat, rows: Int, cols: Int) -> (CGFloat, CGFloat) {
        var horizontalSpacing = constants.minDistanceBetweenCards
        var verticalSpacing = constants.minDistanceBetweenCards
        let numberOfHorizontalSpaces = CGFloat(cols - 1)
        let numberOfHorizontalCards = CGFloat(cols)
        let numberOfVerticalSpaces = CGFloat(rows - 1)
        let numberOfVerticalCards = CGFloat(rows)
        
        // check horizontal spacing first
        if (width * numberOfHorizontalCards + numberOfHorizontalSpaces * horizontalSpacing < bounds.size.width){
            let remainingHorizontalSpace = bounds.size.width - (width * numberOfHorizontalCards)
            horizontalSpacing = remainingHorizontalSpace / numberOfHorizontalSpaces
        }
        // then check vertical scaling
        if (height * numberOfVerticalCards + numberOfVerticalSpaces * verticalSpacing < bounds.size.height){
            let remainingVerticalSpace = bounds.size.height - (height * numberOfVerticalCards)
            verticalSpacing = remainingVerticalSpace / numberOfVerticalSpaces
        }
        
        return (horizontalSpacing, verticalSpacing)
    }
    
    private func determineOptimalRowsColumnsWithExtraRowAdded () -> (Int, Int) {
        let boundsWidthHeightRatio = bounds.size.width / bounds.size.height
        let rowsPerColumn = Double(constants.cardWidthHeightRatio / boundsWidthHeightRatio)
        let numberOfCards = Double(currentCards.count)
        let columnsUnrounded = sqrt(numberOfCards / rowsPerColumn)
        var columns = columnsUnrounded.rounded()
        let rows = (numberOfCards / columnsUnrounded).rounded()
        
        while (columns * rows < Double(currentCards.count)){
            columns += 1
        }
        
        // [rows + 1] in order to always have extra row for deck/discard piles
        return(Int(rows + 1), Int(columns))
    }
    
    private func determineCardDimensions(rows: Int, columns: Int) -> (CGFloat, CGFloat) {
        
        // account for the minimum spacing between cards
        let effectiveWidth = bounds.size.width - (CGFloat(columns) - 1) * constants.minDistanceBetweenCards
        let effectiveHeight = bounds.size.height - (CGFloat(rows) - 1) * constants.minDistanceBetweenCards
        
        // first try sizing the cards based off of width
        let possibleCardWidth = effectiveWidth / CGFloat(columns)
        let possibleCardHeight = possibleCardWidth / constants.cardWidthHeightRatio
        if (possibleCardHeight * CGFloat(rows) <= effectiveHeight){
            return (possibleCardWidth, possibleCardHeight)
        }
        
        // Otherwise, we base the card size off the height
        let secondPossibleCardHeight = effectiveHeight / CGFloat(rows)
        let secondPossibleCardWidth = secondPossibleCardHeight * constants.cardWidthHeightRatio
        if (possibleCardWidth * CGFloat(columns) <= effectiveWidth){
            return (secondPossibleCardWidth, secondPossibleCardHeight)
        }
        else {
            assert(true, "SetCardGridView.determineCardDimensions: Invalid card size. We should never reach here")
            return(0, 0)
        }
    }
    
    private struct constants {
        static let cardWidthHeightRatio: CGFloat = 5 / 8
        static let minDistanceBetweenCards: CGFloat = 4
        
        // related to animation
        static let cardReorderAnimationTime: Double = 0.2
        static let cardDealAnimationTime: Double = 0.2
        static let cardFlipTransitionTime: Double = 0.2
    }
}
