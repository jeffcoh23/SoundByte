
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
    
    let user = PFObject(className: "User")
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
        
        user.setObject(userEmail, forKey: "Email")
        user.setObject(userPassword, forKey: "Password")
        user.saveInBackgroundWithBlock {(succeeded,error) -> Void in
            if succeeded{
                self.displayMyAlertMessage("Registration is successful. Thank you!")
                self.performSegueWithIdentifier("register", sender: self)
                
            }
            else{
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
        var myAlert = UIAlertController(title:"Alert", message: "Registration is successful. Thank you!", preferredStyle:UIAlertControllerStyle.Alert);
        
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.Default){action in self.dismissViewControllerAnimated(true, completion: nil);
        }
        
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated:true, completion:nil)
        
        //Display alert message with confirmation
        
    }
    func displayMyAlertMessage(userMessage:String){
        var myAlert = UIAlertController(title:"Alert", message:userMessage, preferredStyle:UIAlertControllerStyle.Alert);
        
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.Default, handler:nil);
        
        myAlert.addAction(okAction);
        
        self.presentViewController(myAlert, animated:true, completion:nil);
    }
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

