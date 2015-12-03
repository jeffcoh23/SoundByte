//
//  TimelineViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 12/1/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import AVFoundation
import UIKit
import Parse
import AVKit

public var AudioPlayer = AVPlayer()
public var SelectedSongNumber = Int()

class TimelineViewController: UIViewController, AVAudioPlayerDelegate{
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBOutlet weak var tableView: UITableView!
    
    
    var IDArray = [String]()
    var NameArray = [String]()
    override func viewDidLoad() {
        //super.viewDidLoad()
    
    
    let followingQuery = PFQuery(className: "Follow")
    NSLog("\(PFUser.currentUser())")
    followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
    let playlistFromFollowedUsers = PFQuery(className: "Playlist")
        playlistFromFollowedUsers.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
    
    //playlistFromFollowedUsers.includeKey("user")
    //playlistFromFollowedUsers.orderByAscending("username")
    
    
        
    playlistFromFollowedUsers.findObjectsInBackgroundWithBlock({
        
        (result: [AnyObject]?, error: NSError?) -> Void in
        
        var songIDs = result as! [PFObject]
        for i in 0...songIDs.count-1{
            self.IDArray.append(songIDs[i].valueForKey("objectId") as! String)
            self.NameArray.append(songIDs[i].valueForKey("songName") as! String)
            self.tableView.reloadData()
        }
        
        })
    }
    
    func grabSong(){
        var SongQuery = PFQuery(className: "Playlist")
        NSLog("\(SongQuery)")
        SongQuery.getObjectInBackgroundWithId(IDArray[SelectedSongNumber], block: {
            (object : PFObject?, error: NSError?) -> Void in
            
            //If this is a song file
            if let AudioFileURLTemp = object?.objectForKey("songFile")?.url{
                AudioPlayer = AVPlayer(URL: NSURL(string: AudioFileURLTemp!))
                AudioPlayer.play()
            }
        })
    }
}

extension TimelineViewController: UITableViewDataSource {
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return IDArray.count
        }
    
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

            var cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! UITableViewCell
            
            cell.textLabel!.text = NameArray[indexPath.row]
            
            return cell
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
            SelectedSongNumber = indexPath.row

            grabSong()
        }
    

    
    }

