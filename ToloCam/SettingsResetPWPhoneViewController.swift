//
//  SettingsResetPWPhoneViewController.swift
//  ToloCam
//
//  Created by Leo Li on 17/05/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud

class SettingsResetPWPhoneViewController: UIViewController {
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var confirmPwField: UITextField!
    @IBOutlet weak var sendCodeBtn: UIButton!
    var timer = Timer()
    var timerCount = 60

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendCodeBtn.layer.borderWidth = 1
        self.sendCodeBtn.layer.borderColor = UIColor(colorLiteralRed: 152/255, green: 152/255, blue: 152/255, alpha: 1).cgColor
        self.sendCodeBtn.layer.cornerRadius = 5


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendCode(_ sender: Any) {
        if AVUser.current()?.mobilePhoneNumber != nil{
            AVUser.requestPasswordReset(withPhoneNumber: AVUser.current()!.mobilePhoneNumber!, block: { (done:Bool, error:Error?) in
                if error == nil{
                    let alert = UIAlertController(title: "发送成功", message: "请查收短信", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.__countDownTimer), userInfo: nil, repeats: true)
                    self.sendCodeBtn.isEnabled = false
                }else{
                    let alert = UIAlertController(title: "发送失败", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
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

    @IBAction func confirmBtn(_ sender: Any) {
        if self.codeField.text == ""{
            let alert = UIAlertController(title: "错误", message: "请填写验证码", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if self.pwField.text != self.confirmPwField.text{
            let alert = UIAlertController(title: "错误", message: "密码不一致", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            AVUser.resetPassword(withSmsCode: self.codeField.text!, newPassword: self.pwField.text!) { (done:Bool, error:Error?) in
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
            }
        }
    }
    
    @IBAction func unhidePw1(_ sender: Any) {
        self.pwField.isSecureTextEntry = !self.pwField.isSecureTextEntry
    }
    
    @IBAction func unhidePw2(_ sender: Any) {
        self.confirmPwField.isSecureTextEntry = !self.confirmPwField.isSecureTextEntry
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

//@IBDesignable
class TextField: UITextField {
    @IBInspectable var insetX: CGFloat = 15
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}
