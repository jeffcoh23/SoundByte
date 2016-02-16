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
    func cell(cell: SongSearchTableViewCell, didSelectUnFollowSong song: AnyObject?)
}

class SongSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var artistSearchLabel: UILabel!
    @IBOutlet weak var songSearchLabel: UILabel!
    @IBOutlet weak var addSongSearchButton: UIButton!
    weak var delegate: SongSearchTableViewCellDelegate?
 

    var songURI: AnyObject?

    var canFollow: Bool? = true {
        didSet {
            /*
            Change the state of the follow button based on whether or not
            it is possible to follow a user.
            */
            if let canFollow = canFollow {
                addSongSearchButton.selected = !canFollow
            }
        }
    }


    @IBAction func songFollowButtonTapped(sender: AnyObject) {
        if let canFollow = canFollow where canFollow == true {
            delegate?.cell(self, didSelectFollowSong: songURI!)
            ParseHelper.addFollowSongRelationshipToUser(songURI!, user: PFUser.currentUser()!)
            self.canFollow = false
        } else {
            delegate?.cell(self, didSelectUnFollowSong: songURI!)
            ParseHelper.removeFollowSongRelationshipToUser(songURI!, user: PFUser.currentUser()!)
            self.canFollow = true
        }
    }
}
