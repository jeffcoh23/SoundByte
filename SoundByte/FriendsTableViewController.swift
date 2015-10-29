//
//  FriendsTableViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 10/29/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit

class FriendsTableViewController: PFQueryTableViewController {
    
    @IBOutlet weak var usersName: UILabel!
     let cellIdentifier:String = "UserCell"
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {

        
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 25
        self.tableView.rowHeight = 350
        super.viewDidLoad()
    }
//    override init(style: UITableViewStyle, className: String!)
//    {
//        super.init(style: style, className: className)
//        
//        self.pullToRefreshEnabled = true
//        self.paginationEnabled = false
//        self.objectsPerPage = 25
//        
//        self.parseClassName = className
//    }
//    
//    required init(coder aDecoder:NSCoder)  
//    {
//        fatalError("NSCoding not supported")  
//    }
    
    override func queryForTable() -> PFQuery {
        var query:PFQuery = PFQuery(className: "User")
        query.whereKey("username", equalTo: "jeff")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                println("Successfully retrieved: \(objects)")
            } else {
                println("Error:")
            }
        }

        if(objects?.count == 0)
        {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork
            
        }
        
        query.orderByAscending("username")
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        let cellIdentifier:String = "Cell"
        
        var cell:PFTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? PFTableViewCell
        
        if(cell == nil) {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        if let user = PFUser?() {
            cell?.textLabel?.text = user.username! as? String
        }
        
        return cell;
    }
}
