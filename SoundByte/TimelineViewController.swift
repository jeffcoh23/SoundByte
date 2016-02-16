


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

public var SelectedSongNumber = Int()
//public var valueToPass: String!

class TimelineViewController: UIViewController{
    
    
    
    var valueToPass: [PFObject]!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        if (self.respondsToSelector(action)){
            return true
        }
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        nameArray.removeAll()
        var usersname = "username"
        let findUserObjectId = PFQuery(className: "Follow")
        findUserObjectId.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        
        findUserObjectId.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let results = results{
                    for result in results {
                        let user : PFUser = result["toUser"] as! PFUser
                        let queryUsers = PFUser.query()
                        
                        queryUsers!.getObjectInBackgroundWithId(user.objectId!, block: {( userGet: PFObject?, error: NSError?) -> Void in
                            if let userGet = userGet{
                                self.valueToPass?.append(userGet)
                                self.nameArray.append(userGet.objectForKey("username") as! String)
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            } else{
                    print(error)
                    return
            }
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "friendPlaylist"){
            if let destination = segue.destinationViewController as? FriendPlaylistViewController{
                let path = tableView.indexPathForSelectedRow!
                //let cell = tableView.cellForRowAtIndexPath(path!)
                destination.viaSegue = self.nameArray[path.row]
                
            }
            
        }
    }
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return self.nameArray.count ?? 0
        }
    
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! TimelineTableViewCell
            cell.usernameLabel.text = self.nameArray[indexPath.row]
            return cell
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
            _ = tableView.indexPathForSelectedRow!
            if let _ = tableView.cellForRowAtIndexPath(indexPath){
                self.performSegueWithIdentifier("friendPlaylist", sender: self)
            }
            SelectedSongNumber = indexPath.row
        }
    

    
    }
