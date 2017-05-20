//
//  ViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/11/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
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
            NSFontAttributeName : UIFont(name: "PingFangSC-Light", size: 22)! // Note the !
        ]
        
        registerBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //Customizing placeholder text style
        self.usernameField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: attributes)
        self.passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
        //disabling username field autocorrect
        self.usernameField.autocorrectionType = UITextAutocorrectionType.no
        self.usernameField.autocapitalizationType = UITextAutocapitalizationType.none
        //setting input text style
        self.usernameField.font = UIFont(name: "PingFangSC-Light", size: 22)
        self.passwordField.font = UIFont(name: "PingFangSC-Light", size: 22)
        //cursor color
        self.usernameField.tintColor = UIColor.white
        self.passwordField.tintColor = UIColor.white
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
    
    @IBAction func forgotPW(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "选择身份验证方式", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction.init(title: "邮箱", style: .default, handler: { (action:UIAlertAction) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "resetPWMailVC") as! ResetPWMailViewController
            self.show(vc, sender: nil)
        }))
        alert.addAction(UIAlertAction.init(title: "手机", style: .default, handler: { (action:UIAlertAction) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "resetPWPhoneVC") as! ResetPWPhoneViewController
            self.show(vc, sender: nil)
        }))
        alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true) {
        }
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
                var alertController = UIAlertController()
                switch error!.localizedDescription{
                case "The username and password mismatch.":
                    alertController = UIAlertController(title: "错误", message: "密码不正确", preferredStyle: UIAlertControllerStyle.alert)
                case "Could not find user":
                    alertController = UIAlertController(title: "错误", message: "用户不存在", preferredStyle: UIAlertControllerStyle.alert)
                default:
                    alertController = UIAlertController(title: "错误", message: "未知错误", preferredStyle: UIAlertControllerStyle.alert)
                    
                }
                print(error!.localizedDescription)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                self.view.isUserInteractionEnabled = true
            }
        }
        
    }
    
}
