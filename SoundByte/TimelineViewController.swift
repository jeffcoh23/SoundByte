//
//  TimelineViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 12/1/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TimelineViewController: UIViewController{
    var users: [PFObject] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
    
    let followingQuery = PFQuery(className: "Follow")
    
    followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
    //print(followingQuery.getFirstObject())
    followingQuery.orderByAscending("username")
    
    
        
    followingQuery.findObjectsInBackgroundWithBlock {(
        
        result: [AnyObject]?, error: NSError?) -> Void in
        
        //print(followingQuery.getFirstObject())
        self.users = result as? [PFObject] ?? []
        print(self.users)
        self.tableView.reloadData()
        }
    }
}

    extension TimelineViewController: UITableViewDataSource {
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return users.count
        }
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            
            let followingQuery = PFQuery(className: "Follow")
            
            followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
            //print(followingQuery.getFirstObject())
            followingQuery.orderByAscending("username")

            let cell = tableView.dequeueReusableCellWithIdentifier("PostCell")!
            
            cell.textLabel!!.text = users[indexPath.row].objectId
            
            return cell as! UITableViewCell
        }
    }

