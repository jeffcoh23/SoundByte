//
//  LoginViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 10/26/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Bolts

class LoginViewController: UIViewController {
    
    //text field for username
    @IBOutlet weak var userEmailTextField: UITextField!
    
    //text field for password
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    //Segue name
    let loginViewControllerSegue = "LoginSuccessful"
    
    override func viewDidLoad() {
        if PFUser.currentUser() != nil{
            self.performSegueWithIdentifier(self.loginViewControllerSegue, sender: nil)
        }
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //Action when login button is tapped
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        var userEmail = userEmailTextField.text
        userEmail = userEmail!.lowercaseString
        let userPassword = userPasswordTextField.text

        PFUser.logInWithUsernameInBackground(userEmail!, password: userPassword!){
            user, error in
            if user != nil{
                self.performSegueWithIdentifier(self.loginViewControllerSegue, sender: nil)
            }else if let error = error{
                self.showErrorView(error)
               
            }
        }
    }
        
}

