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
