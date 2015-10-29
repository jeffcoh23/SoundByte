//
//  TableViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 10/29/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit

class TableViewController: PFQueryTableViewController {
   	// Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery{
        var query:PFQuery = PFUser.query()!
        query.whereKey("username", equalTo: "jeff@union.edu")
        query.orderByAscending("username")
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as! CustomTableViewCell!
        if cell == nil {
            cell = CustomTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CustomCell")
        }
        
        // Extract values from the PFObject to display in the table cell
        
        var query:PFQuery=PFUser.query()!
        query.whereKey("username", equalTo: cell.customUserName.text!)
        cell.customUserName.text = PFUser.currentUser()?.username
        
        println("\(objects)")
        
        return cell
    }
}
