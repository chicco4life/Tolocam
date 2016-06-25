//
//  RegisterViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/16/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import Bolts

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.modalTransitionStyle = .CrossDissolve
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Avenir-Book", size: 22)! // Note the !
        ]
        
        //Customizing placeholder text style
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: attributes)
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: attributes)
        //disabling username field & emailfield autocorrect
        self.usernameTextField.autocorrectionType = UITextAutocorrectionType.No
        self.usernameTextField.autocapitalizationType = UITextAutocapitalizationType.None
        
        self.emailTextField.autocorrectionType = UITextAutocorrectionType.No
        self.emailTextField.autocapitalizationType = UITextAutocapitalizationType.None
        
        //setting input text style
        self.usernameTextField.font = UIFont(name: "Avenir-Book", size: 22)
        self.passwordTextField.font = UIFont(name: "Avenir-Book", size: 22)
        self.emailTextField.font = UIFont(name: "Avenir-Book", size: 22)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func popVC(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerTapped(sender: AnyObject) {
        
        
        if usernameTextField.text == "" {
            let alertController = UIAlertController(title:"Error", message:"Please input a username.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if passwordTextField.text == "" {
            let alertController = UIAlertController(title:"Error", message:"Please input a password.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if emailTextField.text == "" {
            let alertController = UIAlertController(title:"Error", message:"Please input an email address.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpressionOptions())
        if regex.firstMatchInString(usernameTextField.text!, options: NSMatchingOptions(), range:NSMakeRange(0, usernameTextField.text!.characters.count)) != nil {
            print("could not handle special characters")
            let alertController = UIAlertController(title:"Error", message:"Please don't use any special characters.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        }
        
        let user = PFUser()
        user.username = usernameTextField.text?.lowercaseString
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        user.signUpInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            
            if error == nil {
                //no error
                
                print("Successfully Signed Up User.")
                
                let vc = TabBarInitializer.getTabBarController()
                self.presentViewController(vc, animated: true, completion: nil)
                
                //follow self
                
                let follow = PFObject(className: "Follow")
                follow["followFrom"] = PFUser.currentUser()
                follow["followingTo"] = PFUser.currentUser()
                
                follow.saveInBackground()
                
            } else {
                // There is an error while signing up
                
                let alertController = UIAlertController(title:"Error", message:"This username/email is already registered!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title:"OK", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            
        })
        
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}