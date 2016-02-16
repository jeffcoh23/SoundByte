//
//  FriendPlaylistViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 12/15/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Parse
import ConvenienceKit


class FriendPlaylistViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    @IBOutlet weak var likeButton: UIButton!
    var songBeingPlayedURI : String!
    var songDictionary: [NSURL : String] = [:]
    var viaSegue: String!
    var likes = [NSURL]?()
    let kClientID = "cf5b0855e8f440719ad3a1811e704fe3"
    let kCallbackURL = "soundbyte://return-after-login"
    //let kTokenSwapURL = "http://lochttp://localhost:1234/refreshalhost:1234/swap"
    //let kTokenRefreshURL = ""
    var queuePlayer: AVQueuePlayer!
    var player: SPTAudioStreamingController!
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    var songsArray = [AVPlayerItem]()
    var IDArray = [String]()
    var audioPlayer = AVPlayer()
    // All necessary labels including image views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var shadedCoverView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func wasSongAlreadyLiked(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            var pointer = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()!.objectId!)
            // _ = PFUser.query()
            var likesQuery = PFQuery(className: "Like")
            if (likesQuery.countObjects(nil) > 1){
            var newLikesQuery = likesQuery.whereKey("likedSongURI", equalTo: self.songBeingPlayedURI)
            var finalQuery = newLikesQuery.whereKey("fromUser", equalTo: pointer)
            
           // dispatch_async(dispatch_get_main_queue(), {() -> Void in
                if (finalQuery.countObjectsInBackground() != 0){
                    self.likeButton.selected = true
                }
                else{
                    self.likeButton.selected = false
                }
         //   })
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        wasSongAlreadyLiked()
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: "sessionUpdated", object: nil)
        
        super.viewDidLoad()
        self.titleLabel.text = "Nothing Playing"
        self.albumLabel.text = ""
        self.artistLabel.text = ""
        
        let selectedFriendQuery = PFUser.query()!
        _ = selectedFriendQuery.whereKey("username", equalTo: viaSegue)
        let selectedFriendName = try! selectedFriendQuery.getFirstObject()
        let userSelectedFriendName = selectedFriendName.objectId
        
        let playlistFromFollowedUsers = PFQuery(className: "Playlist")
        let pointer = PFObject(withoutDataWithClassName: "_User", objectId: userSelectedFriendName)
        playlistFromFollowedUsers.whereKey("user", equalTo: pointer)
        self.queuePlayer = AVQueuePlayer()
           // AVQueuePlayer(items: nil)

        playlistFromFollowedUsers.findObjectsInBackgroundWithBlock({
            
            (result: [PFObject]?, error: NSError?) -> Void in
            
            var songIDs = result as [PFObject]!
            
            if songIDs.count < 1{
                return
            }
            else{
               
                for i in 0...songIDs.count-1{
                   _ = songIDs[i].valueForKey("spotifyTrackNumber") as! String
                    self.IDArray.append(songIDs[i].valueForKey("spotifyTrackNumber") as! String)
                    let apiURL = "https://api.spotify.com/v1/tracks/\(self.IDArray[i])"
                    let url = NSURL(string: apiURL)
                    
                    let urlRequest = NSMutableURLRequest(URL: url!) as NSMutableURLRequest
                    //let headersAuth = NSString(format: "Bearer %@", spotifyAuthenticator.session.accessToken)
                    //urlRequest.setValue(headersAuth as? String, forHTTPHeaderField: "Authorization")
                    
                    let queue = NSOperationQueue()
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue, completionHandler: {(response: NSURLResponse?, recievedData: NSData?, error: NSError?) -> Void in
                        if error != nil{
                            print(error!.localizedDescription)
                        }
                        else{
                            var err : NSError? = nil
                            let jsonResult : NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(recievedData!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                            if err == nil{
                                let songPreview = jsonResult.objectForKey("preview_url") as! String
                                let songURI = jsonResult.objectForKey("uri") as! String
                                var asset: AVURLAsset = AVURLAsset(URL: (NSURL(string: songPreview))!, options: nil)
                                var playerItem = AVPlayerItem(asset: asset)
                                
                                self.queuePlayer.insertItem(playerItem, afterItem: self.queuePlayer.items().last as? AVPlayerItem! ?? self.queuePlayer.items().first)
                                self.songDictionary.updateValue(songURI, forKey:  playerItem.valueForKey("URL") as! NSURL)
                                if (self.queuePlayer.items().count <= 1) {
                                    self.updateUI(NSURL(string: songURI))
                                    self.songBeingPlayedURI = songURI
                                }
                            }
                            else{
                                print(err?.localizedDescription)
                            }
                        }
                    })
                   
                    
                }
            }
            self.queuePlayer.addObserver(self, forKeyPath: "currentItem", options: [.New, .Initial], context: &self.songDictionary)
            self.queuePlayer.play()

            
        })
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentItem", let player = object as? AVPlayer,
        currentItem = player.currentItem?.asset as? AVURLAsset {
            let newSongURI = self.songDictionary[currentItem.valueForKey("URL") as! NSURL]
            if newSongURI != nil{
             self.updateUI(NSURL(string: newSongURI!))
             self.songBeingPlayedURI = newSongURI
             
             wasSongAlreadyLiked()
            }
            
        }
    }
    
    
    func updateUI(uriTrack: NSURL!){
        let auth: SPTAuth = SPTAuth.defaultInstance()
        if uriTrack == nil{
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
            let imageURL = track.album.largestCover.imageURL
            if imageURL == nil{
                NSLog("This album doesnt have any images!", track.album)
                self.coverView.image = nil
                self.shadedCoverView.image = nil
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{() -> Void in
                var error: NSError? = nil
                var image: UIImage? = nil
                let imageData = NSData(contentsOfURL: imageURL)
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
    
    @IBAction func likeButtonClicked(sender: AnyObject) {
        let pointer = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()!.objectId!)
        var query = PFUser.query()
        let likesQuery = PFQuery(className: "Like")
        let newLikesQuery = likesQuery.whereKey("likedSongURI", equalTo: self.songBeingPlayedURI)
        let finalQuery = newLikesQuery.whereKey("fromUser", equalTo: pointer)
        if (finalQuery.countObjectsInBackground() == 0){
            let likeObject = PFObject(className: "Like")
            likeObject.setObject(self.songBeingPlayedURI, forKey: "likedSongURI")
            likeObject.setObject(PFUser.currentUser()!, forKey: "fromUser")
            likeObject.saveEventually()
            self.likeButton.selected = true
        }
        else{
            finalQuery.findObjectsInBackgroundWithBlock {( results: [PFObject]?, error: NSError?) -> Void in
                if let results = results as? [PFObject]!{
                    for likes in results{
                        likes.delete(nil) //deleteInBackgroundWithBlock(nil)
                    }
                    
                }
            }
            self.likeButton.selected = false
        }
    }
    
    @IBAction func exitButton(sender: AnyObject) {
        self.queuePlayer.pause()
    }
    
    @IBAction func nextSongButton(sender: AnyObject) {
//        NSLog("\(self.queuePlayer.items().count-1)")
//        NSLog("\(self.queuePlayer.items().endIndex)")
//        if (self.queuePlayer.items().endIndex == 1){
//            self.queuePlayer.items().first
//            //return
//        }
        self.queuePlayer.advanceToNextItem()
    }
    
    @IBAction func previousSongButton(sender: AnyObject) {
      //self.queuePlayer.items().
    }
    
    
    @IBAction func playAndPauseButton(sender: AnyObject) {
        if self.queuePlayer.rate == 1.0{
            self.queuePlayer.pause()
        }
        else if (self.queuePlayer.rate == 0.0){
            self.queuePlayer.play()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

