//
//  HomeViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 10/26/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//


import UIKit
import Parse

class HomeViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show the current visitor's username
        if let pUserName = PFUser.currentUser()?.username {
            self.userNameLabel.text = "Hello @" + pUserName
        }
    }
    

    @IBAction func logoutButtonTapped(sender: AnyObject) {
    
    // Send a request to log out a user
    PFUser.logOut()
    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! UIViewController
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

