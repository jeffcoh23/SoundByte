//
//  ParseHelper.swift
//  SoundByte
//
//  Created by Jeff Cohen on 11/9/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import Foundation
import Parse
// MARK: Following

/**
Fetches all users that the provided user is following.

:param: user The user whose followees you want to retrieve
:param: completionBlock The completion block that is called when the query completes
*/

class ParseHelper{
    
    // Following Relation
    static let ParseFollowClass       = "Follow"
    static let ParseFollowFromUser    = "fromUser"
    static let ParseFollowToUser      = "toUser"
    static let ParseUserUsername      = "username"
    static let ParseSongClass = "Playlist"
    
static func getFollowingUsersForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
    let query = PFQuery(className: ParseFollowClass)
    
    query.whereKey(ParseFollowFromUser, equalTo:user)
    query.findObjectsInBackgroundWithBlock(completionBlock)
}

/**
Establishes a follow relationship between two users.

:param: user    The user that is following
:param: toUser  The user that is being followed
*/
static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
    let followObject = PFObject(className: ParseFollowClass)
    followObject.setObject(user, forKey: ParseFollowFromUser)
    followObject.setObject(toUser, forKey: ParseFollowToUser)
    
    followObject.saveInBackgroundWithBlock(nil)
}
    
static func addFollowSongRelationshipToUser(song: AnyObject, user: PFUser ){
        let followObject = PFObject(className: ParseSongClass)
        followObject.setObject(user, forKey: "user")
    
        var str = song.uri.description
        var index1 = advance(song.uri.description.startIndex, 14)
        var subStr = str.substringFromIndex(index1)
        followObject.setObject(subStr, forKey: "spotifyTrackNumber")
        //NSLog("\(subStr)")
        followObject.saveInBackgroundWithBlock(nil)
}

/**
Deletes a follow relationship between two users.

:param: user    The user that is following
:param: toUser  The user that is being followed
*/
static func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
    let query = PFQuery(className: ParseFollowClass)
    query.whereKey(ParseFollowFromUser, equalTo:user)
    query.whereKey(ParseFollowToUser, equalTo: toUser)
    
    query.findObjectsInBackgroundWithBlock {
        (results: [AnyObject]?, error: NSError?) -> Void in
        
        let results = results as? [PFObject] ?? []
        
        for follow in results {
            follow.deleteInBackgroundWithBlock(nil)
        }
    }
}

// MARK: Users

/**
Fetch all users, except the one that's currently signed in.
Limits the amount of users returned to 20.

:param: completionBlock The completion block that is called when the query completes

:returns: The generated PFQuery
*/
static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
    let query = PFUser.query()!
    // exclude the current user
    query.whereKey(ParseHelper.ParseUserUsername,
        notEqualTo: PFUser.currentUser()!.username!)
    query.orderByAscending(ParseHelper.ParseUserUsername)
    query.limit = 20
    
    query.findObjectsInBackgroundWithBlock(completionBlock)
    
    return query
}

/**
Fetch users whose usernames match the provided search term.

:param: searchText The text that should be used to search for users
:param: completionBlock The completion block that is called when the query completes

:returns: The generated PFQuery
*/
static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock)
    -> PFQuery {
        /*
        NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
        Regex can be slow on large datasets. For large amount of data it's better to store
        lowercased username in a separate column and perform a regular string compare.
        */
        let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername,
            matchesRegex: searchText, modifiers: "i")
        
        query.whereKey(ParseHelper.ParseUserUsername,
            notEqualTo: PFUser.currentUser()!.username!)
        
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
}
}