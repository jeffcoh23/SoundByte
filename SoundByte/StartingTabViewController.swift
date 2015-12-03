//
//  FriendsTableViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 10/29/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit
import Parse

class StartingTabViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    override func viewWillAppear(animated: Bool) {
        NSLog("\(PFUser.currentUser())")
        if (PFUser.currentUser() == nil){
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! UIViewController
                self.presentViewController(viewController, animated: true, completion: nil)
                
            })
        }
        else{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //self.seg
            })
        }
    }
   }
