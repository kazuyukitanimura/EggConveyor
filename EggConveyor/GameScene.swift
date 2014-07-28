//
//  GameScene.swift
//  EggConveyor
//
//  Created by Kazuyuki Tanimura on 7/22/14.
//  Copyright (c) 2014 Kazuyuki Tanimura. All rights reserved.
//

import SpriteKit

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
        conveyor.position = CGPoint(x:CGRectGetMaxX(self.frame) * 1.1, y:self.frame.size.height * 0.15)
        self.addChild(conveyor)
        for (var i:Int = 0; i < 5; i++) {
            conveyor = conveyor.copy() as SKSpriteNode
            conveyor.xScale = conveyor.xScale * (1.0 - ((i & 0b01) << 1))
            conveyor.position = CGPoint(x:centerX, y:self.frame.size.height * 0.15 * (i + 1))
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

        // message
        message = SKLabelNode(fontNamed:"Chalkduster")
        message.text = "TAP TO START!"
        message.fontSize = 65
        message.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(message)
    }

    func flip(node: SKSpriteNode) {
        node.xScale = -node.xScale
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        message.removeFromParent()
        
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
            } else { // right hen
                if (location.y > step6Y) {
                    henR.position.y = step6Y
                } else if (location.y > step5Y) {
                    henR.position.y = step5Y
                } else {
                    henR.position.y = step4Y
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
