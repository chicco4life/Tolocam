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
        
        if usernameTextField.text == nil {
            return
        }
        
        if usernameTextField.text == "" {
            return
        }
        
        let user = PFUser()
            user.username = usernameTextField.text?.lowercaseString
            user.password = passwordTextField.text
            user.email = emailTextField.text
            user["followingWho"] = ["admin","chicco", "leo", usernameTextField.text!.lowercaseString]
        
        
        user.signUpInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            
            if error == nil {
                //no error
                
                print("Successfully Signed Up User.")
                
                let vc = TabBarInitializer.getTabBarController()
                self.presentViewController(vc, animated: true, completion: nil)
                
            } else {
                // There is an error while signing up
                
                let alertController = UIAlertController(title:"Error", message:"There was one or more errors while signing up.", preferredStyle: UIAlertControllerStyle.Alert)
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