//
//  GameScene.swift
//  EggConveyor
//
//  Created by Kazuyuki Tanimura on 7/22/14.
//  Copyright (c) 2014 Kazuyuki Tanimura. All rights reserved.
//

import SpriteKit

enum GameState {
    case first, play, end
}

class MySpriteNode: SKSpriteNode {
    // http://stackoverflow.com/questions/25126295/swift-class-does-not-implement-its-superclasss-required-members
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    var _parent: GameScene!
    init(parent: GameScene, image: String) {
        let texture = SKTexture(imageNamed: image)
        let color = UIColor()
        super.init(texture: texture, color: color, size: texture.size())
        self._parent = parent
    }

    func show() {
        self.removeFromParent()
        _parent.addChild(self)
    }

    func hide() {
        self.removeFromParent()
    }
}

class Life: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    // class variable is not avaialble yet...
    //class var _lifeCount:Int = 0
    //class var _lifes = [Life]()

    init(parent: GameScene) {
        super.init(parent: parent, image: "egg_01")
        self.setScale(0.3)
        //_lifes.append(self)
    }
/*
    class func showAll() {
        for life in lifes {
            life.show()
        }
    }
*/
}

class GameScene: SKScene {
    // It seems 576 is the real height as opposed to 640 for iPhone5s
    let screenHeight:CGFloat = 576.0
    var henL:SKSpriteNode!
    var henR:SKSpriteNode!
    var centerX:CGFloat!
    var centerY:CGFloat!
    var step1Y:CGFloat!
    var step2Y:CGFloat!
    var step3Y:CGFloat!
    var step4Y:CGFloat!
    var step5Y:CGFloat!
    var step6Y:CGFloat!
    var message:SKLabelNode!
    var score:Int = 0
    var scoreLabel:SKLabelNode!
    var lifeCount:Int = 0
    let maxLifes:Int = 3
    var lifes = [Life]()
    var gameState:GameState!
    var tickLengthMillis = NSTimeInterval(500)
    var lastTick:NSDate?

    override func didMoveToView(view: SKView) {
        centerX = CGRectGetMidX(self.frame)
        centerY = CGRectGetMidY(self.frame)
        let ground = centerY - screenHeight * 0.5

        // background
        let backGround = SKSpriteNode(imageNamed: "background")
        self.addChild(backGround)
        backGround.position = CGPoint(x:centerX, y:centerY)

        // tower
        let tower = SKSpriteNode(imageNamed: "tower")
        tower.setScale(screenHeight / tower.size.height)
        tower.position = CGPoint(x:centerX, y:centerY - 10.0)
        self.addChild(tower)

        // step
        let step1 = SKSpriteNode(imageNamed: "steel_01")
        let step2 = SKSpriteNode(imageNamed: "steel_02")
        let step3 = SKSpriteNode(imageNamed: "steel_03")
        let step4 = SKSpriteNode(imageNamed: "steel_04")
        let step5 = SKSpriteNode(imageNamed: "steel_05")
        let step6 = SKSpriteNode(imageNamed: "steel_07")
        let stepScale:CGFloat = 0.2
        step1.setScale(stepScale)
        step2.setScale(stepScale)
        step3.setScale(stepScale)
        step4.setScale(stepScale)
        step5.setScale(stepScale)
        step6.setScale(stepScale)
        step1Y = self.frame.size.height * 0.15
        step2Y = self.frame.size.height * 0.45
        step3Y = self.frame.size.height * 0.75
        step4Y = self.frame.size.height * 0.00
        step5Y = self.frame.size.height * 0.30
        step6Y = self.frame.size.height * 0.60
        step1.position = CGPoint(x:centerX * 0.4, y:step1Y)
        step2.position = CGPoint(x:centerX * 0.4, y:step2Y)
        step3.position = CGPoint(x:centerX * 0.4, y:step3Y)
        step4.position = CGPoint(x:centerX * 1.6, y:step4Y)
        step5.position = CGPoint(x:centerX * 1.6, y:step5Y)
        step6.position = CGPoint(x:centerX * 1.6, y:step6Y)
        self.addChild(step1)
        self.addChild(step2)
        self.addChild(step3)
        self.addChild(step4)
        self.addChild(step5)
        self.addChild(step6)

        // conveyor
        let conveyor1 = SKTexture(imageNamed: "conveyor_01")
        let conveyor2 = SKTexture(imageNamed: "conveyor_02")
        let conveyor3 = SKTexture(imageNamed: "conveyor_03")
        let anim = SKAction.animateWithTextures([conveyor1, conveyor2, conveyor3], timePerFrame: 0.2)
        let convey = SKAction.repeatActionForever(anim)
        var conveyor = SKSpriteNode(texture: conveyor1)
        let conveyorScale:CGFloat = 0.4
        conveyor.xScale = conveyorScale
        conveyor.yScale = -conveyorScale
        conveyor.runAction(convey)
        conveyor.position = CGPoint(x:centerX * 2.2, y:self.frame.size.height * 0.15)
        self.addChild(conveyor)
        for (var i:Int = 0; i < 5; i++) {
            conveyor = conveyor.copy() as SKSpriteNode
            if ((i & 0b01) == 0b01) {
                flip(conveyor)
            }
            conveyor.position = CGPoint(x:centerX, y:self.frame.size.height * 0.15 * CGFloat(i + 1))
            self.addChild(conveyor)
        }

        // truck
        let truck = SKSpriteNode(imageNamed: "truck_01")
        let truckScale:CGFloat = 0.3
        truck.setScale(truckScale)
        truck.anchorPoint = CGPointMake(0.5, 0.0)
        truck.position = CGPoint(x:truck.size.width * 0.5, y:ground)
        self.addChild(truck)
        let gas = SKSpriteNode(imageNamed: "truck_02")
        gas.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeOutWithDuration(1.0), SKAction.fadeInWithDuration(1.0)])))
        gas.setScale(truckScale)
        gas.anchorPoint = CGPointMake(0.5, 0.0)
        gas.position = CGPoint(x:truck.size.width + gas.size.width * 0.5 - 1.0, y:ground + 2.0)
        self.addChild(gas)

        // hen
        henL = SKSpriteNode(imageNamed: "hen_01") // left hen
        henR = SKSpriteNode(imageNamed: "hen_01") // right hen
        let henScale:CGFloat = 0.4
        henL.setScale(henScale)
        henR.setScale(henScale)
        henL.anchorPoint = CGPointMake(0.5, 0.0)
        henR.anchorPoint = CGPointMake(0.5, 0.0)
        henL.position = CGPoint(x:centerX * 0.4, y:self.frame.size.height * 0.15)
        henR.position = CGPoint(x:centerX * 1.6, y:self.frame.size.height * 0.30)
        flip(henL)
        self.addChild(henL)
        self.addChild(henR)

        // egg
        let egg2 = SKSpriteNode(imageNamed: "egg_02")
        let egg3 = SKSpriteNode(imageNamed: "egg_03")
        let egg4 = SKSpriteNode(imageNamed: "egg_04")
        let egg5 = SKSpriteNode(imageNamed: "egg_05")
        let egg6 = SKSpriteNode(imageNamed: "egg_06")
        let egg7 = SKSpriteNode(imageNamed: "egg_07")
        let egg8 = SKSpriteNode(imageNamed: "egg_08")
        let eggScale:CGFloat = 0.2
        egg2.setScale(eggScale)
        egg3.setScale(eggScale)
        egg4.setScale(eggScale)
        egg5.setScale(eggScale)
        egg6.setScale(eggScale)
        egg7.setScale(eggScale)
        egg8.setScale(eggScale)
        egg2.position = CGPoint(x:centerX, y:210)
        egg3.position = CGPoint(x:centerX, y:280)
        egg4.position = CGPoint(x:centerX, y:350)
        egg5.position = CGPoint(x:centerX, y:420)
        egg6.position = CGPoint(x:centerX, y:490)
        egg7.position = CGPoint(x:centerX, y:560)
        egg8.position = CGPoint(x:centerX, y:630)
        self.addChild(egg2)
        self.addChild(egg3)
        self.addChild(egg4)
        self.addChild(egg5)
        self.addChild(egg6)
        self.addChild(egg7)
        self.addChild(egg8)

        // message
        message = SKLabelNode(fontNamed:"Chalkduster")
        message.fontSize = 65
        message.position = CGPoint(x:centerX, y:centerY)

        // score
        scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
        setScore(score)
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x:centerX * 2.0 - scoreLabel.frame.size.width, y:screenHeight + ground - scoreLabel.frame.size.height)
        self.addChild(scoreLabel)

        // life
        for (var i:Int = 0; i < maxLifes; i++) {
            let life = Life(parent: self)
            life.position = CGPoint(x:centerX * 2.0 - life.size.width * 3.0 + life.size.width * CGFloat(i), y:scoreLabel.position.y - scoreLabel.frame.size.height)
            lifes.append(life)
        }
        reset()
    }

    func gainLife() {
        if (lifeCount < lifes.count) {
            lifes[lifeCount++].show()
        }
    }

    func lostLife() {
        lifes[--lifeCount].hide()
        if (lifeCount == 0) {
            gameOver()
        }
    }

    func gameOver() {
        stopTicking()
        message.removeFromParent()
        message.text = "GAME OVER!"
        self.addChild(message)
        gameState = .end
    }

    func setScore(_score:Int) {
        score = _score
        scoreLabel.text = "Score: " + String(_score)
    }

    func reset() {
        stopTicking()
        for life in lifes {
            life.show()
        }
        lifeCount = maxLifes
        setScore(0)
        gameState = .first
        message.removeFromParent()
        message.text = "TAP TO START!"
        self.addChild(message)
    }

    func flip(node: SKSpriteNode) {
        node.xScale = -node.xScale
    }

    func tick() {
        setScore(++score)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        if (gameState == .first) {
            message.removeFromParent()
            gameState = .play
            startTicking()
            return
        } else if (gameState == .end) {
            reset()
            return
        }
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            var hen = henL
            if (location.x < centerX) { // left hen
                if (location.y > step3Y) {
                    henL.position.y = step3Y
                } else if (location.y > step2Y) {
                    henL.position.y = step2Y
                } else {
                    henL.position.y = step1Y
                }
                gainLife()
            } else { // right hen
                if (location.y > step6Y) {
                    henR.position.y = step6Y
                } else if (location.y > step5Y) {
                    henR.position.y = step5Y
                } else {
                    henR.position.y = step4Y
                }
                lostLife()
            }
        }
    }

    func startTicking() {
        lastTick = NSDate.date()
    }

    func stopTicking() {
        lastTick = nil
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if lastTick == nil {
            return
        }
        var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            lastTick = NSDate.date()
            tick()
        }
    }
}
