
//
//  RegisterPageViewController.swift
//  SoundByte
//
//  Created by Jeff Cohen on 10/26/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import Foundation
import UIKit

class RegisterPageViewController: UIViewController {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    let signUpSuccessful = "SignupSuccessful"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    
    
    
    @IBAction func registerButton(sender: UIButton) {
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        let userRepeatPassword = repeatPasswordTextField.text
        
        //Check for empty fields
        if(userEmail.isEmpty || userPassword.isEmpty || userRepeatPassword.isEmpty){
            displayMyAlertMessage("All fields are required")
            return
        }
        
        //Validates password length
        if (count(userPassword) > 17 || (count(userPassword)<5)){
            displayMyAlertMessage("Password must be between 5 and 12 characters")
            return
        }
        
        //Validates email
        if (validateEmail(userEmail)==false){
            displayMyAlertMessage("Not a valid email address")
            return
        }
        
        //check if passwords match
        if(userPassword != userRepeatPassword){
            //Display an alert message
            displayMyAlertMessage("Passwords do not match")
            return
        }
        
        
        //Store data
        let user = PFUser()
        user.username = userEmailTextField.text
        user.password = userPasswordTextField.text
        user.signUpInBackgroundWithBlock {succeeded,error in
            if succeeded{
                self.performSegueWithIdentifier(self.signUpSuccessful, sender: nil)
            }
            else if let error = error{
                self.showErrorView(error)
            }
            
        }
    
    }
    //Display alert message with confirmation
    func displayMyAlertMessage(userMessage:String){
        var myAlert = UIAlertController(title:"Alert", message:userMessage, preferredStyle:UIAlertControllerStyle.Alert);
        
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.Default, handler:nil);
        
        myAlert.addAction(okAction);
        
        self.presentViewController(myAlert, animated:true, completion:nil);
    }
    
}

