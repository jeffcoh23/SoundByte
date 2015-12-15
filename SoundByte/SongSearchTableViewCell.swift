//
//  SongSearchTableViewCell.swift
//  SoundByte
//
//  Created by Jeff Cohen on 12/11/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit
import Parse

protocol SongSearchTableViewCellDelegate: class {
    func cell(cell: SongSearchTableViewCell, didSelectFollowSong song: AnyObject?)
  //  func cell(cell: SongSearchTableViewCell, didSelectUnfollowSong song: String)
}

class SongSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var songSearchLabel: UILabel!
    @IBOutlet weak var addSongSearchButton: UIButton!
    weak var delegate: SongSearchTableViewCellDelegate?
    
    //    @IBAction func followButtonTapped(sender: AnyObject) {
    //        if let canFollow = canFollow where canFollow == true {
    //            delegate?.cell(self, didSelectFollowUser: user!)
    //            self.canFollow = false
    //        } else {
    //            delegate?.cell(self, didSelectUnfollowUser: user!)
    //            self.canFollow = true
    //        }
    //    }
    //}
//
    var songURI: AnyObject?
//    func grabSong(){
//        if let currentUser = PFUser.currentUser(){
//            delegate?.cell(self,)
//            let songQuery = PFQuery(className: "Playlist")
//            songQuery!["spotifyTrackNumber"] =
//        }
//    }
//    
    @IBAction func songFollowButtonTapped(sender: AnyObject) {
        NSLog("\(songURI)")
        delegate?.cell(self, didSelectFollowSong: songURI!)


        ParseHelper.addFollowSongRelationshipToUser(songURI!, user: PFUser.currentUser()!)
        //ParseHelper.addFollowSongRelationshipToUser(songSearchLabel.text!, user: PFUser.currentUser()!)
//        PFUser.currentUser()?.saveInBackgroundWithBlock{
//            succeeded, error in
//            if succeeded{
//                
//            }
//        }
//    }
    }
}
