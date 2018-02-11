//
//  Row.swift
//  WordyMcWordface
//
//  Created by Ed on 21/5/16.
//  Copyright © 2016 TootTootToot. All rights reserved.
//

import Foundation

import SpriteKit
import GameplayKit


struct RowCategory
{
    static let Words: UInt32 = 0
    static let ColoredDots: UInt32 = 1
}


class Row : SKSpriteNode
{
    var tiles : [TileSprite]
    var word: String
    var tileCount : Int
    var tilePositionSize: [Int]
    var solved : Bool
    var category : Int
    
    
    init(word: String, yPos: Int, category : Int)
    {
    
        self.tiles = Array()
        
        self.word = word
        self.tilePositionSize = Array()
        self.solved = false
        self.category = category
        
        let splitString : [String] = splitWord(word)
        
        var count = 0
        var orderCount = 0
        
        
        let j = Int(arc4random_uniform(UInt32(13)))
        
        var col = UIColor()
        
        if category == 0
        {
            switch j
            {
                case 0:
                    col = UIColor.black
                case 1:
                    col = UIColor.darkGray
                case 2:
                    col = UIColor.lightGray
                case 3:
                    col = UIColor.gray
                case 4:
                    col = UIColor.red
                case 5:
                    col = UIColor.green
                case 6:
                    col = UIColor.blue
                case 7:
                    col = UIColor.cyan
                case 8:
                    col = UIColor.yellow
                case 9:
                    col = UIColor.magenta
                case 10:
                    col = UIColor.orange
                case 11:
                    col = UIColor.purple
                case 12:
                    col = UIColor.brown
                default:
                    break
            }
        }
        else
        {
            col = UIColor.black
        }
        
        
        for tileChars in splitString
        {
            let t = TileSprite(positionOrder: count, order: orderCount, chars: tileChars, wordLength: word.count, y: 0, c: col, category: category)
            
            tiles.append(t)
            
            tilePositionSize.append(tileChars.count)
            
            count = count + tileChars.count
            
            orderCount = orderCount + 1
            
            print(t.positionOrder, t.order)
        }
        
        self.tileCount = splitString.count
        
        super.init(texture: nil, color:UIColor.clear,size: CGSize(width: rowWidth, height: 100))
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint(x: 375, y: yPos)
        self.zPosition = -5.0
        
        physicsBody = SKPhysicsBody(rectangleOf: self.size)
        physicsBody!.isDynamic = true
        physicsBody!.categoryBitMask = CollisionCategory.Tile
        physicsBody?.collisionBitMask = CollisionCategory.InvisibleRectangle | CollisionCategory.Tile
        physicsBody?.restitution = 0.35


        self.name = "row" + word
        
        for t in tiles
        {
            addChild(t)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



func splitWord(_ word: String) -> [String]
{
    let tileCount = word.count / 2

    let rand: Int = Int(arc4random_uniform(UInt32(tileCount)))
    
    let mod = word.count % 2

    var addon = 2;
    
    var returnArray : [String] = Array()

    var counter = 0

    //for var i = 0; i < tileCount * 2; i = i + addon
    
    for i in stride(from: 0, to: tileCount * 2, by: addon)
    {
        if counter == rand && mod == 1
        {
            addon = 3
        }
        else
        {
            addon = 2
        }

        let r = Range(word.index(word.startIndex, offsetBy: i) ..< word.index(word.startIndex, offsetBy: i + addon))
        
        print(word[r])
        
        returnArray.append(String(word[r]))
        
        counter = counter + 1
    }
    
    
    
    let r1 = Int(arc4random_uniform(UInt32(returnArray.count)))
    
    var r2 : Int
    
    repeat
    {
        r2 = Int(arc4random_uniform(UInt32(returnArray.count)))
    }
    while (r2 == r1)
    
  
    returnArray[r1] = String(returnArray[r1].reversed())
    returnArray[r2] = String(returnArray[r2].reversed())
    
    returnArray.shuffle()
    
    return returnArray
}

//
//
//func scramble(word: String) -> String {
//    var chars = Array(word.characters)
//    var result = ""
//
//    while chars.count > 0 {
//        let index = Int(arc4random_uniform(UInt32(chars.count - 1)))
//        chars[index].writeTo(&result)
//        chars.removeAtIndex(index)
//    }
//
//    return result
//}
//




extension Array
{
    mutating func shuffle()
    {
        if count < 2 { return }
        
        for i in 0..<(count - 1)
        {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            
            if (i != j)
            {
                self.swapAt(i, j)
            }
        }
    }
}
