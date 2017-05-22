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

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var blurEffectView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        registerBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.loginBtn.layer.cornerRadius = self.loginBtn.frame.height/2
        self.loginBtn.layer.borderWidth = 4
        self.loginBtn.layer.borderColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        self.loginBtn.addTarget(self, action: #selector(__buttonHighlight), for: .touchDown)
        self.loginBtn.addTarget(self, action: #selector(__buttonNormal), for: .touchUpInside)
        self.loginBtn.addTarget(self, action: #selector(__buttonNormal), for: .touchUpOutside)

        //cursor color
        self.usernameField.tintColor = UIColor.white
        self.passwordField.tintColor = UIColor.white
        self.usernameField.tag = 0
        self.passwordField.tag = 1
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        self.blurEffectView = UIVisualEffectView()
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundImg.addSubview(self.blurEffectView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.hideKeyboardWhenTappedAround()
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
        if self.usernameField.text == "" || self.passwordField.text == "" {
            let alert = UIAlertController(title: "错误", message: "账号或密码不可为空", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
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
                    alertController = UIAlertController(title: "错误", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    
                }
                print(error!.localizedDescription)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            logInTapped(self)
        }
        // Do not add a line break
        return true
    }
    
    func __buttonHighlight(){
        self.loginBtn.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.3)
        self.loginBtn.layer.borderWidth = 0
    }
    
    func __buttonNormal(){
        self.loginBtn.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0)
        self.loginBtn.layer.borderWidth = 4
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                //only move views except background
                self.view.frame.origin.y -= keyboardSize.height
                UIView.animate(withDuration: 0.5, animations: { 
                    self.blurEffectView.effect = UIBlurEffect(style: .regular)
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
