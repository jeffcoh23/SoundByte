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

    @IBOutlet weak var artistSearchLabel: UILabel!
    @IBOutlet weak var songSearchLabel: UILabel!
    @IBOutlet weak var addSongSearchButton: UIButton!
    weak var delegate: SongSearchTableViewCellDelegate?
 

    var songURI: AnyObject?


    @IBAction func songFollowButtonTapped(sender: AnyObject) {
        delegate?.cell(self, didSelectFollowSong: songURI!)
        ParseHelper.addFollowSongRelationshipToUser(songURI!, user: PFUser.currentUser()!)
    }
}
