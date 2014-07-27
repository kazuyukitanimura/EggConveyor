//
//  GameScene.swift
//  EggConveyor
//
//  Created by Kazuyuki Tanimura on 7/22/14.
//  Copyright (c) 2014 Kazuyuki Tanimura. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let screenSize = UIScreen.mainScreen().bounds// * UIScreen.mainScreen().scale
    let screenHeight = UIScreen.mainScreen().bounds.height * UIScreen.mainScreen().scale

    override func didMoveToView(view: SKView) {
        // background
        let backGround = SKSpriteNode(imageNamed: "background")
        self.addChild(backGround)
        backGround.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))

        // tower
        let tower = SKSpriteNode(imageNamed: "tower")
        tower.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - 4.0)
        tower.setScale(screenSize.width / tower.size.height) // ???
        self.addChild(tower)

        // step
        let step1 = SKSpriteNode(imageNamed: "steel_01")
        let step2 = SKSpriteNode(imageNamed: "steel_02")
        let step3 = SKSpriteNode(imageNamed: "steel_03")
        let step4 = SKSpriteNode(imageNamed: "steel_04")
        let step5 = SKSpriteNode(imageNamed: "steel_05")
        let step7 = SKSpriteNode(imageNamed: "steel_07")
        step1.setScale(0.2)
        step2.setScale(0.2)
        step3.setScale(0.2)
        step4.setScale(0.2)
        step5.setScale(0.2)
        step7.setScale(0.2)
        step1.position = CGPoint(x:CGRectGetMidX(self.frame) * 0.4, y:self.frame.size.height * 0.15)
        step2.position = CGPoint(x:CGRectGetMidX(self.frame) * 0.4, y:self.frame.size.height * 0.45)
        step3.position = CGPoint(x:CGRectGetMidX(self.frame) * 0.4, y:self.frame.size.height * 0.75)
        step4.position = CGPoint(x:CGRectGetMidX(self.frame) * 1.7, y:self.frame.size.height * 0.00)
        step5.position = CGPoint(x:CGRectGetMidX(self.frame) * 1.7, y:self.frame.size.height * 0.30)
        step7.position = CGPoint(x:CGRectGetMidX(self.frame) * 1.7, y:self.frame.size.height * 0.60)
        self.addChild(step1)
        self.addChild(step2)
        self.addChild(step3)
        self.addChild(step4)
        self.addChild(step5)
        self.addChild(step7)

        // conveyor
        let conveyor1 = SKTexture(imageNamed: "conveyor_01")
        let conveyor2 = SKTexture(imageNamed: "conveyor_02")
        let conveyor3 = SKTexture(imageNamed: "conveyor_03")
        let anim = SKAction.animateWithTextures([conveyor1, conveyor2, conveyor3], timePerFrame: 0.2)
        let convey = SKAction.repeatActionForever(anim)
        var conveyor = SKSpriteNode(texture: conveyor1)
        conveyor.xScale = 0.4
        conveyor.yScale = -0.4
        conveyor.runAction(convey)
        conveyor.position = CGPoint(x:CGRectGetMaxX(self.frame) * 1.1, y:self.frame.size.height * 0.15)
        self.addChild(conveyor)
        for var i:Int = 0; i < 5; i++ {
            conveyor = conveyor.copy() as SKSpriteNode
            conveyor.xScale = conveyor.xScale * (1.0 - ((i & 0b01) << 1))
            conveyor.position = CGPoint(x:CGRectGetMidX(self.frame), y:self.frame.size.height * 0.15 * (i + 1))
            self.addChild(conveyor)
        }

        // truck
        let truck = SKSpriteNode(imageNamed: "truck_01")
        truck.setScale(0.3)
        truck.position = CGPoint(x:truck.size.width / 2.0, y:CGRectGetMidY(self.frame))
        self.addChild(truck)
        let gas = SKSpriteNode(imageNamed: "truck_02")
        gas.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeOutWithDuration(1.0), SKAction.fadeInWithDuration(1.0)])))
        gas.setScale(0.3)
        gas.position = CGPoint(x:truck.size.width + gas.size.width / 2.0, y:CGRectGetMidY(self.frame) - 16.0)
        self.addChild(gas)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
