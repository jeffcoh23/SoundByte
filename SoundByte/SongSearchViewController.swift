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
    

    
    
    @IBOutlet weak var tableViewSongResults: UITableView!
    @IBOutlet weak var songSearchBar: UISearchBar!
    var player: SPTAudioStreamingController?
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    var spotifyListPage: SPTListPage?
    
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

    
    var IDArray = [String]()
    var NameArray = [String]()
    override func viewDidLoad() {
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        let playlistFromFollowedUsers = PFQuery(className: "Playlist")
        playlistFromFollowedUsers.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        //playlistFromFollowedUsers.includeKey("user")
        //playlistFromFollowedUsers.orderByAscending("username")
        
       // NSLog("\(PFUser.currentUser())")

        
        playlistFromFollowedUsers.findObjectsInBackgroundWithBlock({
            
            (result: [AnyObject]?, error: NSError?) -> Void in
            

            var songIDs = result as! [PFObject]
            if songIDs.count < 1{
                return
            }
            else{
                for i in 0...songIDs.count-1{
                    self.IDArray.append(songIDs[i].valueForKey("spotifyTrackNumber") as! String)
                    //self.NameArray.append(songIDs[i].valueForKey("songName") as! String)
                    //self.tableView.reloadData()
                    
                }
            }
            
        })
    }
    
    func grabSong(){
        let followingQuery = PFQuery(className: "Follow")
        //NSLog("\(PFUser.currentUser())")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        let playlistFromFollowedUsers = PFQuery(className: "Playlist")
        playlistFromFollowedUsers.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        //NSLog("\(IDArray[SelectedSongNumber])")
        for i in 0...IDArray.count-1{
            let SpotifyURI = IDArray[i]
            self.player!.playURIs([NSURL(string: SpotifyURI)!], withOptions: nil, callback: nil)
        }
        
        
//        playlistFromFollowedUsers.getObjectInBackgroundWithId(IDArray[SelectedSongNumber], block: {
//            (object : PFObject?, error: NSError?) -> Void in
//                        //NSLog("\(object)")
//            NSLog("\(object)")
//           // if let
//
//            //object?.description
//            //If this is a song file
//        
//            //if let AudioFileURLTemp = object?.objectForKey("songFile")?.url{
//              //  NSLog(AudioFileURLTemp!)
//                let spotifyURI = "\(object)"
//                self.player!.playURIs([NSURL(string: spotifyURI)!], withOptions: nil, callback: nil)
//                //AudioPlayer = AVPlayer(URL: NSURL(string: AudioFileURLTemp!))
//                //AudioPlayer.play()
//            //}
        //})
    }
    func startPlayback(){
//        SPTYourMusic.savedTracksForUserWithAccessToken(spotifyAuthenticator.session.accessToken, callback: { (error, result) -> Void in
//            if let result = result as? SPTListPage {
//                NSLog("\(result)")
//                self.fetchAll(result) { (tracks) in
//                    NSLog("\(result)")
//                    NSLog("\(tracks)")
//                    let uris = SPTTrack.urisFromArray(tracks.shuffled())
//                    
//                    self.player!.playURIs(uris, fromIndex: 0) { (error) -> Void in
//                        if let error = error {
//                            NSLog(String(format: "playURIs error: %@", error))
//                        }
//                    }
//                }
//            }
//        })
    }
   func fetchAll(listPage: SPTListPage, _ callback: (tracks: [SPTSavedTrack]) -> Void) {
//        if listPage.hasNextPage {
//            listPage.requestNextPageWithSession(spotifyAuthenticator.session, callback: { (error, page) -> Void in
//                if let page = page as? SPTListPage {
//                    self.fetchAll(listPage.pageByAppendingPage(page), callback)
//                }
//            })
//        } else {
//            if let items = listPage.items as? [SPTSavedTrack] {
//                callback(tracks: items)
//            }
//        }
    }
    
    // SPTAudioStreamingPlaybackDelegate protocol methods
    
    private
    
    func setupSpotifyPlayer() {
        player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID) // can also use kClientID; they're the same value
        player!.playbackDelegate = self
        player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
    }
    
    func loginWithSpotifySession(session: SPTSession) {
        if spotifyAuthenticator.session.accessToken != nil{
            self.spotifyLoginButton.hidden = true
        }
      
        player!.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                println("Couldn't login with session: \(error)")
                return
            }
            self.grabSong()
            
        })
    }
    
    func useLoggedInPermissions() {
        
        //let spotifyURI = PFQuery()
        //spotifyURI.whereKey(<#key: String#>, containedIn: <#[AnyObject]#>)
        //let spotifyURI = PFUser.currentUser().
        //let spotifyURI = "spotify:track:4h0zU3O9R5xzuTmNO7dNDU)"
        //player!.playURIs([NSURL(string: spotifyURI)!], withOptions: nil, callback: nil)
    }
}

extension SongSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        //state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        //state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        SPTSearch.performSearchWithQuery(searchText, queryType: SPTSearchQueryType.QueryTypeTrack, accessToken: spotifyAuthenticator.session.accessToken, callback: {( error, result) -> Void in
            if let result = result as? SPTListPage{
                self.spotifyListPage = result
                //if self.spotifyListPage?.items != nil{
                    //NSLog("\(self.spotifyListPage?.items)")}
                //self.results = self.spotifyListPage?.items.mutableCopy()
                self.tableViewSongResults.reloadData()
                    }
              //  }
            //}
        })
        
    }
    
}
//spotify:track:7AFH5sXGvpJxqDQ3lr6qu1

extension SongSearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if spotifyListPage?.items == nil{
            return 1
        }
        return spotifyListPage!.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SongCell") as! SongSearchTableViewCell
        

        cell.addSongSearchButton.hidden = true
        if spotifyListPage?.items == nil{
            cell.songSearchLabel!.text = "No Results Found"
        }

        else{
            cell.addSongSearchButton.hidden = false
            cell.songSearchLabel!.text = self.spotifyListPage?.items[indexPath.row].name
            var song = self.spotifyListPage?.items[indexPath.row]
            cell.songURI = song
        }
        
        cell.delegate = self
        
        return cell
    }
}



extension SongSearchViewController: SongSearchTableViewCellDelegate {
    
    func cell(cell: SongSearchTableViewCell, didSelectFollowSong song: AnyObject?) {
//        NSLog("\(song)")
//        ParseHelper.addFollowSongRelationshipToUser(song!, user: PFUser.currentUser()!)
//        // update local cache
//        //followingUsers?.append(user)
    }
}

//    func cell(cell: SongSearchTableViewCell, didSelectUnfollowUser user: PFUser) {
//        if var followingUsers = followingUsers {
//            ParseHelper.removeFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
//            // update local cache
//            //removeObject(user, fromArray: &followingUsers)
//            self.followingUsers = followingUsers
//        }
//    }
    
//}
