//
//  SetCardView.swift
//  setGame
//
//  Created by Ryan Brazones on 9/13/18.
//  Copyright © 2018 greenred. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    
    enum withShape: String {
        case oval = "oval"
        case diamond = "diamond"
        case squiggle = "squiggle"
        static let allValues = [withShape.oval, .diamond, .squiggle]
    }
    
    enum withShade: String {
        case solid = "solid"
        case striped = "striped"
        case unfilled = "unfilled"
        static let allValues = [withShade.solid, .striped, .unfilled]
    }
    
    @IBInspectable
    var color: UIColor = UIColor.green { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var number: Int = 3 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var isSelected: Bool = false { didSet {setNeedsDisplay()}}
    
    @IBInspectable
    var cardBackgroundColor: UIColor = UIColor.white { didSet{ setNeedsDisplay() }}
    
    @IBInspectable
    var cardSelectOutlineColor: UIColor = UIColor.red { didSet{ setNeedsDisplay() }}
    
    @IBInspectable
    var isFaceUp: Bool = true { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var backsideColor: UIColor = #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
    
    var shape: withShape = .squiggle
    var shade: withShade = .striped
    
    override func draw(_ rect: CGRect) {
        
        // There will be situations where we want to draw more than 1 shape on a given
        // card. We are using addClip() to simplify the process of drawing the stripes
        // inside the shapes. Thus, it is necessary to save/restore the graphics context
        // so the addClip() calls from one shape do not interfere with the drawing of
        // the other shapes on the card.
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawCardBackground()
        
        if (!isFaceUp) { return }
        
        let pointsToDrawShapes = determinePointsToDrawShapes()
        for point in pointsToDrawShapes {
            context.saveGState()
            switch(shape){
            case .oval: drawOval(at: point)
            case .diamond: drawDiamond(at: point)
            case .squiggle: drawSquiggle(at: point)
            }
            context.restoreGState()
        }
    }
}

extension SetCardView {

    private func determinePointsToDrawShapes() -> [CGPoint] {
        var points = [CGPoint]()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        switch(number){
        case 1:
            points += [center]
        case 2:
            let upperPoint = center.offsetBy(dx: 0, dy: -(shapeHeight * constantValues.shapeHeightToSpacingRatio) / 2)
            let lowerPoint = center.offsetBy(dx: 0, dy: (shapeHeight * constantValues.shapeHeightToSpacingRatio) / 2)
            points += [upperPoint, lowerPoint]
        case 3:
            let upperPoint = center.offsetBy(dx: 0, dy: -shapeHeight * constantValues.shapeHeightToSpacingRatio)
            let lowerPoint = center.offsetBy(dx: 0, dy: shapeHeight * constantValues.shapeHeightToSpacingRatio)
            points += [lowerPoint, center, upperPoint]
        default: break
        }
        return points
    }
    
    private func drawTestRect(at point: CGPoint) {
        let test = UIBezierPath()
        let distanceToCenter = (shapeWidth / 2 - shapeHeight / 2)
        test.move(to: point.offsetBy(dx: -shapeWidth / 2, dy: shapeHeight / 2))
        test.addLine(to: test.currentPoint.offsetBy(dx: 0, dy: -shapeHeight))
        test.addLine(to: test.currentPoint.offsetBy(dx: shapeWidth, dy: 0))
        test.addLine(to: test.currentPoint.offsetBy(dx: 0, dy: shapeHeight))
        test.addLine(to: test.currentPoint.offsetBy(dx: -shapeWidth, dy: 0))
        test.move(to: point.offsetBy(dx: -shapeWidth / 2, dy: 0))
        test.addLine(to: test.currentPoint.offsetBy(dx: shapeWidth, dy: 0))
        test.move(to: point.offsetBy(dx: -distanceToCenter, dy: shapeHeight / 2))
        test.addLine(to: test.currentPoint.offsetBy(dx: 0, dy: -shapeHeight))
        test.move(to: point.offsetBy(dx: distanceToCenter, dy: shapeHeight / 2))
        test.addLine(to: test.currentPoint.offsetBy(dx: 0, dy: -shapeHeight))
        UIColor.black.setStroke()
        test.stroke()
    }
    
    private func drawCardBackground() {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: constantValues.cardCornerRadius)
        roundedRect.addClip()
        
        if isFaceUp {
            cardBackgroundColor.setFill()
            UIColor.white.setStroke()
        } else {
            backsideColor.setFill()
            UIColor.black.setStroke()
        }
        
        if (isSelected) {
            cardSelectOutlineColor.setStroke()
        }
        
        roundedRect.lineWidth = constantValues.cardSelectLineWidth
        roundedRect.fill()
        roundedRect.stroke()
    }
    
    private func drawDiamond(at point: CGPoint) {
        let diamondPath = UIBezierPath()
        diamondPath.move(to: point.offsetBy(dx: -shapeWidth / 2, dy: 0))
        diamondPath.addLine(to: point.offsetBy(dx: 0, dy: -shapeHeight / 2))
        diamondPath.addLine(to: point.offsetBy(dx: shapeWidth / 2, dy: 0))
        diamondPath.addLine(to: point.offsetBy(dx: 0, dy: shapeHeight / 2))
        diamondPath.addLine(to: point.offsetBy(dx: -shapeWidth / 2, dy: 0))
        color.setStroke()
        color.setFill()
        diamondPath.lineWidth = constantValues.shapeLineWidth
        diamondPath.addClip()
        diamondPath.stroke()
        if (shade == .unfilled) { return }
        else if (shade == .striped) { drawStripesInShape(at: point) }
        else if (shade == .solid) { diamondPath.fill() }
    }
    
    private func drawOval(at point: CGPoint) {
        let ovalPath = UIBezierPath()
        let distanceToCenter = (shapeWidth / 2 - shapeHeight / 2)
        let leftCenter = point.offsetBy(dx: -distanceToCenter, dy: 0)
        let rightCenter = point.offsetBy(dx: distanceToCenter, dy: 0)
        ovalPath.addArc(withCenter: leftCenter, radius: shapeHeight / 2, startAngle: CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        ovalPath.addLine(to: point.offsetBy(dx: distanceToCenter, dy: -shapeHeight / 2))
        ovalPath.addArc(withCenter: rightCenter, radius: shapeHeight / 2, startAngle: 3 * CGFloat.pi / 2, endAngle: CGFloat.pi / 2, clockwise: true)
        ovalPath.addLine(to: point.offsetBy(dx: -distanceToCenter, dy: shapeHeight / 2))
        color.setStroke()
        color.setFill()
        ovalPath.lineWidth = constantValues.shapeLineWidth
        ovalPath.addClip()
        ovalPath.stroke()
        if (shade == .unfilled) { return }
        else if (shade == .striped) { drawStripesInShape(at: point) }
        else if (shade == .solid) { ovalPath.fill() }
    }
    
    private func drawSquiggle(at point: CGPoint) {
        let squigglePath  = UIBezierPath()
        let distanceToCenter = (shapeWidth / 2 - shapeHeight / 2)
        let upperLeftCenter = point.offsetBy(dx: -distanceToCenter, dy: 0)
        let lowerRightCenter = point.offsetBy(dx: distanceToCenter, dy: 0)
        let unitX = shapeWidth / 8  // breaking down shape width into discrete units
        let unitY = shapeHeight / 4 // breaking down shape height into discrete units
        
        // upper left
        squigglePath.move(to: point.offsetBy(dx: -shapeWidth / 2, dy: 0))
        squigglePath.addArc(withCenter: upperLeftCenter, radius: shapeHeight / 2, startAngle: CGFloat.pi, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        
        // top middle
        var curveControlPoint1 = point.offsetBy(dx: 0, dy: -shapeHeight / 2)
        var curveControlPoint2 = point.offsetBy(dx: 0, dy: unitY)
        var endPoint = point.offsetBy(dx: 2 * unitX, dy: -unitY)
        squigglePath.addCurve(to: endPoint, controlPoint1: curveControlPoint1, controlPoint2: curveControlPoint2)
        
        curveControlPoint1 = point.offsetBy(dx: 2.5 * unitX, dy: -1.5 * unitY)
        curveControlPoint2 = point.offsetBy(dx: 2.5 * unitX, dy: -2 * unitY)
        endPoint = point.offsetBy(dx: 3 * unitX, dy: -2 * unitY)
        squigglePath.addCurve(to: endPoint, controlPoint1: curveControlPoint1, controlPoint2: curveControlPoint2)
        
        // upper right
        curveControlPoint1 = point.offsetBy(dx: 3.5 * unitX, dy: -2 * unitY)
        curveControlPoint2 = point.offsetBy(dx: 4 * unitX, dy: -unitY)
        endPoint = point.offsetBy(dx: shapeWidth / 2, dy: 0)
        squigglePath.addCurve(to: endPoint, controlPoint1: curveControlPoint1, controlPoint2: curveControlPoint2)
        
        // lower right (symmetric to upper left)
        squigglePath.addArc(withCenter: lowerRightCenter, radius: shapeHeight / 2, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        
        // lower middle
        curveControlPoint1 = point.offsetBy(dx: 0, dy: shapeHeight / 2)
        curveControlPoint2 = point.offsetBy(dx: 0, dy: -unitY)
        endPoint = point.offsetBy(dx: -2 * unitX, dy: unitY)
        squigglePath.addCurve(to: endPoint, controlPoint1: curveControlPoint1, controlPoint2: curveControlPoint2)
        
        curveControlPoint1 = point.offsetBy(dx: -2.5 * unitX, dy: 1.5 * unitY)
        curveControlPoint2 = point.offsetBy(dx: -2.5 * unitX, dy: 2 * unitY)
        endPoint = point.offsetBy(dx: -3 * unitX, dy: 2 * unitY)
        squigglePath.addCurve(to: endPoint, controlPoint1: curveControlPoint1, controlPoint2: curveControlPoint2)
        
        // lower left (symmertric to upper right)
        curveControlPoint1 = point.offsetBy(dx: -3.5 * unitX, dy: 2 * unitY)
        curveControlPoint2 = point.offsetBy(dx: -4 * unitX, dy: unitY)
        endPoint = point.offsetBy(dx: -shapeWidth / 2, dy: 0)
        squigglePath.addCurve(to: endPoint, controlPoint1: curveControlPoint1, controlPoint2: curveControlPoint2)
        
        color.setStroke()
        color.setFill()
        squigglePath.lineWidth = constantValues.shapeLineWidth
        squigglePath.addClip()
        squigglePath.stroke()
        if (shade == .unfilled) { return }
        else if (shade == .striped) { drawStripesInShape(at: point) }
        else if (shade == .solid) { squigglePath.fill() }
    }
    
    private func drawStripesInShape(at point: CGPoint) {
        let stripePath = UIBezierPath()
        let startPoint = point.offsetBy(dx: -shapeWidth / 2, dy: shapeHeight / 2)
        stripePath.move(to: startPoint)
        let distanceBetweenStripes = shapeWidth / constantValues.numberOfStripesToDraw
        var currentStripeOffset: CGFloat = 0
        var stripeCounter: Int = 0
        while (stripeCounter < Int(constantValues.numberOfStripesToDraw)) {
            stripePath.addLine(to: stripePath.currentPoint.offsetBy(dx: 0, dy: -shapeHeight))
            currentStripeOffset += distanceBetweenStripes
            stripePath.move(to: startPoint.offsetBy(dx: currentStripeOffset, dy: 0))
            stripeCounter += 1
        }
        stripePath.lineWidth = constantValues.stripeLineWidth
        color.setStroke()
        stripePath.stroke()
    }
    
    private struct constantValues {
        static let cardCornerRadius: CGFloat = 8.0
        static let cardSelectLineWidth: CGFloat = 7.5
        static let shapeLineWidth: CGFloat = 2.0
        static let numberOfStripesToDraw: CGFloat = 12.0
        static let stripeLineWidth: CGFloat = 1.0
        static let shapeHeightToSpacingRatio: CGFloat = 1.25
    }
    
    private var shapeHeight: CGFloat {
        return bounds.size.height / 4.5
    }
    
    private var shapeWidth: CGFloat {
        return bounds.size.width / 1.5
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
