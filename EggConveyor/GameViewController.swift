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
    let adBannerView = ADBannerView(adType: .Banner)
    var adInterstitial:ADInterstitialAd!
    var _adView = UIView()
    var _button = UIButton(frame: CGRect(x: 10, y:  10, width: 40, height: 40))

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

        adBannerView.center = CGPoint(x: adBannerView.frame.midX, y: adBannerView.frame.midY)
        adBannerView.hidden = UIDevice.currentDevice().userInterfaceIdiom != .Pad
        adBannerView.frame = CGRectOffset(adBannerView.frame, 0, 0.0)
        //adBannerView.adType = ADAdType.MediumRectangle
        self.view.addSubview(adBannerView)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:"hideAd:", name:"hideAd", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"showAd:", name:"showAd", object:nil)
        for key in slServiceTypes.keys {
            NSNotificationCenter.defaultCenter().addObserver(self, selector:"showSocial:", name:key, object:nil)
        }

        adInterstitial = ADInterstitialAd()
        _adView.frame = self.view.bounds
        _adView.hidden = true
        self.view.addSubview(_adView)
        _button.setBackgroundImage(UIImage(named: "close"), forState: UIControlState.Normal)
        _button.addTarget(self, action: Selector("close"), forControlEvents: UIControlEvents.TouchDown)
        _button.hidden = true
        self.view.addSubview(_button)
      }

    // Handle Notification
    // http://stackoverflow.com/questions/21664295/hide-show-iads-in-spritekit
    //func hideAd(notification: NSNotification) {
    //}
    func showAd(notification: NSNotification) {
        if (adInterstitial.loaded) {
            // http://stackoverflow.com/questions/25285344/interstitialad-ios-8-beta-5-does-not-provide-x-close-button-in-simulator
            _adView.hidden = false
            _button.hidden = false
            adInterstitial.presentInView(_adView)
        }
    }
    func close() {
        _adView.hidden = true
        _button.hidden = true
        adInterstitial = ADInterstitialAd()
    }
    func showSocial(notification: NSNotification) {
        if (SLComposeViewController.isAvailableForServiceType(slServiceTypes[notification.name])) {
            var tweetSheet:SLComposeViewController = SLComposeViewController(forServiceType: slServiceTypes[notification.name])
            var score: AnyObject? = notification.userInfo!["score"]
            tweetSheet.setInitialText("Got score \(score!) on Operation Eggs!")
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
