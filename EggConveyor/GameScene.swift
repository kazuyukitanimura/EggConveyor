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
    
    override func didMoveToView(view: SKView) {
        let centerX = CGRectGetMidX(self.frame)
        let centerY = CGRectGetMidY(self.frame)
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
        let step7 = SKSpriteNode(imageNamed: "steel_07")
        let stepScale:CGFloat = 0.2
        step1.setScale(stepScale)
        step2.setScale(stepScale)
        step3.setScale(stepScale)
        step4.setScale(stepScale)
        step5.setScale(stepScale)
        step7.setScale(stepScale)
        step1.position = CGPoint(x:centerX * 0.4, y:self.frame.size.height * 0.15)
        step2.position = CGPoint(x:centerX * 0.4, y:self.frame.size.height * 0.45)
        step3.position = CGPoint(x:centerX * 0.4, y:self.frame.size.height * 0.75)
        step4.position = CGPoint(x:centerX * 1.6, y:self.frame.size.height * 0.00)
        step5.position = CGPoint(x:centerX * 1.6, y:self.frame.size.height * 0.30)
        step7.position = CGPoint(x:centerX * 1.6, y:self.frame.size.height * 0.60)
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
        let conveyorScale:CGFloat = 0.4
        conveyor.xScale = conveyorScale
        conveyor.yScale = -conveyorScale
        conveyor.runAction(convey)
        conveyor.position = CGPoint(x:CGRectGetMaxX(self.frame) * 1.1, y:self.frame.size.height * 0.15)
        self.addChild(conveyor)
        for var i:Int = 0; i < 5; i++ {
            conveyor = conveyor.copy() as SKSpriteNode
            conveyor.xScale = conveyor.xScale * (1.0 - ((i & 0b01) << 1))
            conveyor.position = CGPoint(x:centerX, y:self.frame.size.height * 0.15 * (i + 1))
            self.addChild(conveyor)
        }

        // truck
        let truck = SKSpriteNode(imageNamed: "truck_01")
        let truckScale:CGFloat = 0.3
        truck.setScale(truckScale)
        truck.position = CGPoint(x:truck.size.width * 0.5, y:ground + truck.size.height * 0.5)
        self.addChild(truck)
        let gas = SKSpriteNode(imageNamed: "truck_02")
        gas.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeOutWithDuration(1.0), SKAction.fadeInWithDuration(1.0)])))
        gas.setScale(truckScale)
        gas.position = CGPoint(x:truck.size.width + gas.size.width * 0.5, y:ground + gas.size.height * 0.5 + 2.0)
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
