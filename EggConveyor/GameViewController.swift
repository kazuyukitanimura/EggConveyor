//
//  GameViewController.swift
//  EggConveyor
//
//  Created by Kazuyuki Tanimura on 7/22/14.
//  Copyright (c) 2014 Kazuyuki Tanimura. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        var sceneData = NSData.dataWithContentsOfFile(path!, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController {
    let adBannerView = ADBannerView(frame: CGRect.zeroRect)

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }

        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
        //adBannerView.delegate = self
        adBannerView.hidden = true
        adBannerView.frame = CGRectOffset(adBannerView.frame, 0, 0.0)
        self.view.addSubview(adBannerView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"hideAd:", name:"hideAd", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"showAd:", name:"showAd", object:nil)
    }

    // Handle Notification
    // http://stackoverflow.com/questions/21664295/hide-show-iads-in-spritekit
    func hideAd(notification: NSNotification) {
        adBannerView.hidden = true
    }
    func showAd(notification: NSNotification) {
        adBannerView.hidden = false
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
