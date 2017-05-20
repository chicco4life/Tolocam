//
//  ResetPWPhoneViewController.swift
//  ToloCam
//
//  Created by Leo Li on 03/05/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud

class ResetPWPhoneViewController: UIViewController {
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var newPWField: UITextField!
    @IBOutlet weak var sendCodeBtn: UIButton!
    var timer = Timer()
    var timerCount = 60

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendCode(_ sender: Any) {
        if phoneNumberField.text != ""{
            let query = AVQuery(className: "_User")
            query.whereKey("mobilePhoneNumber", equalTo: self.phoneNumberField.text!)
            query.findObjectsInBackground({ (results:[Any]?, error:Error?) in
                if error == nil && results?.count != 0{
                    AVUser.requestPasswordReset(withPhoneNumber: self.phoneNumberField.text!, block: { (done:Bool, error:Error?) in
                        if done{
                            let alert = UIAlertController(title: "发送成功", message: "请查收短信", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) in
                            }))
                            self.present(alert, animated: true, completion: nil)
                            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.__countDownTimer), userInfo: nil, repeats: true)
                            self.sendCodeBtn.isEnabled = false
                            
                        }else{
                            if error?.localizedDescription == "Mobile phone number isn't verified."{
                                let alert = UIAlertController(title: "发送失败", message: "该手机号码没有被验证", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }else{
                                let alert = UIAlertController(title: "发送失败", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            print(error!)
                        }
                    })
                }else{
                    let alert = UIAlertController(title: "错误", message: "没有符合该手机号码的账号", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }else{
            let alert = UIAlertController(title: "错误", message: "请输入手机号码", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func __countDownTimer() {
        timerCount -= 1
        if timerCount == 0 {
            timer.invalidate()
            
            self.sendCodeBtn.setTitle("发送", for: .normal)
            self.sendCodeBtn?.isEnabled = true
        } else {
            self.sendCodeBtn.setTitle("\(timerCount)", for: .normal)
        }
    }

    @IBAction func viewPW(_ sender: Any) {
        self.newPWField.isSecureTextEntry = !self.newPWField.isSecureTextEntry
    }
    
    @IBAction func resetPW(_ sender: Any) {
        if phoneNumberField.text == ""{
            let alert = UIAlertController(title: "错误", message: "请输入手机号码", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if codeField.text == ""{
            let alert = UIAlertController(title: "错误", message: "请输入验证码", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            AVUser.resetPassword(withSmsCode: codeField.text!, newPassword: newPWField.text!, block: { (done:Bool, error:Error?) in
                if done{
                    let alert = UIAlertController(title: "成功", message: "请使用新密码登录", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    print(error!.localizedDescription)
                    let alert = UIAlertController(title: "错误", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
  
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
