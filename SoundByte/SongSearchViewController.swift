//
//  SongSearchViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 12/7/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit
import Parse


//run "ruby spotify_token_swap.rb" to launch server


class SongSearchViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingPlaybackDelegate {
    
    let kClientID = "cf5b0855e8f440719ad3a1811e704fe3"
    let kCallbackURL = "soundbyte://return-after-login"
    //let kTokenSwapURL = "http://localhost:1234/swap"
    //let kTokenRefreshURL = "http://localhost:1234/refresh"
    
    
    var songsAlreadyLiked: [String]?
    
    @IBOutlet weak var tableViewSongResults: UITableView!
    @IBOutlet weak var songSearchBar: UISearchBar!
    var player: SPTAudioStreamingController?
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    var spotifyListPage: SPTListPage?
    
    @IBOutlet weak var spotifyLoginButton: UIButton!
    
    var followingSongs: [String]?{
        didSet{
            tableViewSongResults.reloadData()
        }
    }
    
    // the current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    
    // this view can be in two different states
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    // whenever the state changes, perform one of the two queries and update the list
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                query = ParseHelper.allUsers(updateList)
                
            case .SearchMode:
                let searchText = songSearchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock:updateList)
            }
        }
    }
    
    // MARK: Update userlist
    
    /**
    Is called as the completion block of all queries.
    As soon as a query completes, this method updates the Table View.
    */
    func updateList(results: [PFObject]?, error: NSError?) {
        self.tableViewSongResults.reloadData()
        
    }
    
    
    
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
        let auth: SPTAuth = SPTAuth.defaultInstance()
        setupSpotifyPlayer()
        //NSLog("\(auth.session.description)")
        loginWithSpotifySession(auth.session)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("login cancelled")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("login failed")
    }
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        state = .DefaultMode
        ParseHelper.getFollowingSongsForUser(PFUser.currentUser()!) {
            (results: [PFObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject]! ?? []
            // use map to extract the User from a Follow object
            self.followingSongs = relations.map {
                $0.valueForKey("spotifyTrackNumber") as! String
            }
            
        }
        
    }
    
    func sessionUpdatedNotification (notification: NSNotification) -> Void{
        if self.navigationController?.topViewController == self{
            let auth: SPTAuth = SPTAuth.defaultInstance()
            if auth.session.isValid(){
                
                self.setupSpotifyPlayer()
                self.loginWithSpotifySession(auth.session)
                
            }
        }
    }
    
    var IDArray = [String]()
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionUpdatedNotification", name: "sessionUpdated", object: nil)
        self.spotifyLoginButton.hidden = true
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        let playlistFromFollowedUsers = PFQuery(className: "Playlist")
        playlistFromFollowedUsers.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        playlistFromFollowedUsers.findObjectsInBackgroundWithBlock({
            
            (result: [PFObject]?, error: NSError?) -> Void in
            
            
            var songIDs = result as! [PFObject]!
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
        
        for i in 0...IDArray.count-1{
            let SpotifyURI = IDArray[i]
            self.player!.playURIs([NSURL(string: SpotifyURI)!], withOptions: nil, callback: nil)
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
        if spotifyAuthenticator.session.accessToken != nil{
            self.spotifyLoginButton.hidden = true
        }
        
        player!.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                print("Couldn't login with session: \(error)")
                return
            }
            //self.grabSong()
            
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
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        SPTSearch.performSearchWithQuery(searchText, queryType: SPTSearchQueryType.QueryTypeTrack, accessToken: nil, callback: {( error, result) -> Void in
            if let result = result as? SPTListPage{
                self.spotifyListPage = result
                
                self.tableViewSongResults.reloadData()
            }
            //  }
            //}
        })
        
    }
    
}

extension SongSearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if spotifyListPage?.items == nil{
            return 1
        }
        return spotifyListPage!.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell") as! SongSearchTableViewCell
        
        
        cell.addSongSearchButton.hidden = true
        if spotifyListPage?.items == nil{
            cell.songSearchLabel!.text = "No Results Found"
            cell.artistSearchLabel.hidden = true
        }
            
        else{
            cell.addSongSearchButton.hidden = false
            //var partialTrack = self.spotifyListPage?.items[indexPath.row].artists?.first.description
            cell.artistSearchLabel!.text = self.spotifyListPage?.items[indexPath.row].artists?.first!.name
            cell.songSearchLabel!.text = self.spotifyListPage?.items[indexPath.row].name
            let song = self.spotifyListPage?.items[indexPath.row]
            let URISong = song!.uri.description
            //NSLog("\(song!.uri.description)")
            cell.songURI = song as? SPTPartialTrack
            if let followingSongs = followingSongs{
                cell.canFollow = !followingSongs.contains(URISong)
            }
            
        }
        
        
        cell.delegate = self
        
        return cell
    }
}



extension SongSearchViewController: SongSearchTableViewCellDelegate {
    
    func cell(cell: SongSearchTableViewCell, didSelectFollowSong song: SPTPartialTrack?) {
    }
    func cell(cell: SongSearchTableViewCell, didSelectUnFollowSong song: SPTPartialTrack?) {
    }
}