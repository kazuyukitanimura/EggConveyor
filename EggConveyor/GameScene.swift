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

class MyLabelNode: SKLabelNode {
    // http://stackoverflow.com/questions/25126295/swift-class-does-not-implement-its-superclasss-required-members
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    var _parent: GameScene!
    init(parent: GameScene) {
        super.init()
        fontName = "Chalkduster"
        _parent = parent
    }

    func show() {
        removeFromParent()
        _parent.addChild(self)
    }

    func hide() {
        removeFromParent()
    }
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
        _parent = parent
    }

    func show() {
        removeFromParent()
        _parent.addChild(self)
    }

    func hide() {
        removeFromParent()
    }

    func flip() {
        xScale = -xScale
    }
}

class Conveyor: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    let conveyor1 = SKTexture(imageNamed: "conveyor_01")
    let conveyor2 = SKTexture(imageNamed: "conveyor_02")
    let conveyor3 = SKTexture(imageNamed: "conveyor_03")
    init(parent: GameScene) {
        let anim = SKAction.animateWithTextures([conveyor1, conveyor2, conveyor3], timePerFrame: 0.2)
        let convey = SKAction.repeatActionForever(anim)
        super.init(parent: parent, image: "conveyor_01")
        let conveyorScale:CGFloat = 0.4
        xScale = conveyorScale
        yScale = -conveyorScale
        runAction(convey)
    }
}

class Gas: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    init(parent: GameScene) {
        super.init(parent: parent, image: "truck_02")
        setScale(0.3)
        anchorPoint = CGPointMake(0.5, 0.0)
    }
}

class Truck: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    let gas: Gas!
    init(parent: GameScene) {
        super.init(parent: parent, image: "truck_01")
        setScale(0.3)
        anchorPoint = CGPointMake(0.5, 0.0)
        gas = Gas(parent: parent)
        gas.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeOutWithDuration(1.0), SKAction.fadeInWithDuration(1.0)])))
    }

    func start() {
        gas.position = CGPoint(x:size.width + gas.size.width * 0.5 - 1.0, y:position.y + 3.0)
        gas.show()
    }

    func stop() {
        gas.hide()
    }
}

class Hen: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    init(parent: GameScene) {
        super.init(parent: parent, image: "hen_01")
        setScale(0.4)
        anchorPoint = CGPointMake(0.5, 0.0)
    }
}

class Message: MyLabelNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    override init(parent: GameScene) {
        super.init(parent: parent)
        fontSize = 65
    }

    func show(_text: String) {
        text = _text
        show()
    }
}

class Score: MyLabelNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    var score:Int = 0 {
        didSet {
            self.text = "Score: " + String(score)
        }
    }

    override init(parent: GameScene) {
        super.init(parent: parent)
        fontSize = 30
        set(score)
    }

    func set(_score:Int) {
        score = _score
    }

    func add (n: Int) { // += oeprator cannot be declared yet...
        score += n
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
    var henL:Hen!
    var henR:Hen!
    var truck:Truck!
    var centerX:CGFloat!
    var centerY:CGFloat!
    var step1Y:CGFloat!
    var step2Y:CGFloat!
    var step3Y:CGFloat!
    var step4Y:CGFloat!
    var step5Y:CGFloat!
    var step6Y:CGFloat!
    var message:Message!
    var scoreLabel:Score!
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
        step1Y = self.frame.size.height * 0.15
        step2Y = self.frame.size.height * 0.45
        step3Y = self.frame.size.height * 0.75
        step4Y = self.frame.size.height * 0.00
        step5Y = self.frame.size.height * 0.30
        step6Y = self.frame.size.height * 0.60

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
        var conveyor = Conveyor(parent: self)
        conveyor.position = CGPoint(x:centerX * 2.2, y:self.frame.size.height * 0.15)
        conveyor.show()
        for (var i:Int = 0; i < 5; i++) {
            conveyor = Conveyor(parent: self)
            if ((i & 0x01) == 0x01) {
                conveyor.flip()
            }
            conveyor.position = CGPoint(x:centerX, y:self.frame.size.height * 0.15 * CGFloat(i + 1))
            conveyor.show()
        }

        // truck
        truck = Truck(parent: self)
        truck.position = CGPoint(x:truck.size.width * 0.5, y:ground)
        truck.show()

        // hen
        henL = Hen(parent: self) // left hen
        henR = Hen(parent: self) // right hen
        henL.position = CGPoint(x:centerX * 0.4, y:self.frame.size.height * 0.15)
        henR.position = CGPoint(x:centerX * 1.6, y:self.frame.size.height * 0.30)
        henL.flip()
        henL.show()
        henR.show()

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
        message = Message(parent: self)
        message.position = CGPoint(x:centerX, y:centerY)

        // score
        scoreLabel = Score(parent: self)
        scoreLabel.position.x = centerX * 2.0 - scoreLabel.frame.size.width
        scoreLabel.position.y = screenHeight + ground - scoreLabel.frame.size.height
        scoreLabel.show()

        // life
        for (var i:Int = 0; i < maxLifes; i++) {
            let life = Life(parent: self)
            life.position.x = centerX * 2.0 - life.size.width * 3.0 + life.size.width * CGFloat(i)
            life.position.y = scoreLabel.position.y - scoreLabel.frame.size.height
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
        truck.stop()
        message.show("GAME OVER!")
        gameState = .end
    }

    func reset() {
        stopTicking()
        truck.stop()
        for life in lifes {
            life.show()
        }
        lifeCount = maxLifes
        scoreLabel.set(0)
        gameState = .first
        message.show("TAP TO START!")
    }

    func tick() {
        scoreLabel.add(1)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        if (gameState == .first) {
            message.hide()
            gameState = .play
            startTicking()
            truck.start()
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
