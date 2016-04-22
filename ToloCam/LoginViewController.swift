//
//  ViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/11/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Foundation

class LoginViewController: UIViewController {


    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true;
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func logInTapped(sender: AnyObject) {
        let username = usernameField.text?.lowercaseString
         let password = passwordField.text
        print("password \(password)")
        
        
        PFUser.logInWithUsernameInBackground(username!, password: password!) {
            (user:PFUser?, error:NSError?) -> Void in
            
            if (error) == nil {
                //successfully logged in
                
                print("Successfully Logged In.")
                
                let vc = TabBarInitializer.getTabBarController()
                self.presentViewController(vc, animated: true, completion: nil)
                
            } else {
                //Error while logging in
                
                let alertController = UIAlertController(title: "Error", message: "Incorrect Username/Password", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }
        
    }

}

