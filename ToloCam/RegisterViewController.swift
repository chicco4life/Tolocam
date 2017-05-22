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

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginVCBtn: UIButton!
    
    var blurEffectView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = .crossDissolve
        
        loginVCBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.registerBtn.layer.cornerRadius = self.registerBtn.frame.height/2
        self.registerBtn.layer.borderWidth = 4
        self.registerBtn.layer.borderColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        self.registerBtn.addTarget(self, action: #selector(__buttonHighlight), for: .touchDown)
        self.registerBtn.addTarget(self, action: #selector(__buttonNormal), for: .touchUpInside)
        self.registerBtn.addTarget(self, action: #selector(__buttonNormal), for: .touchUpOutside)
        
        self.usernameTextField.tag = 0
        self.emailTextField.tag = 1
        self.passwordTextField.tag = 2
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
        
        self.blurEffectView = UIVisualEffectView()
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundImg.addSubview(self.blurEffectView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func dismissVC(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            registerTapped(self)
        }
        // Do not add a line break
        return false
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
            let alertController = UIAlertController(title:"错误", message:"请输入用户名", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            return
        }
        
        if passwordTextField.text == "" {
            let alertController = UIAlertController(title:"错误", message:"请输入密码", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            return
        }
        
        if emailTextField.text == "" {
            let alertController = UIAlertController(title:"错误", message:"请输入邮箱地址", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            return
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: emailTextField.text) == false{
            let alertController = UIAlertController(title:"错误", message:"请输入正确的邮箱地址", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            return

        }
        
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
        if regex.firstMatch(in: usernameTextField.text!, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, usernameTextField.text!.characters.count)) != nil {
            print("could not handle special characters")
            let alertController = UIAlertController(title:"错误", message:"请不要使用特殊字符", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.view.isUserInteractionEnabled = true
            
            
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
                    
                    if error?.localizedDescription == "Username has already been taken"{
                        let alertController = UIAlertController(title:"错误", message:"用户名已被占用", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title:"确定", style: .cancel, handler: nil))
                        self.present(alertController, animated: true, completion: {
                            self.view.isUserInteractionEnabled = true
                        })
                    }else{
                        let alertController = UIAlertController(title:"错误", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title:"确定", style: .cancel, handler: nil))
                        self.present(alertController, animated: true, completion: { 
                            self.view.isUserInteractionEnabled = true
                        })
                    }
            }
        
        }
    }
    
    func __buttonHighlight(){
        self.registerBtn.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.3)
        self.registerBtn.layer.borderWidth = 0
    }
    
    func __buttonNormal(){
        self.registerBtn.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0)
        self.registerBtn.layer.borderWidth = 4
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
                UIView.animate(withDuration: 0.5, animations: {
                    self.blurEffectView.effect = UIBlurEffect(style: .light)
                })
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
                UIView.animate(withDuration: 0.5, animations: {
                    self.blurEffectView.effect = nil
                })
            }
        }
    }
}
