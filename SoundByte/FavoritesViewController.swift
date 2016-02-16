//
//  FavoritesViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 2/9/16.
//  Copyright (c) 2016 Jeff Cohen. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var songWithInfoDictionary : [String : (String, String)] = [:]{
        didSet{
            tableView.reloadData()
        }
    }
    var songURIArray = [String](){
        didSet{
            tableView.reloadData()
        }
    }
    
    func fetchLikedSongs(){
        let pointer = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()!.objectId!)
        var query = PFUser.query()
        let likesQuery = PFQuery(className: "Like")
        let finalQuery = likesQuery.whereKey("fromUser", equalTo: pointer)
        finalQuery.findObjectsInBackgroundWithBlock ( {
            (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil{
                if let results = results{
                    for result in results{
                        self.songURIArray.append(result["likedSongURI"] as! String)
                        self.fetchNameAndArtist(result["likedSongURI"] as! String)

                    }
                }
            }
            else{
                return
            }
            
            
        })
        
    }
    
    func fetchNameAndArtist(uriTrackAsString: String!) -> [String : (String, String)]{
        let uriTrack = NSURL(string: uriTrackAsString)
        SPTTrack.trackWithURI(uriTrack, session: nil) { (error, track) -> Void in
            if let track = track as? SPTTrack, artist = track.artists.first as? SPTPartialArtist{
                self.songWithInfoDictionary.updateValue((track.name, artist.name), forKey: uriTrackAsString)

            }
        }
       

        return self.songWithInfoDictionary
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let pointer = PFObject(withoutDataWithClassName: "_User", objectId: PFUser.currentUser()!.objectId!)
        var query = PFUser.query()
        let likesQuery = PFQuery(className: "Like")
        let finalQuery = likesQuery.whereKey("fromUser", equalTo: pointer)
        finalQuery.findObjectsInBackgroundWithBlock({
            (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil{
                if let results = results{
                    for result in results{
                        let uriTrackAsString = result["likedSongURI"] as! String
                        self.songURIArray.append(uriTrackAsString)
                        let uriTrack = NSURL(string: result["likedSongURI"] as! String)
                        SPTTrack.trackWithURI(uriTrack, session: nil) { (error, track) -> Void in
                            if let track = track as? SPTTrack, artist = track.artists.first as? SPTPartialArtist{
                                self.songWithInfoDictionary.updateValue((track.name, artist.name), forKey: uriTrackAsString)
                                
                                
                                
                            }
                        }
                        //self.fetchNameAndArtist(result["likedSongURI"] as! String)
                        
                    }
                }
            }
            else{
                return
            }
            
            
        })
        //fetchLikedSongs()
        //self.tableView.reloadData()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FavoritesViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return self.songWithInfoDictionary.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell") as! FavoritesTableViewCell
        var (songTitle, artistName) = self.songWithInfoDictionary[self.songURIArray[indexPath.row]]!
        cell.songName.text = songTitle
        cell.artistName.text = artistName
        return cell
    }

}
