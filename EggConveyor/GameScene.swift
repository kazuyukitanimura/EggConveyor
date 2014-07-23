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
        // steel
        let steel = SKSpriteNode(imageNamed: "steel")
        steel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - 4.0)
        steel.setScale(screenSize.width / steel.size.height) // ???
        self.addChild(steel)
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
