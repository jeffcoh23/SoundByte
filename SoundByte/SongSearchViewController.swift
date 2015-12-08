//
//  SongSearchViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 12/7/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit


//run "ruby spotify_token_swap.rb" to launch server

class SongSearchViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingPlaybackDelegate {

    let kClientID = "cf5b0855e8f440719ad3a1811e704fe3"
    let kCallbackURL = "soundbyte://return-after-login"
    //let kTokenSwapURL = "http://localhost:1234/swap"
    //let kTokenRefreshURL = "http://localhost:1234/refresh"
    
    var player: SPTAudioStreamingController?
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    
    @IBOutlet weak var spotifyLoginButton: UIButton!
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
        setupSpotifyPlayer()
        loginWithSpotifySession(session)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        println("login cancelled")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        println("login failed")
    }
    
    // SPTAudioStreamingPlaybackDelegate protocol methods
    
    private
    
    func setupSpotifyPlayer() {
        player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID) // can also use kClientID; they're the same value
        player!.playbackDelegate = self
        player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
    }
    
    func loginWithSpotifySession(session: SPTSession) {
        player!.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                println("Couldn't login with session: \(error)")
                return
            }
            self.spotifyLoginButton.hidden = true
            self.useLoggedInPermissions()
        })
    }
    
    func useLoggedInPermissions() {
        let spotifyURI = "spotify:track:1WJk986df8mpqpktoktlce"
        player!.playURIs([NSURL(string: spotifyURI)!], withOptions: nil, callback: nil)
    }
}