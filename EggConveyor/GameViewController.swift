//
//  GameViewController.swift
//  SFChickens
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

class GameViewController: UIViewController, ADBannerViewDelegate {
    let adBannerView = ADBannerView(adType: .Banner)
    var adInterstitial:ADInterstitialAd!
    var _adView = UIView()
    var _button = UIButton(frame: CGRect(x: 10, y:  10, width: 40, height: 40))
    var gadInterstitial:GADInterstitial!
    var gadRequest:GADRequest = GADRequest()

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

        adBannerView.hidden = true
        adBannerView.frame = CGRectMake(0, 0, view.bounds.size.width, adBannerView.frame.height)
        adBannerView.center = CGPoint(x: adBannerView.frame.midX, y: adBannerView.frame.midY)
        adBannerView.delegate = self
        view.addSubview(adBannerView)
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
        let testDevices:NSArray = [GAD_SIMULATOR_ID]
        gadRequest.testDevices = testDevices
        gadRenew()
    }

    func gadRenew() {
        gadInterstitial = GADInterstitial()
        gadInterstitial.adUnitID = ADUNITID
        gadInterstitial.loadRequest(gadRequest)
    }

    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBannerView.hidden = UIDevice.currentDevice().userInterfaceIdiom != .Pad
    }

    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBannerView.hidden = true
    }

    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        /* pause when ad is clicked */
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            let skView = self.view as SKView
            skView.paused = true
        }
        return true
    }

    func bannerViewActionDidFinish(banner: ADBannerView!) {
        /* un-pause when ad is closed */
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            let skView = self.view as SKView
            skView.paused = false
        }
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
        } else {
            if (gadInterstitial.isReady) {
                gadInterstitial.presentFromRootViewController(self)
            }
            gadRenew()
        }
        adInterstitial = ADInterstitialAd()
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
            tweetSheet.setInitialText("Got score \(score!) on SFChickens! https://itunes.apple.com/us/app/sfchickens/id923871223")
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
