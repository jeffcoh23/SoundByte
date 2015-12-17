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
    
    override func viewDidLoad() {
        //super.viewDidLoad()
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
                }
            }
            
        })
    }
    
    func grabSong(){
        var spotifyURIArray = [NSURL]()
        for i in 0...IDArray.count-1{
            spotifyURIArray.append(NSURL(string: IDArray[i])!)
        }
           // NSLog("\(spotifyURIArray)")
            self.player!.playURIs(spotifyURIArray, fromIndex: 1) { (error) -> Void in
                    if let error = error {
                        println(error)
                    }
//                    else{
//                        //NSLog("yo")
                        self.updateUI(self.player.currentTrackURI)
//
//                }
            }

        //}
    }
    
    func updateUI(uriTrack: NSURL!){
        //NSLog("\(self.player.currentTrackURI)")
        var auth: SPTAuth = SPTAuth.defaultInstance()
        if uriTrack == nil{
            NSLog("sdf")
            self.coverView.image = nil
            //self.shadedCoverView.image = nil
            return
        }
        self.spinner.startAnimating()
        SPTTrack.trackWithURI(uriTrack, session: auth.session) { (error, track) -> Void in
            if let track = track as? SPTTrack, artist = track.artists.first as? SPTPartialArtist{
            self.titleLabel.text = track.name
            self.albumLabel.text = track.album.name
            //var artist = track.artists[0] as! SPTPartialTrack
            self.artistLabel.text = artist.name
            var imageURL = track.album.largestCover.imageURL
            if imageURL == nil{
                NSLog("This album doesnt have any images!", track.album)
                self.coverView.image = nil
                self.shadedCoverView.image = nil
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{() -> Void in
                var error: NSError? = nil
                var image: UIImage? = nil
                var imageData = NSData(contentsOfURL: imageURL)
                if imageData != nil{
                    image = UIImage(data: imageData!)
                }
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.spinner.stopAnimating()
                    self.coverView.image = image
                    if image == nil{
                        NSLog("Couldnt load cover image ")
                        return
                    }
                    })
                //var blurred: UIImage = self.applyBlurOnImage(image!, withRadius: 10.0)
//                dispatch_async(dispatch_get_main_queue(), {() -> Void in
//                    self.shadedCoverView.image = blurred
//                })
            })
        }
        }
    }
    

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
            //NSLog("\(self.player.currentTrackURI)")

            
        })
    }

        
        
        // Do any additional setup after loading the view.
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Buttons for playing, pausing, rewinding, and fast-forwarding


    
    @IBAction func playPauseButtonTapped(sender: AnyObject) {
        self.player.setIsPlaying(!self.player.isPlaying, callback: nil)
        self.updateUI(self.player.currentTrackURI)

    }
    @IBAction func rewindButtonTapped(sender: AnyObject) {
        //NSLog("\(self.player.currentTrackURI)")
        self.player?.skipPrevious(nil)
        self.updateUI(self.player.currentTrackURI)
       // NSLog("\(self.player.currentTrackURI)")



    }
    
    @IBAction func fastForwardButtonTapped(sender: AnyObject) {
        //the problem is that the spotify track number does not update after the skipNext is called, so the 
        // updating does not really happen
        NSLog("\(self.player.currentTrackURI)")

        self.player?.skipNext(nil)
        updateUI(self.player.currentTrackURI)
        NSLog("\(self.player.currentTrackURI)")



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
