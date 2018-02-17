//
//  GameScene.swift
//  WordyMcWordface
//
//  Created by Ed on 19/5/16.
//  Copyright (c) 2016 TootTootToot. All rights reserved.
//

import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let myFont : SSBitmapFont = GameScene.bitmapFontForFile("JointOutline64")
var myView : SKView = SKView()
var justDidAMove : Bool = false


struct CollisionCategory
{
  static let None: UInt32 = 0
  static let Tile: UInt32 = 1
  static let WorldBorder: UInt32 = 2
  static let Fruit: UInt32 = 4
  static let InvisibleRectangle: UInt32 = 8
  static let HammerBlastRadius: UInt32 = 16
  static let InvisibleRectangle2: UInt32 = 32
}



enum GameMode
{
    case speed20
    
    case levelProgression
    
    case quickPlay
    
    case deathMatch
}



enum TileTypes
{
    case words
    
    case coloredDots
    
    case monsters
}


var gameMode : GameMode = GameMode.quickPlay
var tileType : TileTypes = TileTypes.coloredDots





class GameScene: SKScene
{
    var tap = UITapGestureRecognizer()
    
    var swipeRight = UISwipeGestureRecognizer()
    
    var swipeLeft = UISwipeGestureRecognizer()
    
    var myRows : [Row?] = Array()
    
    var rootBGNode: SKSpriteNode?
    
    var scoreSpriteLabel = SSBitmapFontLabelNode()
    var timeSpriteLabel = SSBitmapFontLabelNode()
    var scoreBarBorder = SKSpriteNode()
    var scoreBarClock = SKSpriteNode()
    var countdownTimer = 60
    
    
    override func didMove(to view: SKView)
    {

        rootBGNode = SKSpriteNode(color: UIColor.red, size: CGSize.zero)//(width: self.frame.size.width * 2, height: self.frame.size.height * 2))
        rootBGNode!.position = CGPoint(x: self.size.width , y: self.size.height / 2)
        rootBGNode!.zPosition = -10
        addChild(rootBGNode!)
    
        let mushroomBG = SKSpriteNode(imageNamed: "mushrooms_background")
        mushroomBG.position = CGPoint(x: -375, y: 667)
        mushroomBG.size = CGSize(width: 790, height: 2668)
        mushroomBG.zPosition = rootBGNode!.zPosition + 0.1
            
        let dust1 = SKEmitterNode(fileNamed: "MyParticleSnow1")
        dust1!.particleScale = 0.01
        dust1!.position = CGPoint(x: -300, y: 1000)
        dust1!.zPosition = mushroomBG.zPosition + 20
        dust1?.resetSimulation()
        dust1?.advanceSimulationTime(10.0)
        mushroomBG.addChild(dust1!)
        
        let dust2 = SKEmitterNode(fileNamed: "MyParticleSnow1")
        dust2!.particleScale = 0.005
        dust2!.position = CGPoint(x: -60, y: 250)
        dust2!.zPosition = mushroomBG.zPosition + 20
        dust2?.resetSimulation()
        dust2?.advanceSimulationTime(10.0)
        mushroomBG.addChild(dust2!)
        
        let dust3 = SKEmitterNode(fileNamed: "MyParticleSnow1")
        dust3!.particleScale = 0.0075
        dust3!.position = CGPoint(x: 350, y: 600)
        dust3!.zPosition = mushroomBG.zPosition + 20
        dust3?.resetSimulation()
        dust3?.advanceSimulationTime(10.0)
        mushroomBG.addChild(dust3!)
    
        rootBGNode!.addChild(mushroomBG)
        
        let time: Double = 60
        let actionScroll = SKAction.moveBy(x: 0, y: -1334, duration: time)
        let actionReverseScroll = SKAction.moveBy(x: 0, y: 1334, duration: time)
        let actionBoth = SKAction.sequence([actionScroll, actionReverseScroll])
    
        rootBGNode!.run(SKAction.repeatForever(actionBoth))

    
    
        let invisibleRect = SKSpriteNode(color: SKColor.clear, size: CGSize(width: self.frame.width, height: 25))
        invisibleRect.position = CGPoint(x: 375, y: 50)
        invisibleRect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 25))
        invisibleRect.physicsBody?.categoryBitMask = CollisionCategory.InvisibleRectangle
        invisibleRect.zPosition = 8
        invisibleRect.physicsBody?.isDynamic = false
        invisibleRect.physicsBody?.angularDamping = 0
        invisibleRect.physicsBody?.linearDamping = 0
        invisibleRect.physicsBody?.friction = 0
        
        addChild(invisibleRect)


        let invisibleRectLeft = SKSpriteNode(color: SKColor.green, size: CGSize(width: 25, height: self.frame.height))
        invisibleRectLeft.position = CGPoint(x: 12.5, y: 667)
        invisibleRectLeft.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 25, height: self.frame.height))
        invisibleRectLeft.physicsBody?.categoryBitMask = CollisionCategory.InvisibleRectangle
        invisibleRectLeft.zPosition = 8
        invisibleRectLeft.physicsBody?.isDynamic = false
        invisibleRectLeft.physicsBody?.angularDamping = 0
        invisibleRectLeft.physicsBody?.linearDamping = 0
        invisibleRectLeft.physicsBody?.friction = 0
        
        addChild(invisibleRectLeft)
        
        
        
        let invisibleRectRight = SKSpriteNode(color: SKColor.green, size: CGSize(width: 25, height: self.frame.height))
        invisibleRectRight.position = CGPoint(x: 737.5, y: 667)
        invisibleRectRight.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 25, height: self.frame.height))
        invisibleRectRight.physicsBody?.categoryBitMask = CollisionCategory.InvisibleRectangle
        invisibleRectRight.zPosition = 8
        invisibleRectRight.physicsBody?.isDynamic = false
        invisibleRectRight.physicsBody?.angularDamping = 0
        invisibleRectRight.physicsBody?.linearDamping = 0
        invisibleRectRight.physicsBody?.friction = 0
        
        addChild(invisibleRectRight)
 
        setupGestureHandlers()
        
        myView = self.view!


        let _filename = "Level_1"
        
        var theLevel = Level(filename: _filename)

    
        for i in 0 ..< theLevel.words.count
        {
            let delayAction = SKAction.wait(forDuration: Double(i) * 5)
        
            let row = Row(word: theLevel.words[i].word, yPos: 1334, category: theLevel.words[i].category)
        
            self.myRows.append(row)
        
            run(delayAction, completion:
            {
                [unowned self] in
                
                self.addChild(row)
            })
        }

     /*
        for  i in 4 ... 9
        {
            let offset = rowWidth / i
            
            for j in 0 ... i
            {
                var circle = SKShapeNode(circleOfRadius: 3.0)
                circle.position = CGPoint(x: rowWidth / 4 + (offset / 2) + offset * j, y: 100 + (i - 3) * 200)
                circle.fillColor = UIColor.green
                circle.zPosition = -10
                addChild(circle)
            }
       }
        */
        
        let scoreBarBacking = SKSpriteNode(imageNamed: "ScorebarBackground skin")
        scoreBarBacking.position = CGPoint(x: 375, y: 1400)
        scoreBarBacking.zPosition = 1
        scoreBarBacking.size = CGSize(width: 750, height: 110)
        addChild(scoreBarBacking)
        
  
        
        scoreBarBorder = SKSpriteNode(imageNamed: "ScoreBarborder")
        scoreBarBorder.position = CGPoint(x: 0, y: 0)
        scoreBarBorder.zPosition = scoreBarBacking.zPosition + 0.1
        scoreBarBorder.size = CGSize(width: 750, height: 110)
        scoreBarBacking.addChild(scoreBarBorder)
        
        scoreBarClock = SKSpriteNode(imageNamed: "clock outline")
        scoreBarClock.position = CGPoint(x: 0, y: 0)
        scoreBarClock.zPosition = scoreBarBorder.zPosition + 0.1
        scoreBarClock.size = CGSize(width: 92 * 1.1, height: 105 * 1.1)
        scoreBarBorder.addChild(scoreBarClock)
        
   //     scoreBarClock.physicsBody = SKPhysicsBody(circleOfRadius: 1)
   //     scoreBarClock.physicsBody?.collisionBitMask = 0
   //     scoreBarClock.physicsBody?.dynamic = false
        
        let startPoint = scoreBarBacking.position
            
        let endPoint = CGPoint(x: 375, y: 1334 - 55)
        
        var moveEffect: SKTMoveEffect? = SKTMoveEffect(node: scoreBarBacking, duration: 1.0, startPosition: startPoint, endPosition: endPoint)

        moveEffect!.timingFunction = SKTTimingFunctionBounceEaseOut

        scoreBarBacking.run(SKAction.actionWithEffect(moveEffect!), completion:
        {
            moveEffect = nil
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
    }
    
   
    var sixtythsTicker = 0
    var secondsTicker = 0
    var clockRunning: Bool = true

   
   
    override func update(_ currentTime: TimeInterval)
    {
        if clockRunning == true
        {
            sixtythsTicker += 1
        }
    
        if sixtythsTicker == 60
        {
            sixtythsTicker = 0
            
            secondsTicker += 1
            
            
            countdownTimer -= 1
            
            if countdownTimer == 0
            {
                countdownTimer = 60
            }
            
            updateHUD()
        }
        
        
        if justDidAMove == false
        {
            return
        }
        
        justDidAMove = false
        
        
        var sumString = ""
        
        for myRow in myRows
        {
            if myRow?.solved == true
            {
                continue
            }
            
            
            if myRow?.category == 1   // the category for words
            {
                sumString = ""
                
                for tile in myRow!.tiles
                {
                    sumString += tile.chars
                }

                
                if sumString == myRow?.word
                {
                    let foundSound = SKAction.playSoundFileNamed("Gold Shine", waitForCompletion: false)
                        
                    run(foundSound)
               
                    myRow?.solved = true
                    
                    myRow?.removeFromParent()
                    
                    
                    if let index = myRows.index(where: {$0 == myRow})
                    {
                        myRows.remove(at: index)
                    }
                }
            }
            else //if myRow?.category == 1   // Dots?
            {
                var mismatch : Bool = false
            
            
                //for var i = 0; i < myRow!.tileCount - 1; i = i + 1
                for i in 0 ... myRow!.tileCount - 2
                {
                    
                    print("=========")
                    print(i)
                    print(String(describing: myRow?.tiles[i]))
                    let tileA = myRow?.tiles[i].chars  // all this fucking crap just to get the character. Fuck Swift and its string handling
                    
                    let tileARightmostIndex = tileA?.index((tileA?.endIndex)!, offsetBy: -1)
                    
                    let tileAChar = tileA![tileARightmostIndex!]
                    
                    print("A Left ")
                    print(tileAChar)
                    
                    //let letterTileARight = myRow?.tiles[i].chars[myRow!.tiles[i].chars.index(myRow!.tiles[i].chars.endIndex, offsetBy: -1)]
                    
                    
                    let tileB = myRow?.tiles[i + 1].chars
                    
                    let tileBLeftmostIndex = tileB?.index((tileB?.startIndex)!, offsetBy: 0)
                    
                    let tileBChar = tileB![tileBLeftmostIndex!]
                    
                    print ("B right" )
                    print(tileBChar)
                    //let letterTileBLeft = myRow?.tiles[i + 1].chars[myRow!.tiles[i + 1].chars.index(myRow!.tiles[i + 1].chars.startIndex, offsetBy: 0)]
      
                    if tileAChar != tileBChar
                    {
                        mismatch = true
                        
                        break
                    }
                }
                
                
                if mismatch == false
                {
                    let foundSound = SKAction.playSoundFileNamed("Gold Shine", waitForCompletion: false)
                        
                    run(foundSound)
               
                    myRow?.solved = true
                    
                    myRow?.removeFromParent()
                    
                    
                    if let index = myRows.index(where: {$0 == myRow})
                    {
                        myRows.remove(at: index)
                    }
                }
            }
        }
    }
    
    
    
    func setupGestureHandlers()
    {
        tap = UITapGestureRecognizer(target: self, action: #selector(GameScene.handleTaps(_:)))
        view!.addGestureRecognizer(tap)
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipes(_:)) )
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(swipeRight)
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipes(_:)) )
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(swipeLeft)
    }
    
 
 
    func updateHUD()
    {
        scoreSpriteLabel.removeFromParent()
                
        scoreSpriteLabel = myFont.node(from: String(format: "%08d", 10))
        scoreSpriteLabel.position = CGPoint(x: -160, y: 0)
        scoreSpriteLabel.xScale = 0.6
        scoreSpriteLabel.yScale = 0.6
        scoreSpriteLabel.zPosition = scoreBarBorder.zPosition + 0.1
        scoreBarBorder.addChild(scoreSpriteLabel)
        
        timeSpriteLabel.removeFromParent()
        
       
        timeSpriteLabel = myFont.node(from: ("\(countdownTimer)"))
        
        timeSpriteLabel.position = CGPoint(x: 0, y: -4)
        timeSpriteLabel.xScale = 1.0
        timeSpriteLabel.yScale = 1.0
        timeSpriteLabel.zPosition =  scoreBarClock.zPosition + 1
        scoreBarClock.addChild(timeSpriteLabel)
        
    }
    
    
    
    static func bitmapFontForFile(_ filename: String) -> SSBitmapFont
    {
        let path = Bundle.main.path(forResource: filename, ofType: "skf")!
        
        let url = URL(fileURLWithPath: path)
        
        var bitmapFont: SSBitmapFont = SSBitmapFont()
        
        do
        {
            bitmapFont = try SSBitmapFont(file: url)
        }
        catch
        {
            print("error")
        }
        
        return bitmapFont
    }
    
    
    
    var selectedRow : Row?
    
    @objc func handleTaps(_ sender:UITapGestureRecognizer)
    {
        let UIpoint: CGPoint = sender.location(ofTouch: 0, in: nil)
        
        let location = self.view?.convert(UIpoint, to: self)

        let nodes = self.nodes(at: location!)


        for node in nodes
        {
            if node.name?.contains("row") == true
            {
                selectedRow = node as? Row
            }
        }
        
        if selectedRow != nil && selectedRow!.solved == true
        {
            let notAdjacentSound = SKAction.playSoundFileNamed("Sfx 11", waitForCompletion: false)
                
            run(notAdjacentSound)
            
            return
        }
        
        for node in nodes
        {
            if node.name?.contains("tile") == true
            {
                let n : TileSprite = node as! TileSprite
                
                print("tile ", n)
                
                n.rotateLeft()
            }
        }
    }
    
    
    @objc func handleSwipes(_ gesture: UISwipeGestureRecognizer)
    {
        if somethingIsMoving == true
        {
            return
        }
    
    
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            var point = gesture.location(in: self.view)
            
            point.x = point.x * 2  // because nobody understands how the fuck convertPoint() works
            point.y = 1334 - (point.y * 2)
            
            
            let nodes = self.nodes(at: point)
            
            var selectedRow : Row?
            
            var selectedTile : TileSprite?
            
            var tileToSwapWith : TileSprite?
        
        
            for node in nodes
            {
                if node.name?.contains("row") == true
                {
                    selectedRow = node as? Row
                }
                
                if node.name?.contains("tile") == true
                {
                    selectedTile = node as? TileSprite
                }
            }
        
        
            if selectedRow == nil || selectedTile == nil
            {
                return
            }
        
        
            var p0 : CGPoint = CGPoint.zero
            var p1 : CGPoint = CGPoint.zero
        
            switch swipeGesture.direction
            {
                case UISwipeGestureRecognizerDirection.right:
                
                    if selectedTile?.order < (selectedRow?.tiles.count)! - 1
                    {
                        tileToSwapWith = selectedRow?.tiles[selectedTile!.order + 1]
                    }
                    else
                    {
                        return
                    }
                
                case UISwipeGestureRecognizerDirection.left:
                
                    if selectedTile?.order > 0
                    {
                        tileToSwapWith = selectedRow?.tiles[selectedTile!.order - 1]
                    }
                    else
                    {
                        return
                    }
              
                default:
                    break
            }
            
            if selectedTile!.positionOrder > tileToSwapWith!.positionOrder
            {
                let temp = tileToSwapWith!
                tileToSwapWith! = selectedTile!
                selectedTile! = temp
            }
            
            
        
            let selectedSound = SKAction.playSoundFileNamed("Sfx 04", waitForCompletion: false)
                
            run(selectedSound)
            
            somethingIsMoving = true
                                    
            let oldOrder0 = selectedTile!.order
            let oldOrder1 = tileToSwapWith!.order
            
            if selectedTile!.numChars == tileToSwapWith!.numChars
            {
                let temp  = selectedTile!.positionOrder
                selectedTile!.positionOrder = tileToSwapWith!.positionOrder
                tileToSwapWith!.positionOrder = temp
                
                p0 = tileToSwapWith!.position
                p1 = selectedTile!.position
            }
            
            if selectedTile!.numChars == 2 && tileToSwapWith!.numChars == 3
            {
                let temp  = selectedTile!.positionOrder
                selectedTile!.positionOrder = tileToSwapWith!.positionOrder + 1
                tileToSwapWith!.positionOrder = temp
                
                p0.x = CGFloat(-rowWidth) / 2 + CGFloat(selectedTile!.tileOffset) * CGFloat(selectedTile!.positionOrder + 1)
                p1.x = CGFloat(-rowWidth) / 2 + CGFloat(tileToSwapWith!.tileOffset) * CGFloat(tileToSwapWith!.positionOrder + 1) + CGFloat(tileToSwapWith!.tileOffset / 2)
            }
            
            if selectedTile!.numChars == 3 && tileToSwapWith!.numChars == 2
            {
                let temp  = selectedTile!.positionOrder
                selectedTile!.positionOrder = tileToSwapWith!.positionOrder - 1
                tileToSwapWith!.positionOrder = temp
                
                p0.x = CGFloat(-rowWidth) / 2 + CGFloat(selectedTile!.tileOffset) * CGFloat(selectedTile!.positionOrder + 1) + CGFloat(tileToSwapWith!.tileOffset / 2) // how much to move the 3
                p1.x = CGFloat(-rowWidth) / 2 + CGFloat(tileToSwapWith!.tileOffset) * CGFloat(tileToSwapWith!.positionOrder + 1) //- CGFloat(tilesTouched[1].tileOffset)
            }
            
            let actionP0 = SKAction.move(to: p0, duration: 0.25)
            let actionP1 = SKAction.move(to: p1, duration: 0.25)
            
            let scaleP0Down = SKAction.scale(to: 0.75, duration: 0.125)
            scaleP0Down.timingMode = .easeOut
            let scaleP0Up = SKAction.scale(to: 1.0, duration: 0.125)
            scaleP0Up.timingMode = .easeIn
            let scaleP0 = SKAction.sequence([scaleP0Down, scaleP0Up])
            
            let scaleP1Up = SKAction.scale(to: 1.25, duration: 0.125)
            scaleP1Up.timingMode = .easeOut
            let scaleP1Down = SKAction.scale(to: 1.0, duration: 0.125)
            scaleP1Down.timingMode = .easeIn
            let scaleP1 = SKAction.sequence([scaleP1Up, scaleP1Down])
            
            let transformP0 = SKAction.group([actionP0, scaleP0])
            let transformP1 = SKAction.group([actionP1, scaleP1])
            
            selectedTile!.zPosition = -1
            tileToSwapWith!.zPosition = 1
  
  
        
            selectedTile!.run(transformP0, completion:
            {
                justDidAMove = true
            })
            
            tileToSwapWith!.run(transformP1, completion:
            {
               justDidAMove = true
               somethingIsMoving = false
            })
            
     //       var tempTile = tileToSwapWith
            selectedRow!.tiles[oldOrder0] = tileToSwapWith!
            selectedRow!.tiles[oldOrder1] = selectedTile!
            
            selectedRow!.tiles[oldOrder0].order = oldOrder0
            selectedRow!.tiles[oldOrder1].order = oldOrder1
        }
    }
}



