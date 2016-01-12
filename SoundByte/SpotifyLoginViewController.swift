//
//  SpotifyLoginViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 1/12/16.
//  Copyright (c) 2016 Jeff Cohen. All rights reserved.
//

import UIKit

class SpotifyLoginViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingPlaybackDelegate {
    
    let kClientID = "cf5b0855e8f440719ad3a1811e704fe3"
    let kCallbackURL = "soundbyte://return-after-login"
    //let kTokenSwapURL = "http://localhost:1234/swap"
    //let kTokenRefreshURL = "http://localhost:1234/refresh"
    
    var player: SPTAudioStreamingController?
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    let spotifyLoginViewControllerSegue = "SpotifyLoginSuccessful"
    
    override func viewDidLoad(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionUpdatedNotification", name: "sessionUpdated", object: nil)
        var auth: SPTAuth = SPTAuth.defaultInstance()
        if auth.session != nil{
            self.performSegueWithIdentifier(self.spotifyLoginViewControllerSegue, sender: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        var auth: SPTAuth = SPTAuth.defaultInstance()
        if (auth.session == nil){
            return
        }
        
        //check if auth is still valid
        if (auth.session.isValid()){
            self.performSegueWithIdentifier(spotifyLoginViewControllerSegue, sender: nil)
        }
        
        if (auth.hasTokenRefreshService){
            self.renewTokenAndShowPlayer()
            return
        }
    }
    
    func renewTokenAndShowPlayer(){
        var auth: SPTAuth = SPTAuth.defaultInstance()
        auth.renewSession(auth.session, callback:{(error: NSError!, session: SPTSession!) -> Void in
            auth.session = session
            if error != nil{
                NSLog("***Error renewing session: %@", error)
                return
            }
            self.performSegueWithIdentifier(self.spotifyLoginViewControllerSegue, sender: nil)
        })
    }
    
    func sessionUpdatedNotification (notification: NSNotification) -> Void{
        if self.navigationController?.topViewController == self{
            var auth: SPTAuth = SPTAuth.defaultInstance()
            if auth.session.isValid(){
                self.performSegueWithIdentifier(spotifyLoginViewControllerSegue, sender: nil)
                
            }
        }
    }
    
    
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        spotifyAuthenticator.clientID = kClientID
        spotifyAuthenticator.requestedScopes = [SPTAuthStreamingScope]
        spotifyAuthenticator.redirectURL = NSURL(string: kCallbackURL)
        // spotifyAuthenticator.tokenSwapURL = NSURL(string: kTokenSwapURL)
        //spotifyAuthenticator.tokenRefreshURL = NSURL(string: kTokenRefreshURL)
        let spotifyAuthenticationViewController = SPTAuthViewController.authenticationViewController()
        spotifyAuthenticationViewController.delegate = self
        spotifyAuthenticationViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        spotifyAuthenticationViewController.definesPresentationContext = true
        presentViewController(spotifyAuthenticationViewController, animated: false, completion: nil)
    }
    
    // SPTAuthViewDelegate protocol methods
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        var auth: SPTAuth = SPTAuth.defaultInstance()
        self.performSegueWithIdentifier(spotifyLoginViewControllerSegue, sender: nil)
        setupSpotifyPlayer()
        loginWithSpotifySession(auth.session)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        println("login cancelled")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        println("login failed")
    }
    
    private
    
    func setupSpotifyPlayer() {
        player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID) // can also use kClientID; they're the same value
        player!.playbackDelegate = self
        player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
    }
    
    
    func loginWithSpotifySession(session: SPTSession) {
        if spotifyAuthenticator.session.accessToken != nil{
            self.performSegueWithIdentifier(self.spotifyLoginViewControllerSegue, sender: nil)
        }
        player!.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                println("Couldn't login with session: \(error)")
                return
            }
            
            
        })
    }
}
    
