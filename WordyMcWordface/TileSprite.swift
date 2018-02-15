//
//  TileSprite.swift
//  WordyMcWordface
//
//  Created by Ed on 19/5/16.
//  Copyright © 2016 TootTootToot. All rights reserved.
//

import Foundation
import SpriteKit


var somethingIsMoving : Bool = false
var rowWidth = 650


class TileSprite : SKSpriteNode
{
    var letters : [SSBitmapFontLabelNode] = Array()
    var positionOrder : Int = 0
    var order : Int = 0
    var tileOffset : Int = 0
    var numChars : Int = 0
    var chars: String = ""
 //   var letterA : SSBitmapFontLabelNode
  //  var letterB : SSBitmapFontLabelNode
    
    init(positionOrder: Int, order: Int, chars: String, wordLength: Int, y: Int, c: UIColor, category: Int)
    {
        let offset = rowWidth / wordLength
        
        super.init(texture: nil, color:UIColor.white, size: CGSize(width: CGFloat(offset * chars.count), height: 80))
        
        self.chars = chars
        self.zPosition = 0.0
        self.positionOrder = positionOrder
        self.order = order
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.tileOffset = offset
        self.numChars = chars.count
        
        
        let letterScale : CGFloat = 1.0 - ((1.0 / CGFloat(wordLength) * 3.0))
        
        if numChars == 2
        {
            self.position = CGPoint(x: -rowWidth / 2 + (offset * positionOrder) + offset, y: y)

            let container = SKShapeNode(rect: CGRect(x: 0, y: 0, width: CGFloat(offset * chars.count), height: 80), cornerRadius: 35)
            
            container.fillColor = c
            container.lineWidth = 3.0
            container.strokeColor = UIColor.white
            container.zPosition = self.zPosition + 0.1
            container.alpha = 0.75
            
            let tex = myView.texture(from: container)
            self.texture = tex
            
            var letterA = SSBitmapFontLabelNode()
            let letterAString = String(chars[chars.startIndex])
            letterA = myFont.node(from: letterAString)
            letterA.position = CGPoint(x: -offset / 2, y: 0)
            letterA.xScale = letterScale
            letterA.yScale = letterScale
            letterA.zPosition = container.zPosition + 0.1
            letterA.verticalAlignmentMode = SSBMFLabelVerticalAlignmentMode.center
            
            
            if category == 0
            {
                addDot(letterA.position, letter: letterAString, z: container.zPosition + 0.5)
            }
            
            letters.append(letterA)
            
            var letterB = SSBitmapFontLabelNode()

            let letterBString = String(chars[chars.index(after: chars.startIndex)])
            letterB = myFont.node(from: letterBString)
            letterB.position = CGPoint(x: offset / 2, y:0)
            letterB.xScale = letterScale
            letterB.yScale = letterScale
            letterB.zPosition = container.zPosition + 0.1
            letterB.verticalAlignmentMode = SSBMFLabelVerticalAlignmentMode.center
            
            
            if category == 0
            {
                addDot(letterB.position, letter: letterBString, z: container.zPosition + 0.5)
            }
            
            letters.append(letterB)
            
           
            if category == 1
            {
                letterA.alpha = 1
                letterB.alpha = 1
                
                addChild(letterA)
                addChild(letterB)
            }
        }
        else if numChars == 3
        {
            let x = -rowWidth / 2 + offset * (positionOrder + 1) + offset / 2
            self.position = CGPoint(x: x, y: y)

            let container = SKShapeNode(rect: CGRect(x: 0, y: 0, width: CGFloat(offset * chars.count), height: 80), cornerRadius: 35)
            container.fillColor = c
            container.lineWidth = 3.0
            container.strokeColor = UIColor.white
            container.zPosition = self.zPosition + 0.1
            container.alpha = 0.75
            
            let tex = myView.texture(from: container)
            self.texture = tex
            
            var letterA = SSBitmapFontLabelNode()
            let letterAString = String(chars[chars.startIndex])
            letterA = myFont.node(from: letterAString)
            letterA.position = CGPoint(x: -offset , y: 0)
            letterA.xScale = letterScale
            letterA.yScale = letterScale
            letterA.zPosition = container.zPosition + 0.1
            letterA.verticalAlignmentMode = SSBMFLabelVerticalAlignmentMode.center
            
            letters.append(letterA)
            
            if category == 0
            {
                addDot(letterA.position, letter: letterAString, z: container.zPosition + 0.5)
            }
            
            var letterB = SSBitmapFontLabelNode()
            let letterBString = String(chars[chars.index(after: chars.startIndex)])
            letterB = myFont.node(from: letterBString)
            letterB.position = CGPoint(x: 0, y:0)
            letterB.xScale = letterScale
            letterB.yScale = letterScale
            letterB.zPosition = container.zPosition + 0.1
            letterB.verticalAlignmentMode = SSBMFLabelVerticalAlignmentMode.center
            
            letters.append(letterB)
            
            if category == 0
            {
                addDot(letterB.position, letter: letterBString, z: container.zPosition + 0.5)
            }
            
            
            var letterC = SSBitmapFontLabelNode()
            let letterCString = String(chars[chars.index(before: chars.endIndex)])
            letterC = myFont.node(from: letterCString)
            letterC.position = CGPoint(x: offset, y:0)
            letterC.xScale = letterScale
            letterC.yScale = letterScale
            letterC.zPosition = container.zPosition + 0.1
            letterC.verticalAlignmentMode = SSBMFLabelVerticalAlignmentMode.center
            
            letters.append(letterC)
            
            if category == 0
            {
                addDot(letterC.position, letter: letterCString, z: container.zPosition + 0.5)
            }
            
            if category == 1
            {
                letterA.alpha = 1
                letterB.alpha = 1
                letterC.alpha = 1
                
                addChild(letterA)
                addChild(letterB)
                addChild(letterC)
            }
            
        }
        
        self.name = "tile" + chars
        
    }


    func addDot(_ position: CGPoint, letter: String, z: CGFloat)
    {
        let dot = SKShapeNode(circleOfRadius: 20)
        dot.position = position
        dot.fillColor = selectColor(letter)
        dot.strokeColor = UIColor.white
        dot.lineWidth = 3.0
        dot.zPosition = z
        
        addChild(dot)
    }
    
    
    
    func selectColor(_ letter: String) -> UIColor
    {
        var col = UIColor()

        switch letter
        {
            case "0":
                col = UIColor.red
            case "1":
                col = UIColor.blue
            case "2":
                col = UIColor.yellow
            case "3":
                col = UIColor.purple
            case "4":
                col = UIColor.orange
            case "5":
                col = UIColor.green
            default:
                break
        }
        
        return col
    }
    

    required init?(coder aDecoder: NSCoder)
    {
        
        
        super.init(texture: nil, color:UIColor.white,size: CGSize(width: 64, height: 64))
    }
    
    
    func rotateLeft()
    {
        if somethingIsMoving == true
        {
            return
        }
        
        somethingIsMoving = true
        
        let rotateAction = SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.25)
        
        self.zPosition += 2.0
        
        self.run(rotateAction, completion:
        {
            self.zPosition -= 2.0
        })
        
        let rotateAntiAction = SKAction.reversed(rotateAction)
        
        let selectedSound = SKAction.playSoundFileNamed("coin_collect", waitForCompletion: false)
                
        run(selectedSound)
        
        for letter in letters
        {
            letter.zPosition += 2.0
        
            letter.run(rotateAntiAction(), completion:
            {
                somethingIsMoving = false
                
                justDidAMove = true
                
                letter.zPosition -= 2.0
            })
        }
        
  
        chars = String(chars.reversed())
    }
    
    
    func rotateRight()
    {
    }
    
    
    
    
}

