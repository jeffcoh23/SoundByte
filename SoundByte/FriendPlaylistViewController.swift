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



class FriendPlaylistViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    var blankshit : String!
    var songDictionary: [NSURL : String] = [:]
    var viaSegue: String!
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
    

    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: "sessionUpdated", object: nil)
        
        super.viewDidLoad()
        self.titleLabel.text = "Nothing Playing"
        self.albumLabel.text = ""
        self.artistLabel.text = ""
        
        let selectedFriendQuery = PFUser.query()!
        var selectedFriendUsername = selectedFriendQuery.whereKey("username", equalTo: viaSegue)
        var selectedFriendName = selectedFriendQuery.getFirstObject()
        var userSelectedFriendName = selectedFriendName!.objectId
        
        let playlistFromFollowedUsers = PFQuery(className: "Playlist")
        let pointer = PFObject(withoutDataWithClassName: "_User", objectId: userSelectedFriendName)
        playlistFromFollowedUsers.whereKey("user", equalTo: pointer)
        self.queuePlayer = AVQueuePlayer(items: nil)

        playlistFromFollowedUsers.findObjectsInBackgroundWithBlock({
            
            (result: [AnyObject]?, error: NSError?) -> Void in
            
            var songIDs = result as! [PFObject]
            
            if songIDs.count < 1{
                return
            }
            else{
               
                for i in 0...songIDs.count-1{
                   var songPrev = songIDs[i].valueForKey("spotifyTrackNumber") as! String
                    self.IDArray.append(songIDs[i].valueForKey("spotifyTrackNumber") as! String)
                    let apiURL = "https://api.spotify.com/v1/tracks/\(self.IDArray[i])"
                    let url = NSURL(string: apiURL)
                    
                    var urlRequest = NSMutableURLRequest(URL: url!) as NSMutableURLRequest
                    //let headersAuth = NSString(format: "Bearer %@", spotifyAuthenticator.session.accessToken)
                    //urlRequest.setValue(headersAuth as? String, forHTTPHeaderField: "Authorization")
                    
                    let queue = NSOperationQueue()
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue, completionHandler: {(response: NSURLResponse!, recievedData: NSData!, error: NSError!) -> Void in
                        if error != nil{
                            println(error.localizedDescription)
                        }
                        else{
                            var err : NSError? = nil
                            let jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(recievedData, options: NSJSONReadingOptions.AllowFragments, error: &err) as! NSDictionary
                            if err == nil{
                                let songPreview = jsonResult.objectForKey("preview_url") as! String
                                let songURI = jsonResult.objectForKey("uri") as! String
                                //NSLog("\(songURI)")
                                var asset: AVURLAsset = AVURLAsset(URL: (NSURL(string: songPreview)), options: nil)
                                var playerItem = AVPlayerItem(asset: asset)
                                
                                self.queuePlayer.insertItem(playerItem, afterItem: self.queuePlayer.items().last as? AVPlayerItem)
                                self.songDictionary.updateValue(songURI, forKey:  playerItem.valueForKey("URL") as! NSURL)
                                if (self.queuePlayer.items().count <= 1) {
                                    self.updateUI(NSURL(string: songURI))
                                }
                            }
                            else{
                                println(err?.localizedDescription)
                            }
                        }
                    })
                   
                    
                }
            }
            self.queuePlayer.addObserver(self, forKeyPath: "currentItem", options: .New | .Initial, context: &self.songDictionary) //Send dictionary object in context
            self.queuePlayer.play()

            
        })
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentItem", let player = object as? AVPlayer,
        currentItem = player.currentItem?.asset as? AVURLAsset {
            var newSongURI = self.songDictionary[currentItem.valueForKey("URL") as! NSURL]
            if newSongURI != nil{
             self.updateUI(NSURL(string: newSongURI!))
            }
        }
    }
    
    
    func updateUI(uriTrack: NSURL!){
        var auth: SPTAuth = SPTAuth.defaultInstance()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

