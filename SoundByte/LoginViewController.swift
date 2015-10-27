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
import Parse
import Bolts

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    let loginViewControllerSegue = "LoginSuccessful"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        var userEmail = userEmailTextField.text
        userEmail = userEmail.lowercaseString
        var userPassword = userPasswordTextField.text
        
        PFUser.logInWithUsernameInBackground(userEmail, password: userPassword){
            user, error in
            if user != nil{
                self.performSegueWithIdentifier(self.loginViewControllerSegue, sender: nil)
            }else if let error = error{
                self.showErrorView(error)
               
            }
        }
    }
        
}

