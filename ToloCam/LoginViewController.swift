//
//  ViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/11/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
import Foundation
import AVOSCloud

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName : UIFont(name: "Avenir-Book", size: 22)! // Note the !
        ]
        
        registerBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //Customizing placeholder text style
        self.usernameField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: attributes)
        self.passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
        //disabling username field autocorrect
        self.usernameField.autocorrectionType = UITextAutocorrectionType.no
        self.usernameField.autocapitalizationType = UITextAutocapitalizationType.none
        //setting input text style
        self.usernameField.font = UIFont(name: "Avenir-Book", size: 22)
        self.passwordField.font = UIFont(name: "Avenir-Book", size: 22)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func logInTapped(_ sender: AnyObject) {
        
        self.view.isUserInteractionEnabled = false
        
        let username = usernameField.text?.lowercased()
        let password = passwordField.text
        print("password \(password)")
        

        
        AVUser.logInWithUsername(inBackground: username!, password: password!) { (user, error) in
            if error == nil {
                let vc = TabBarInitializer.getTabBarController()
                self.present(vc, animated: true, completion: nil)
            }else{
                //error
                let alertController = UIAlertController(title: "Error", message: "Incorrect Username/Password", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                self.view.isUserInteractionEnabled = true
            }
        }
        
    }
    
}
