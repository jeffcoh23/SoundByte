//
//  FriendPlaylistViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 12/15/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit

class FriendPlaylistViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingPlaybackDelegate {

    let kClientID = "cf5b0855e8f440719ad3a1811e704fe3"
    let kCallbackURL = "soundbyte://return-after-login"
    //let kTokenSwapURL = "http://localhost:1234/swap"
    //let kTokenRefreshURL = "http://localhost:1234/refresh"
    
    var player: SPTAudioStreamingController!
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    var IDArray = [String]()
    
    // All necessary labels including image views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var shadedCoverView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
       // func loginWithSpotify() {
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
        //loginWithSpotify(nil)

    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        println("login cancelled")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        println("login failed")
    }
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        //loginWithSpotify(nil)
        self.titleLabel.text = "Nothing Playing"
        self.albumLabel.text = ""
        self.artistLabel.text = ""
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        let playlistFromFollowedUsers = PFQuery(className: "Playlist")
        playlistFromFollowedUsers.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        playlistFromFollowedUsers.findObjectsInBackgroundWithBlock({
            
            (result: [AnyObject]?, error: NSError?) -> Void in
            
            
            var songIDs = result as! [PFObject]
            if songIDs.count < 1{
                return
            }
            else{
                for i in 0...songIDs.count-1{
                    self.IDArray.append(songIDs[i].valueForKey("spotifyTrackNumber") as! String)
                    //self.tableView.reloadData()
                    
                }
            }
            
        })
    }
    
    func grabSong(){
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        let playlistFromFollowedUsers = PFQuery(className: "Playlist")
        playlistFromFollowedUsers.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        var spotifyURIArray = [NSURL]()
        for i in 0...IDArray.count-1{
            spotifyURIArray.append(NSURL(string: IDArray[i])!)
            //let SpotifyURI = [NSURL(string: IDArray[i])!]
            
            //NSLog("\(SpotifyURI)")
            //NSLog("\(IDArray)")
            self.player!.playURIs(spotifyURIArray, fromIndex: 0) { (error) -> Void in
                    if let error = error {
                        println(error)
                                //self.log(String(format: "playURIs error: %@", error))
                    }
            }

            //self.player!.playURIs([NSURL(string: SpotifyURI)!], withOptions: nil, callback: nil)
        }
    }
    
//    func grabSong(){
//       // let uris = SPTTrack.urisFromArray(IDArray)
//        //NSLog("\(uris)")
//        self.player.playURIs(IDArray, fromIndex: 0) { (error) -> Void in
//            if let error = error {
//                println(error)
//                //self.log(String(format: "playURIs error: %@", error))
//            }
//        }
////        for i in 0...IDArray.count-1{
////            //var SpotifyURI = IDArray[i]
////            let uris = SPTTrack.urisFromArray(IDArray)
////            self.player!.playURIs(uris, withOptions: nil, callback: nil)
////        }
//    }


    // SPTAudioStreamingPlaybackDelegate protocol methods
    
    private
    
    func setupSpotifyPlayer() {
        player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID) // can also use kClientID; they're the same value
        player!.playbackDelegate = self
        player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
    }
    
    func loginWithSpotifySession(session: SPTSession) {
//        if spotifyAuthenticator.session.accessToken != nil{
//            self.spotifyLoginButton.hidden = true
//        }
        
        player!.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                println("Couldn't login with session: \(error)")
                return
            }
            self.grabSong()
            
        })
    }

        
        
        // Do any additional setup after loading the view.
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Buttons for playing, pausing, rewinding, and fast-forwarding


    
    @IBAction func playPauseButtonTapped(sender: AnyObject) {
        self.player.setIsPlaying(!self.player.isPlaying, callback: nil)
    }
    @IBAction func rewindButtonTapped(sender: AnyObject) {
        self.player?.skipPrevious(nil)
    }
    
    @IBAction func fastForwardButtonTapped(sender: AnyObject) {
        self.player?.skipNext(nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
