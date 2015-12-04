//
//  FriendsTableViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 10/29/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit
import Parse

class StartingTabViewController: UITabBarController{
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = true
        super.viewDidLoad()

    }
   }
