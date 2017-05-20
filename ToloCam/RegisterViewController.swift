//
//  RegisterViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/16/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
import AVOSCloud

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginVCBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = .crossDissolve
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName : UIFont(name: "Avenir-Book", size: 22)! // Note the !
        ]
        
        loginVCBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //Customizing placeholder text style
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: attributes)
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: attributes)
        //disabling username field autocorrect
        self.usernameTextField.autocorrectionType = UITextAutocorrectionType.no
        self.usernameTextField.autocapitalizationType = UITextAutocapitalizationType.none
        self.emailTextField.autocorrectionType = .no
        self.emailTextField.autocapitalizationType = .none
        //setting input text style
        self.usernameTextField.font = UIFont(name: "Avenir-Book", size: 22)
        self.passwordTextField.font = UIFont(name: "Avenir-Book", size: 22)
        self.emailTextField.font = UIFont(name: "Avenir-Book", size: 22)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissVC(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerTapped(_ sender: AnyObject) {
        
        self.view.isUserInteractionEnabled = false
        
        if usernameTextField.text == "" {
            let alertController = UIAlertController(title:"Error", message:"Please input a username.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if passwordTextField.text == "" {
            let alertController = UIAlertController(title:"Error", message:"Please input a password.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if emailTextField.text == "" {
            let alertController = UIAlertController(title:"Error", message:"Please input an email address.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
        if regex.firstMatch(in: usernameTextField.text!, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, usernameTextField.text!.characters.count)) != nil {
            print("could not handle special characters")
            let alertController = UIAlertController(title:"Error", message:"Please don't use any special characters.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            
        }
        
        let user = AVUser()
        user.username = usernameTextField.text?.lowercased()
        user.password = passwordTextField.text!
        user.email = emailTextField.text!
        user["nickname"] = user.username
        //            user["followingWho"] = ["admin","chicco", "leo", usernameTextField.text!.lowercaseString]
//        user.signUp { (success:LCBooleanResult) in
//            if success.isSuccess {
//                //no error
//                
//                print("Successfully Signed Up User.")
//                
//                let vc = TabBarInitializer.getTabBarController()
//                self.present(vc, animated: true, completion: nil)
//                
//                //follow self
//                
//                //                let follow = PFObject(className: "Follow")
//                let follow = LCObject(className: "Follow")
//                follow["followFrom"] = LCUser.current
//                follow["followingTo"] = LCUser.current
//                
//                //                follow.saveInBackground()
//                follow.save()
//                
//            } else {
//                // There is an error while signing up
//                
//                let alertController = UIAlertController(title:"Error", message:"This username/email is already registered!", preferredStyle: UIAlertControllerStyle.alert)
//                alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
//                self.present(alertController, animated: true, completion: nil)
//                
//            }
            user.signUpInBackground { (success, error) in
                if error == nil{
                    //no error

                    print("Successfully Signed Up User.")

                    let vc = TabBarInitializer.getTabBarController()
                    self.present(vc, animated: true, completion: nil)

                    //follow self

                    let follow = AVObject(className: "Follow")
                    follow["followFrom"] = user
                    follow["followingTo"] = user

                    follow.saveInBackground()

                } else {
                    // There is an error while signing up

                    let alertController = UIAlertController(title:"Error", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: { 
                        self.view.isUserInteractionEnabled = false
                    })
                    

            }
        
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
}
