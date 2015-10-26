//
//  LoginViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 10/26/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import Foundation

//
//  LoginViewController.swift
//  Tutorial1
//
//  Created by Jeff Cohen on 9/29/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        let userEmail = userEmailTextField.text;
        let userPassword = userPasswordTextField.text;
        
        PFUser.logInWithUsernameInBackground(userEmail, password: userPassword)
            {(user, error) in
                if user != nil{
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else{
                    println("Error")
                }
        }
        
        
        
        
    }
}

