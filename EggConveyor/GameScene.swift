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

enum EggState {
    case none, one, two, three, pack, broken
}
let eggStates: [EggState: SKTexture!] = [
    .none: SKTexture(imageNamed: "egg_02"),
    .one: SKTexture(imageNamed: "egg_03"),
    .two: SKTexture(imageNamed: "egg_04"),
    .three: SKTexture(imageNamed: "egg_05"),
    .pack: SKTexture(imageNamed: "egg_06"),
    .broken: SKTexture(imageNamed: "egg_07"),
]

class MyLabelNode: SKLabelNode {
    // http://stackoverflow.com/questions/25126295/swift-class-does-not-implement-its-superclasss-required-members
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(parent: GameScene) {
        super.init()
        fontName = "Chalkduster"
        hide()
        parent.addChild(self)
    }

    func show() {
        hidden = false
    }

    func hide() {
        hidden = true
    }
}

class MySpriteNode: SKSpriteNode {
    // http://stackoverflow.com/questions/25126295/swift-class-does-not-implement-its-superclasss-required-members
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(parent: GameScene, image: String) {
        let texture = SKTexture(imageNamed: image)
        let color = UIColor()
        super.init(texture: texture, color: color, size: texture.size())
        hide()
        parent.addChild(self)
    }

    func show() {
        hidden = false
    }

    func hide() {
        hidden = true
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
        (xScale, yScale) = (conveyorScale, -conveyorScale)
        runAction(convey)
    }
}

class Gas: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    init(parent: GameScene) {
        super.init(parent: parent, image: "truck_02")
        setScale(0.3)
        anchorPoint = CGPointMake(0.0, 0.0)
    }
}

class Truck: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    var eggs = [Egg]()
    var toY:CGFloat {
        return eggs.count > 0 ? eggs.last!.frame.maxY : position.y + 24.0
    }
    let gas: Gas!
    init(parent: GameScene) {
        super.init(parent: parent, image: "truck_01")
        setScale(0.3)
        anchorPoint = CGPointMake(0.0, 0.0)
        gas = Gas(parent: parent)
        gas.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeOutWithDuration(1.0), SKAction.fadeInWithDuration(1.0)])))
    }

    func start() {
        gas.position = CGPoint(x:frame.maxX - 1.0, y:position.y + 3.0)
        gas.show()
    }

    func stop() {
        gas.hide()
    }

    func leave() {
        runAction(SKAction.sequence([SKAction.moveToX(-size.width, duration: 1.0), SKAction.moveToX(position.x, duration: 1.0)]))
    }
}

class Hen: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    init(parent: GameScene) {
        super.init(parent: parent, image: "hen_01")
        setScale(0.35)
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
            text = "Score: " + String(score)
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

class Egg: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    let scale:CGFloat = 0.18
    var nextPos:Int = 2
    var eggState:EggState = .none {
        didSet {
            texture = eggStates[eggState]
            (size.width, size.height) = (texture.size().width * scale, texture.size().height * scale)
        }
    }
    init(parent: GameScene) {
        super.init(parent: parent, image: "egg_02")
        setScale(scale)
        anchorPoint = CGPointMake(0.5, 0.0)
    }

    func move(eggPoses: [CGPoint], toY: CGFloat) -> Bool {
        if (nextPos == eggPoses.count) {
            nextPos = 2
            runAction(SKAction.moveToY(toY, duration: 1.0))
            //hide()
            return true
        }
        if (nextPos > 36) {
            eggState = .pack
        } else if (nextPos > 28) {
            eggState = .three
        } else if (nextPos > 20) {
            eggState = .two
        } else if (nextPos > 12) {
            eggState = .one
        } else if (nextPos > 1) {
            eggState = .none
        }
        position = eggPoses[nextPos]
        if (nextPos++ == 2) {
            show()
        }
        return false
    }
}

class Life: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    // class variable is not avaialble yet...
    //class var _lifeCount:Int = 0
    //class var _lifes = [Life]()

    init(parent: GameScene) {
        super.init(parent: parent, image: "egg_01")
        setScale(0.3)
        anchorPoint = CGPointMake(0.5, 1.0)
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
    var eggs = [Egg]()
    var eggPoses = [CGPoint]()

    override func didMoveToView(view: SKView) {
        centerX = CGRectGetMidX(self.frame)
        centerY = CGRectGetMidY(self.frame)
        let ground = centerY - screenHeight * 0.5
        step1Y = self.frame.size.height * 0.24
        step2Y = self.frame.size.height * 0.46
        step3Y = self.frame.size.height * 0.68
        step4Y = self.frame.size.height * 0.13
        step5Y = self.frame.size.height * 0.35
        step6Y = self.frame.size.height * 0.57

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
        conveyor.position = CGPoint(x:centerX * 2.2, y:step1Y)
        conveyor.show()
        conveyor = Conveyor(parent: self)
        conveyor.position = CGPoint(x:centerX, y:step1Y)
        conveyor.show()
        conveyor = Conveyor(parent: self)
        conveyor.position = CGPoint(x:centerX, y:step5Y)
        conveyor.flip()
        conveyor.show()
        conveyor = Conveyor(parent: self)
        conveyor.position = CGPoint(x:centerX, y:step6Y)
        conveyor.show()
        conveyor = Conveyor(parent: self)
        conveyor.position = CGPoint(x:centerX, y:step3Y)
        conveyor.flip()
        conveyor.show()
        conveyor = Conveyor(parent: self)
        conveyor.position = CGPoint(x:centerX, y:step2Y)
        conveyor.show()

        // truck
        truck = Truck(parent: self)
        truck.position = CGPoint(x:0.0, y:ground)
        truck.show()

        // hen
        henL = Hen(parent: self) // left hen
        henR = Hen(parent: self) // right hen
        henL.position = CGPoint(x:centerX * 0.4, y:step1Y)
        henR.position = CGPoint(x:centerX * 1.6, y:step5Y)
        henL.flip()
        henL.show()
        henR.show()

        // egg
        eggPoses = [
            CGPoint(x:centerX * 1.60, y:step4Y), // 0 broken
            CGPoint(x:centerX * 0.51, y:step4Y), // 1 broken
            CGPoint(x:centerX * 2.00, y:step1Y + conveyor.size.height * 0.5), // 2 - 1
            CGPoint(x:centerX * 1.87, y:step1Y + conveyor.size.height * 0.5), // 3 - 1
            CGPoint(x:centerX * 1.74, y:step1Y + conveyor.size.height * 0.5), // 4 - 1
            CGPoint(x:centerX * 1.45, y:step1Y + conveyor.size.height * 0.5), // 5 - 1
            CGPoint(x:centerX * 1.32, y:step1Y + conveyor.size.height * 0.5), // 6 - 1
            CGPoint(x:centerX * 1.19, y:step1Y + conveyor.size.height * 0.5), // 7 - 1
            CGPoint(x:centerX * 1.06, y:step1Y + conveyor.size.height * 0.5), // 8 - 1
            CGPoint(x:centerX * 0.93, y:step1Y + conveyor.size.height * 0.5), // 9 - 1
            CGPoint(x:centerX * 0.80, y:step1Y + conveyor.size.height * 0.5), // 10 - 1
            CGPoint(x:centerX * 0.67, y:step1Y + conveyor.size.height * 0.5), // 11 - 1
            CGPoint(x:centerX * 0.54, y:step1Y + conveyor.size.height * 0.5), // 12 - 1
            CGPoint(x:centerX * 0.54, y:step5Y + conveyor.size.height * 0.5), // 13 - 2
            CGPoint(x:centerX * 0.67, y:step5Y + conveyor.size.height * 0.5), // 14 - 2
            CGPoint(x:centerX * 0.80, y:step5Y + conveyor.size.height * 0.5), // 15 - 2
            CGPoint(x:centerX * 0.93, y:step5Y + conveyor.size.height * 0.5), // 16 - 2
            CGPoint(x:centerX * 1.06, y:step5Y + conveyor.size.height * 0.5), // 17 - 2
            CGPoint(x:centerX * 1.19, y:step5Y + conveyor.size.height * 0.5), // 18 - 2
            CGPoint(x:centerX * 1.32, y:step5Y + conveyor.size.height * 0.5), // 19 - 2
            CGPoint(x:centerX * 1.45, y:step5Y + conveyor.size.height * 0.5), // 20 - 2
            CGPoint(x:centerX * 1.45, y:step2Y + conveyor.size.height * 0.5), // 21 - 3
            CGPoint(x:centerX * 1.32, y:step2Y + conveyor.size.height * 0.5), // 22 - 3
            CGPoint(x:centerX * 1.19, y:step2Y + conveyor.size.height * 0.5), // 23 - 3
            CGPoint(x:centerX * 1.06, y:step2Y + conveyor.size.height * 0.5), // 24 - 3
            CGPoint(x:centerX * 0.93, y:step2Y + conveyor.size.height * 0.5), // 25 - 3
            CGPoint(x:centerX * 0.80, y:step2Y + conveyor.size.height * 0.5), // 26 - 3
            CGPoint(x:centerX * 0.67, y:step2Y + conveyor.size.height * 0.5), // 27 - 3
            CGPoint(x:centerX * 0.54, y:step2Y + conveyor.size.height * 0.5), // 28 - 3
            CGPoint(x:centerX * 0.54, y:step6Y + conveyor.size.height * 0.5), // 29 - 4
            CGPoint(x:centerX * 0.67, y:step6Y + conveyor.size.height * 0.5), // 30 - 4
            CGPoint(x:centerX * 0.80, y:step6Y + conveyor.size.height * 0.5), // 31 - 4
            CGPoint(x:centerX * 0.93, y:step6Y + conveyor.size.height * 0.5), // 32 - 4
            CGPoint(x:centerX * 1.06, y:step6Y + conveyor.size.height * 0.5), // 33 - 4
            CGPoint(x:centerX * 1.19, y:step6Y + conveyor.size.height * 0.5), // 34 - 4
            CGPoint(x:centerX * 1.32, y:step6Y + conveyor.size.height * 0.5), // 35 - 4
            CGPoint(x:centerX * 1.45, y:step6Y + conveyor.size.height * 0.5), // 36 - 4
            CGPoint(x:centerX * 1.45, y:step3Y + conveyor.size.height * 0.5), // 37 - 5
            CGPoint(x:centerX * 1.32, y:step3Y + conveyor.size.height * 0.5), // 38 - 5
            CGPoint(x:centerX * 1.19, y:step3Y + conveyor.size.height * 0.5), // 39 - 5
            CGPoint(x:centerX * 1.06, y:step3Y + conveyor.size.height * 0.5), // 40 - 5
            CGPoint(x:centerX * 0.93, y:step3Y + conveyor.size.height * 0.5), // 41 - 5
            CGPoint(x:centerX * 0.80, y:step3Y + conveyor.size.height * 0.5), // 42 - 5
            CGPoint(x:centerX * 0.67, y:step3Y + conveyor.size.height * 0.5), // 43 - 5
            CGPoint(x:centerX * 0.54, y:step3Y + conveyor.size.height * 0.5), // 44 - 5
            CGPoint(x:centerX * 0.18, y:step3Y + conveyor.size.height * 0.5), // 45 - 6
        ]
        eggs.append(Egg(parent: self))

        // message
        message = Message(parent: self)
        message.position = CGPoint(x:centerX, y:centerY)

        // score
        scoreLabel = Score(parent: self)
        scoreLabel.position.x = centerX * 2.0 - scoreLabel.frame.size.width
        scoreLabel.position.y = screenHeight + ground - scoreLabel.frame.size.height
        scoreLabel.show()

        // life
        for i in 0..<maxLifes {
            let life = Life(parent: self)
            life.position.x = centerX * 2.0 - life.size.width * CGFloat(maxLifes - i)
            life.position.y = scoreLabel.frame.minY
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
        for (i, egg) in enumerate(eggs) {
            if (egg.move(eggPoses, toY: truck.toY)) {
                //eggs.removeAtIndex(i)
                eggs[i] = Egg(parent: self)
                truck.eggs.append(egg)
                if (truck.eggs.count == 11) {
                    truck.start()
                } else if (truck.eggs.count == 12) {
                    scoreLabel.add(10)
                    truck.leave()
                }
            }
            if (find([6, 14, 22, 30, 38, 46], egg.nextPos) != nil) {
                scoreLabel.add(1)
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        if (gameState == .first) {
            message.hide()
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
