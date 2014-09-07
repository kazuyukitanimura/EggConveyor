//
//  GameScene.swift
//  EggConveyor
//
//  Created by Kazuyuki Tanimura on 7/22/14.
//  Copyright (c) 2014 Kazuyuki Tanimura. All rights reserved.
//

import SpriteKit
import Social

enum GameState {
    case first, play, end, retry
}

extension SKAction {
    class func moveByY (_deltaY: CGFloat, duration: NSTimeInterval) -> SKAction! {
        return SKAction.moveBy(CGVectorMake(0, _deltaY), duration: duration)
    }
}
extension Dictionary {
    func hasKey(_key: AnyObject?) -> Bool {
        return [_key!] != nil
    }
}

class MyLabelNode: SKLabelNode {
    // http://stackoverflow.com/questions/25126295/swift-class-does-not-implement-its-superclasss-required-members
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(parent: SKNode) {
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

    init(parent: SKNode, image: String) {
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
        xScale = -(abs(xScale))
    }

    func flipBack() {
        xScale = abs(xScale)
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

    let scale:CGFloat = 0.3
    var eggs = [Egg]()
    var toY:CGFloat {
        return eggs.count > 0 ? eggs.last!.frame.maxY : position.y + 24.0
    }
    let gas: Gas!
    init(parent: GameScene) {
        super.init(parent: parent, image: "truck_01")
        setScale(scale)
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

    func leave(callback: () -> Void) {
        for egg in eggs {
            egg.removeAllActions()
            let y = egg.position.y - position.y
            egg.removeFromParent()
            addChild(egg)
            egg.size.width /= scale
            egg.size.height /= scale
            egg.position.y = y / scale
            egg.position.x /= scale
        }
        runAction(SKAction.moveToX(-size.width, duration: 1.0), completion: back(callback))
    }

    func back (callback: () -> Void)() { // curried
        stop()
        for egg in eggs {
            egg.removeFromParent()
        }
        eggs.removeAll(keepCapacity: true)
        runAction(SKAction.moveToX(0.0, duration: 1.0), completion: callback)
    }

    func reset() {
        for egg in eggs {
            egg.removeFromParent()
        }
        eggs.removeAll(keepCapacity: true)
    }
}

class Hen: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    enum HenState {
        case normal, cry, rest, smile, catch
    }
    let henStates: [HenState: SKTexture!] = [
        .normal: SKTexture(imageNamed: "hen_01"),
        .cry: SKTexture(imageNamed: "hen_02"),
        .rest: SKTexture(imageNamed: "hen_03"),
        .smile: SKTexture(imageNamed: "hen_04"),
        .catch: SKTexture(imageNamed: "hen_05"),
    ]

    let scale:CGFloat = 0.35
    var henState:HenState = .normal {
        didSet {
            texture = henStates[henState]
            (size.width, size.height) = (texture!.size().width * scale, texture!.size().height * scale)
        }
    }
    var yPoses:[CGFloat]!
    var yPos:Int = 1
    init(parent: GameScene, yPoses: [CGFloat]) {
        super.init(parent: parent, image: "hen_01")
        setScale(scale)
        anchorPoint = CGPointMake(0.5, 0.0)
        self.yPoses = yPoses
        position.y = yPoses[yPos]
    }

    func move(toY: CGFloat) {
        var _yPos = yPos
        let margin:CGFloat = 7
        if (toY > yPoses[2] - margin) {
            yPos = 2
        } else if (toY > yPoses[1] - margin) {
            yPos = 1
        } else {
            yPos = 0
        }
        if (_yPos != yPos) {
            position.y = yPoses[yPos]
            if (henState == .smile) {
                reset()
            }
        }
    }

    func reset() {
        henState = .normal
    }

    func cry() {
        henState = .cry
    }

    func rest() {
        if (henState != .catch) {
            henState = .rest
        }
    }

    func smile() {
        henState = .smile
    }

    func catch() {
        henState = .catch
    }
}

class Message: MyLabelNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    override init(parent: SKNode) {
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
            text = "SCORE " + String(score)
        }
    }
    var lastMiss:Int = 0
    var bestScore:Int {
        get {
            return kvLoad("bestScore") as? Int ?? 0
        }
        set {
            if (bestScore < score) {
                kvStore("bestScore", newValue)
            }
            SRWebClient.POST("http://validate.jsontest.com")
                .headers(["Content-Type":"application/x-www-form-urlencoded charset=utf-8"])
                .data(["json":"[1, 2, 3]"])
                .send(success, failure:nil)
        }
    }
    /*
    var worldBest:String {
        get {
             return kvLoad("worldBest") as? String ?? "... ?"
        }
        set {
            kvStore("worldBest", newValue)
        }
    }*/
    var worldBest = "... ?"
    var worldRank = "... ?"
    var countryBest = "... ?"
    var countryRank = "... ?"
    func success(response:AnyObject!, status:Int) {
        //process success response
        println(response)
        worldBest = String(arc4random_uniform(12345))
        worldRank = String(arc4random_uniform(12345))
        countryBest = String(arc4random_uniform(12345))
        countryRank = String(arc4random_uniform(12345))
    }

    override init(parent: SKNode) {
        super.init(parent: parent)
        fontSize = 30
        set(score)
    }

    func set(_score:Int) {
        score = _score
    }

    func add(n: Int, chance:() -> Bool) -> Int {
        var plus = n
        if (score % 300 == 0 && score > 0 && chance()) {
            lastMiss = score // if there are lost lives, get a life back
        } else if (score - lastMiss >= 300) {
            plus *= 2 // if no life is lost, double the gain
        }
        score += plus
        return plus
    }

    func lostLife() {
        lastMiss = score
        bestScore = score
    }
}

class Egg: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

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

    let scale:CGFloat = 0.22
    var eggState:EggState = .none {
        didSet {
            texture = eggStates[eggState]
            (size.width, size.height) = (texture!.size().width * scale, texture!.size().height * scale)
        }
    }
    var currPos:Int = 2 {
        didSet {
            if (currPos < _eggPoses.count) {
                if (currPos > 37) {
                    eggState = .pack
                } else if (currPos > 29) {
                    eggState = .three
                } else if (currPos > 21) {
                    eggState = .two
                } else if (currPos > 13) {
                    eggState = .one
                } else if (currPos > 2) {
                    eggState = .none
                } else {
                    eggState = .broken
                }
                position = _eggPoses[currPos]
            }
        }
    }
    var _eggPoses:[CGPoint]!
    init(parent: GameScene, eggPoses: [CGPoint]) {
        super.init(parent: parent, image: "egg_02")
        setScale(scale)
        anchorPoint = CGPointMake(0.5, 0.0)
        _eggPoses = eggPoses
    }

    func move(toY: CGFloat, duration: NSTimeInterval) -> Bool {
        if (++currPos == _eggPoses.count) {
            runAction(SKAction.moveToY(toY, duration: duration - NSTimeInterval(0.1)))
            return true
        }
        if (currPos == 3) {
            show()
        }
        return false
    }

    func didFailL(henY: Int) -> Bool {
        if ((henY != 0 && currPos == 13) || (henY != 1 && currPos == 29) || (henY != 2 && currPos == 45)) {
            currPos = 2
            return true
        }
        return false
    }

    func didFailR(henY: Int) -> Bool {
        if (henY != 0 && currPos == 5) {
            currPos = 0
            return true
        }
        if ((henY != 1 && currPos == 21) || (henY != 2 && currPos == 37)) {
            currPos = 1
            return true
        }
        return false
    }

    func didScore() -> Bool {
        return isOneOf(currPos, [6, 14, 22, 30, 38, 46])
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
        anchorPoint = CGPointMake(0.5, 1.2)
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

class Pause: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    init(parent: GameScene) {
        super.init(parent: parent, image: "pause")
        setScale(0.3)
        anchorPoint = CGPointMake(1.2, 1.3)
        name = "pause"
        zPosition = 1.0
        let pauseLetter = MyLabelNode(parent: self)
        pauseLetter.fontSize = 110
        pauseLetter.text = "| |"
        pauseLetter.position = CGPoint(x:-174, y:-236)
        pauseLetter.name = "pause"
        pauseLetter.show()
    }
}

class ChalkBorder: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    init(parent: SKNode) {
        super.init(parent: parent, image: "border")
        setScale(0.6)
    }
}

class ScoreBoard: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    init(parent: GameScene) {
        super.init(parent: parent, image: "scoreboard")
        setScale(0.7)
        zPosition = 2.0
    }

    func show(scoreObj:Score) {
        let fontSize:CGFloat = 82
        let fontSizeHalf:CGFloat = 41
        let newRecordColor = SKColor(red: 216.0/255.0, green: 121.0/255.0, blue: 118.0/255.0, alpha: 1.0)
        let score = scoreObj.score
        let bestScore = scoreObj.bestScore
        let isRecord = score == bestScore
        let gameOver = MyLabelNode(parent: self)
        gameOver.fontSize = fontSize - 20
        gameOver.text = "GAME OVER!"
        gameOver.position = CGPoint(x: 0, y: 280)
        gameOver.show()
        let scoreLabel = MyLabelNode(parent: self)
        scoreLabel.fontSize = fontSize
        scoreLabel.text = "SCORE \(score)"
        if (isRecord) {
            scoreLabel.text = "CONGRATS! NEW"
            scoreLabel.fontColor = newRecordColor
        }
        scoreLabel.position = CGPoint(x: 0, y: 150)
        scoreLabel.show()
        let bestScoreLabel = MyLabelNode(parent: self)
        bestScoreLabel.fontSize = fontSize
        bestScoreLabel.text = "PERSONAL BEST \(bestScore)"
        if (isRecord) {
            bestScoreLabel.fontColor = newRecordColor
        }
        bestScoreLabel.position = CGPoint(x: 0, y: 20)
        bestScoreLabel.show()
        let worldBest = MyLabelNode(parent: self)
        worldBest.fontSize = fontSizeHalf
        worldBest.text = "WORLD BEST \(scoreObj.worldBest)"
        worldBest.position = CGPoint(x: -280, y: -70)
        worldBest.show()
        let worldRank = MyLabelNode(parent: self)
        worldRank.fontSize = fontSizeHalf
        worldRank.text = "WORLD RANK \(scoreObj.worldRank)"
        worldRank.position = CGPoint(x: -280, y: -140)
        worldRank.show()
        let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as String
        let countryBest = MyLabelNode(parent: self)
        countryBest.fontSize = fontSizeHalf
        countryBest.text = "\(countryCode) BEST \(scoreObj.countryBest)"
        countryBest.position = CGPoint(x: 170, y: -70)
        countryBest.show()
        let countryRank = MyLabelNode(parent: self)
        countryRank.fontSize = fontSizeHalf
        countryRank.text = "\(countryCode) RANK \(scoreObj.countryRank)"
        countryRank.position = CGPoint(x: 170, y: -140)
        countryRank.show()
        let borderT = ChalkBorder(parent: self)
        borderT.position = CGPoint(x: -340, y: -340)
        borderT.xScale = 0.4
        borderT.name = "Twitter"
        borderT.show()
        let twitter = MyLabelNode(parent: borderT)
        twitter.fontSize = 160
        twitter.text = "t"
        twitter.fontColor = SKColor(red: 0.0/255.0, green: 172.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        twitter.xScale = 2.0
        twitter.position = CGPoint(x: -60, y: 40)
        twitter.name = "Twitter"
        twitter.show()
        let borderF = ChalkBorder(parent: self)
        borderF.position = CGPoint(x: -170, y: -340)
        borderF.xScale = 0.4
        borderF.name = "Facebook"
        borderF.show()
        let facebook = MyLabelNode(parent: borderF)
        facebook.fontSize = 118
        facebook.text = "f"
        facebook.fontColor = SKColor(red: 99.0/255.0, green: 129.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        facebook.xScale = 2.0
        facebook.position = CGPoint(x: -60, y: 60)
        facebook.name = "Facebook"
        facebook.show()
        let borderR = ChalkBorder(parent: self)
        borderR.position = CGPoint(x: 310, y: -340)
        borderR.xScale = 1.6
        borderR.name = "retry"
        borderR.show()
        let retryLabel = MyLabelNode(parent: borderR)
        retryLabel.fontSize = 110
        retryLabel.text = "\u{21BB} RETRY"
        retryLabel.xScale = 0.4
        retryLabel.position = CGPoint(x: -60, y: 68)
        retryLabel.show()
        show()
        var slideIn = SKAction.moveToX(parent!.frame.midX, duration: 1.5)
        slideIn.timingMode = .EaseOut
        runAction(slideIn)
    }

    override func hide() {
        removeAllChildren()
        super.hide()
    }
}

class Tap: MySpriteNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    var tapLetter:MyLabelNode!
    init(parent: GameScene) {
        super.init(parent: parent, image: "tap")
        setScale(1.0)
        anchorPoint = CGPointMake(0.5, -1.0)
        tapLetter = MyLabelNode(parent: self)
        tapLetter.fontSize = 40
        tapLetter.text = "TAP"
        tapLetter.position = CGPoint(x:-7, y:70)
        tapLetter.show()
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.moveByX(8.0, y: 0.0, duration: 1.0), SKAction.moveByX(-8.0, y: 0.0, duration: 1.0)])))
    }

    override func flip() {
        tapLetter.xScale = -tapLetter.xScale
        super.flip()
    }
}

class ScoreTip: MyLabelNode {
    required init(coder: NSCoder) {super.init(coder: coder)}

    override init(parent: SKNode) {
        super.init(parent: parent)
        fontSize = 60
    }

    func show(score: Int) {
        text = "+\(score)"
        super.show()
        runAction(SKAction.fadeOutWithDuration(1.0))
        runAction(SKAction.moveByY(150, duration: 1.0))
    }
}

class Dispatcher {
    let _size:Int
    let _row:Int
    let _col:Int
    var history:[Bool]
    var count:Int = 0
    var colCnt:Int = 0
    var last:Bool = false
    var _rate:Int = 10
    init(row: Int, col:Int, rate: Int) {
        _size = row * col
        _row = row
        _col = col
        history = [Bool](count:_size, repeatedValue: false)
        _rate = rate
    }

    func dispatch() -> Bool {
        if (count == _size) {
            count = 0
        }
        if (last) {
            last = false
        } else {
            for j in 0..<_row {
                last |= history[j * _col + colCnt] // find conflicts
            }
            last ^= history[count] // but do not count self
            last = !last && (arc4random_uniform(UInt32(_rate)) == 0) // if no conflicts, randomly assign
        }
        history[count++] = last
        if (++colCnt == _col) {
            colCnt = 0
        }
        return last
    }

    func first() {
        /* force first history true*/
        history[0] = true
        last = true
        count = 1
        colCnt = 1
    }
}

class Timer {
    var _interval:NSTimeInterval!
    var _lastTick:NSDate?
    var _onTick:(() -> Void)!

    init (interval: Double, onTick: (() -> Void)!) {
        _interval = NSTimeInterval(interval)
        _onTick = onTick
    }

    func startTicking() {
        _lastTick = NSDate.date()
    }

    func stopTicking() {
        _lastTick = nil
    }

    func toggle() -> Bool{
        if (_lastTick != nil) {
            stopTicking()
            return true
        } else {
            startTicking()
            return false
        }
    }

    func tick() {
        if (_lastTick != nil && -_lastTick!.timeIntervalSinceNow > _interval) {
            startTicking()
            _onTick()
        }
    }
}

func isOneOf<T: Comparable>(x: T, among:[T]) -> Bool {
    //return among.filter {$0 == x}.count > 0
    return find(among, x) != nil
}

func toHex(x: AnyObject) -> String {
    return NSString(format:"%2X", (x as Int)) as String
}

func kvStore(k: String, v: AnyObject) {
    NSUserDefaults.standardUserDefaults().setObject(v, forKey: k)
    NSUserDefaults.standardUserDefaults().synchronize()
}

func kvLoad(k: String) -> AnyObject? {
    return NSUserDefaults.standardUserDefaults().objectForKey(k)
}

class GameScene: SKScene {
    // It seems 576 is the real height as opposed to 640 for iPhone5s
    let screenHeight:CGFloat = 576.0
    var henL:Hen!
    var henR:Hen!
    var truck:Truck!
    var centerX:CGFloat!
    var centerY:CGFloat!
    var step0Y:CGFloat!
    var step1Y:CGFloat!
    var step2Y:CGFloat!
    var step3Y:CGFloat!
    var step4Y:CGFloat!
    var step5Y:CGFloat!
    var step6Y:CGFloat!
    var step7Y:CGFloat!
    var message:Message!
    var scoreLabel:Score!
    var lifeCount:Int = 0
    let maxLifes:Int = 3
    var lifes = [Life]()
    var gameState:GameState!
    var onPlayInterval:Double = 0.9 // sec
    var offPlayInterval:Double = 0.8 // sec
    var oopsInterval:Double = 3.0 // sec
    var countDown:Int = 0
    var eggs = [Egg]()
    var lostEggs = [Egg]()
    var eggPoses = [CGPoint]()
    let dispatcher = Dispatcher(row:3, col:16, rate: 9)
    var level = 1
    var messages = [String]()
    var timers = [Timer]()
    var pause:Pause!
    var scoreBoard:ScoreBoard!
    var taps = [Tap]()
    var UUID:String {
        get {
            var ret = kvLoad("UUID") as? String
            if (ret == nil) {
                ret = toHex(NSDate().timeIntervalSince1970) + "-" + toHex(Int(arc4random()))
                self.UUID = ret!
            }
            return ret!
        }
        set {
            kvStore("UUID", newValue)
        }
    }

    override func didMoveToView(view: SKView) {
        centerX = frame.midX
        centerY = frame.midY
        let ground = centerY - screenHeight * 0.5
        step0Y = frame.size.height * 0.14
        step1Y = frame.size.height * 0.24
        step2Y = frame.size.height * 0.46
        step3Y = frame.size.height * 0.68
        step4Y = frame.size.height * 0.13
        step5Y = frame.size.height * 0.35
        step6Y = frame.size.height * 0.57
        step7Y = frame.size.height * 0.78

        // background
        let backGround = SKSpriteNode(imageNamed: "background")
        addChild(backGround)
        backGround.position = CGPoint(x:centerX, y:centerY)

        // tower
        let tower = SKSpriteNode(imageNamed: "tower")
        tower.setScale(screenHeight / tower.size.height)
        tower.position = CGPoint(x:centerX, y:centerY - 10.0)
        addChild(tower)

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
        addChild(step1)
        addChild(step2)
        addChild(step3)
        addChild(step4)
        addChild(step5)
        addChild(step6)

        // conveyor
        var conveyor = Conveyor(parent: self)
        conveyor.position = CGPoint(x:centerX * 2.2, y:step0Y)
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
        henL = Hen(parent: self, yPoses: [step1Y, step2Y, step3Y]) // left hen
        henR = Hen(parent: self, yPoses: [step4Y, step5Y, step6Y]) // right hen
        henL.position.x = centerX * 0.4
        henR.position.x = centerX * 1.6
        henL.flip()
        henL.show()
        henR.show()

        // egg
        eggPoses = [
            CGPoint(x:centerX * 1.72, y:ground), // 0 broken
            CGPoint(x:centerX * 1.48, y:ground), // 1 broken
            CGPoint(x:centerX * 0.51, y:ground), // 2 broken
            CGPoint(x:centerX * 2.00, y:step0Y + conveyor.size.height * 0.5), // 3 - 0
            CGPoint(x:centerX * 1.87, y:step0Y + conveyor.size.height * 0.5), // 4 - 0
            CGPoint(x:centerX * 1.74, y:step0Y + conveyor.size.height * 0.5), // 5 - 0
            CGPoint(x:centerX * 1.45, y:step1Y + conveyor.size.height * 0.5), // 6 - 1
            CGPoint(x:centerX * 1.32, y:step1Y + conveyor.size.height * 0.5), // 7 - 1
            CGPoint(x:centerX * 1.19, y:step1Y + conveyor.size.height * 0.5), // 8 - 1
            CGPoint(x:centerX * 1.06, y:step1Y + conveyor.size.height * 0.5), // 9 - 1
            CGPoint(x:centerX * 0.93, y:step1Y + conveyor.size.height * 0.5), // 10 - 1
            CGPoint(x:centerX * 0.80, y:step1Y + conveyor.size.height * 0.5), // 11 - 1
            CGPoint(x:centerX * 0.67, y:step1Y + conveyor.size.height * 0.5), // 12 - 1
            CGPoint(x:centerX * 0.54, y:step1Y + conveyor.size.height * 0.5), // 13 - 1
            CGPoint(x:centerX * 0.54, y:step5Y + conveyor.size.height * 0.5), // 14 - 2
            CGPoint(x:centerX * 0.67, y:step5Y + conveyor.size.height * 0.5), // 15 - 2
            CGPoint(x:centerX * 0.80, y:step5Y + conveyor.size.height * 0.5), // 16 - 2
            CGPoint(x:centerX * 0.93, y:step5Y + conveyor.size.height * 0.5), // 17 - 2
            CGPoint(x:centerX * 1.06, y:step5Y + conveyor.size.height * 0.5), // 18 - 2
            CGPoint(x:centerX * 1.19, y:step5Y + conveyor.size.height * 0.5), // 19 - 2
            CGPoint(x:centerX * 1.32, y:step5Y + conveyor.size.height * 0.5), // 20 - 2
            CGPoint(x:centerX * 1.45, y:step5Y + conveyor.size.height * 0.5), // 21 - 2
            CGPoint(x:centerX * 1.45, y:step2Y + conveyor.size.height * 0.5), // 22 - 3
            CGPoint(x:centerX * 1.32, y:step2Y + conveyor.size.height * 0.5), // 23 - 3
            CGPoint(x:centerX * 1.19, y:step2Y + conveyor.size.height * 0.5), // 24 - 3
            CGPoint(x:centerX * 1.06, y:step2Y + conveyor.size.height * 0.5), // 25 - 3
            CGPoint(x:centerX * 0.93, y:step2Y + conveyor.size.height * 0.5), // 26 - 3
            CGPoint(x:centerX * 0.80, y:step2Y + conveyor.size.height * 0.5), // 27 - 3
            CGPoint(x:centerX * 0.67, y:step2Y + conveyor.size.height * 0.5), // 28 - 3
            CGPoint(x:centerX * 0.54, y:step2Y + conveyor.size.height * 0.5), // 29 - 3
            CGPoint(x:centerX * 0.54, y:step6Y + conveyor.size.height * 0.5), // 20 - 4
            CGPoint(x:centerX * 0.67, y:step6Y + conveyor.size.height * 0.5), // 31 - 4
            CGPoint(x:centerX * 0.80, y:step6Y + conveyor.size.height * 0.5), // 32 - 4
            CGPoint(x:centerX * 0.93, y:step6Y + conveyor.size.height * 0.5), // 33 - 4
            CGPoint(x:centerX * 1.06, y:step6Y + conveyor.size.height * 0.5), // 34 - 4
            CGPoint(x:centerX * 1.19, y:step6Y + conveyor.size.height * 0.5), // 35 - 4
            CGPoint(x:centerX * 1.32, y:step6Y + conveyor.size.height * 0.5), // 36 - 4
            CGPoint(x:centerX * 1.45, y:step6Y + conveyor.size.height * 0.5), // 37 - 4
            CGPoint(x:centerX * 1.45, y:step3Y + conveyor.size.height * 0.5), // 38 - 5
            CGPoint(x:centerX * 1.32, y:step3Y + conveyor.size.height * 0.5), // 39 - 5
            CGPoint(x:centerX * 1.19, y:step3Y + conveyor.size.height * 0.5), // 40 - 5
            CGPoint(x:centerX * 1.06, y:step3Y + conveyor.size.height * 0.5), // 41 - 5
            CGPoint(x:centerX * 0.93, y:step3Y + conveyor.size.height * 0.5), // 42 - 5
            CGPoint(x:centerX * 0.80, y:step3Y + conveyor.size.height * 0.5), // 43 - 5
            CGPoint(x:centerX * 0.67, y:step3Y + conveyor.size.height * 0.5), // 44 - 5
            CGPoint(x:centerX * 0.54, y:step3Y + conveyor.size.height * 0.5), // 45 - 5
            CGPoint(x:centerX * 0.18, y:step7Y + conveyor.size.height * 0.5), // 46 - 6
        ]
        eggs.append(Egg(parent: self, eggPoses: eggPoses))

        // message
        message = Message(parent: self)
        message.position = CGPoint(x:centerX, y:centerY)

        // score
        scoreLabel = Score(parent: self)
        scoreLabel.position.x = centerX * 2.0 - scoreLabel.frame.size.width
        scoreLabel.position.y = screenHeight + ground - scoreLabel.frame.size.height

        // life
        for i in 0..<maxLifes {
            let life = Life(parent: self)
            life.position.x = centerX * 2.0 - life.size.width * CGFloat(maxLifes - i)
            life.position.y = scoreLabel.frame.minY
            lifes.append(life)
        }

        // Timers
        timers.append(Timer(interval: onPlayInterval, onTick: onPlay))
        timers.append(Timer(interval: offPlayInterval, onTick: offPlay))
        timers.append(Timer(interval: oopsInterval, onTick: oops))

        // Pause
        pause = Pause(parent: self)
        pause.position = CGPoint(x:centerX * 2.0, y:lifes[0].frame.minY)

        // score board
        scoreBoard = ScoreBoard(parent: self)
        scoreBoard.position = CGPoint(x:centerX * 3.0, y:centerY)

        // Tap
        taps.append(Tap(parent: self))
        taps[0].position = CGPoint(x:centerX * 0.2, y:step1Y)
        taps.append(Tap(parent: self))
        taps[1].flip()
        taps[1].position = CGPoint(x:centerX * 1.8, y:step4Y)

        println(UUID)
        reset()
    }

    func gainLife() -> Bool {
        if (lifeCount < lifes.count) {
            lifes[lifeCount++].show()
            return true
        }
        return false
    }

    func lostLife() {
        lifes[--lifeCount].hide()
        message.show("OOPS! DROPPED!")
        scoreLabel.lostLife()
        henL.cry()
        henR.cry()
        pause.hide()
        if (lifeCount == 0) {
            showAd()
            scoreBoard.show(scoreLabel)
        }
        timers[0].stopTicking()
        timers[2].startTicking()
    }

    func oops() {
        message.hide()
        for egg in lostEggs {
            egg.removeFromParent()
        }
        lostEggs.removeAll(keepCapacity: false)
        timers[2].stopTicking()
        if (lifeCount == 0) {
            gameOver()
            return
        }
        if (henL.henState == .cry) {
            henL.reset()
        }
        if (henR.henState == .cry) {
            henR.reset()
        }
        pause.show()
        timers[0].startTicking()
    }

    func gameOver() {
        timers[0].stopTicking()
        truck.stop()
        pause.hide()
        scoreLabel.hide()
        gameState = .retry
    }

    func retry() {
        timers[0].stopTicking()
        truck.stop()
        truck.reset()
        for life in lifes {
            life.show()
        }
        for egg in eggs {
            egg.removeFromParent()
        }
        henL.reset()
        henR.reset()
        eggs.removeAll(keepCapacity: true)
        lifeCount = maxLifes
        scoreLabel.set(0)
        level = 1
        hideAd()
        scoreBoard.hide()
        scoreLabel.show()
        gameState = .play
        timers[0]._interval = onPlayInterval
        dispatcher._rate = 9
    }

    func reset() {
        retry()
        gameState = .first
        message.show("TAP TO START!")
        for tap in taps {
            tap.show()
        }
    }

    func levelUp() {
        for tap in taps {
            tap.hide()
        }
        timers[1].startTicking()
        messages = ["GO!", "SET", "READY", "LEVEL \(level++)"]
        countDown = messages.count
        timers[0]._interval = max(NSTimeInterval(0.4), timers[0]._interval - NSTimeInterval(0.1))
        dispatcher._rate = max(1, dispatcher._rate - 1)
    }

    func offPlay() {
        if (countDown-- == 0) {
            message.hide()
            timers[1].stopTicking()
            timers[0].startTicking()
            pause.show()
        } else {
            message.show(messages[countDown])
        }
    }

    func onPlay() {
        henL.flip()
        if (henR.yPos == 0) {
            henR.flip()
        }
        if (truck.eggs.count == 9) {
            truck.start()
        } else if (truck.eggs.count == 10) {
            timers[0].stopTicking()
            let scoreTip = ScoreTip(parent: self)
            scoreTip.position = CGPoint(x:centerX, y:centerY)
            scoreTip.fontSize = 80
            scoreTip.show(scoreLabel.add(10, chance:gainLife))
            // remove edge entries
            /*
            for i in reverse(0..<eggs.count) {
                var egg = eggs[i]
                if (isOneOf(egg.currPos, [5, 13, 21, 29, 37, 45])) {
                    scoreLabel.add(1)
                    egg.removeFromParent()
                    eggs.removeAtIndex(i)
                }
            }*/
            henL.rest()
            henR.rest()
            truck.leave(levelUp)
            return
        }
        if (henL.henState != .catch) {
            henL.reset()
        }
        if (henR.henState != .catch) {
            henR.reset()
        }
        var lost = false
        for i in reverse(0..<eggs.count) { // TODO create reverseForEach generator
            var egg = eggs[i]
            if (egg.didFailL(henL.yPos) || egg.didFailR(henR.yPos)) {
                eggs.removeAtIndex(i)
                lostEggs.append(egg)
                lost = true
            } else if (egg.move(truck.toY, duration: timers[0]._interval)) {
                eggs.removeAtIndex(i)
                truck.eggs.append(egg)
            }
            if (egg.didScore()) {
                let scoreTip = ScoreTip(parent: self)
                scoreTip.position = egg.position
                scoreTip.show(scoreLabel.add(1, chance:gainLife))
                var hen = (egg.position.x < centerX) ? henL : henR
                hen.smile()
                if ((hen == henL && hen.yPos == 2) || (hen == henR && hen.yPos == 0)) {
                    hen.flipBack()
                }
            }
        }
        if (lost) {
            lostLife()
        }
        catchEgg()
        if (dispatcher.dispatch()) {
            eggs.append(Egg(parent: self, eggPoses: eggPoses))
        } else if (eggs.count == 0) {
            firstEgg()
        }
    }

    func catchEgg() {
        for egg in eggs {
            if ((egg.currPos == 13 && henL.yPos == 0) || (egg.currPos == 29 && henL.yPos == 1) || (egg.currPos == 45 && henL.yPos == 2)) {
                henL.catch()
            } else if ((egg.currPos == 5 && henR.yPos == 0) || (egg.currPos == 21 && henR.yPos == 1) || (egg.currPos == 37 && henR.yPos == 2)) {
                henR.catch()
            }
        }
    }

    func firstEgg() {
        /* Reduce the time to the first egg */
        eggs.append(Egg(parent: self, eggPoses: eggPoses))
        dispatcher.first()
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        if (gameState == .first) {
            message.hide()
            gameState = .play
            firstEgg()
            levelUp()
        } else if (gameState == .end) {
            reset()
            return
        }

        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node:SKNode = nodeAtPoint(location)
            if (node.name != nil) {
                var slServiceTypes = [
                    "Twitter": SLServiceTypeTwitter,
                    "Facebook": SLServiceTypeFacebook
                ]
                if (node.name == "pause") {
                    if (timers[0].toggle()) {
                        message.show("PAUSED")
                        paused = true
                    } else {
                        paused = false
                        message.hide()
                    }
                } else if (slServiceTypes.hasKey(node.name)) {
                    if (SLComposeViewController.isAvailableForServiceType(slServiceTypes[node.name!])) {
                        showTweet()
                        //var tweetSheet:SLComposeViewController = SLComposeViewController(forServiceType: slServiceTypes[node.name])
                        //tweetSheet.setInitialText("Got \(scoreLabel.score) on TapEgg!")
                        //self.presentViewController(tweetSheet, animated: true, completion: nil)
                    } else {
                        UIAlertView(title: "\(node.name!) Is Disabled >_<", message: "Please login from the iOS settings", delegate: nil, cancelButtonTitle: "OK").show()
                        return
                    }
                }
                break
            }
            if (!paused) {
                var hen = (location.x < centerX) ? henL : henR
                hen.move(location.y)
                if (hen == henR && hen.yPos != 0) {
                    hen.flipBack()
                } else {
                    hen.flip()
                }
            }
        }

        if (gameState == .retry) {
            retry()
            firstEgg()
            levelUp()
            return
        }
        catchEgg()
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for timer in timers {
            timer.tick()
        }
    }

    func showAd() {
        NSNotificationCenter.defaultCenter().postNotificationName("showAd", object:nil) // Sends message to viewcontroller to show ad.
    }

    func hideAd() {
        NSNotificationCenter.defaultCenter().postNotificationName("hideAd", object:nil) // Sends message to viewcontroller to hide ad.
    }

    func showTweet() {
        NSNotificationCenter.defaultCenter().postNotificationName("showTweet", object:nil)
    }
}
