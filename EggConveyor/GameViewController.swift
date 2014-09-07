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
import Social

var slServiceTypes = [
  "Twitter": SLServiceTypeTwitter,
  "Facebook": SLServiceTypeFacebook
]

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

        adBannerView.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        adBannerView.hidden = true
        adBannerView.frame = CGRectOffset(adBannerView.frame, 0, 0.0)
        //adBannerView.adType = ADAdType.MediumRectangle
        self.view.addSubview(adBannerView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"hideAd:", name:"hideAd", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"showAd:", name:"showAd", object:nil)
        for key in slServiceTypes.keys {
            NSNotificationCenter.defaultCenter().addObserver(self, selector:"showSocial:", name:key, object:nil)
        }
      }

    // Handle Notification
    // http://stackoverflow.com/questions/21664295/hide-show-iads-in-spritekit
    func hideAd(notification: NSNotification) {
        adBannerView.hidden = true
    }
    func showAd(notification: NSNotification) {
        adBannerView.hidden = false
    }
    func showSocial(notification: NSNotification) {
        if (SLComposeViewController.isAvailableForServiceType(slServiceTypes[notification.name])) {
          var tweetSheet:SLComposeViewController = SLComposeViewController(forServiceType: slServiceTypes[notification.name])
          //tweetSheet.setInitialText("Got  \(notification.object) on TapEgg!")
          tweetSheet.setInitialText("Got on TapEgg!")
          self.presentViewController(tweetSheet, animated: true, completion: nil)
        } else {
            UIAlertView(title: "\(notification.name) Is Disabled >_<", message: "Please login from the iOS settings", delegate: nil, cancelButtonTitle: "OK").show()
        }
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
