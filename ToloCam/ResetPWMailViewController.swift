//
//  ResetPWMailViewController.swift
//  ToloCam
//
//  Created by Leo Li on 02/05/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import  AVOSCloud

class ResetPWMailViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName : UIFont(name: "PingFangSC-Light", size: 22)! // Note the !
        ]
        self.emailField.attributedPlaceholder = NSAttributedString(string: "邮箱地址", attributes: attributes)
        self.emailField.autocapitalizationType = UITextAutocapitalizationType.none
        self.emailField.font = UIFont(name: "PingFangSC-Light", size: 22)
        self.emailField.textColor = UIColor.white
        self.emailField.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMail(_ sender: Any) {
        if self.emailField.text == ""{
            let alert = UIAlertController(title: "错误", message: "请输入邮箱地址", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let query = AVQuery(className: "_User")
            query.whereKey("email", equalTo: self.emailField.text!)
            query.findObjectsInBackground { (results:[Any]?, error:Error?) in
                if error==nil{
                    if results?.count != 0{
                        AVUser.requestPasswordResetForEmail(inBackground: self.emailField.text!, block: { (done:Bool, error:Error?) in
                            if done{
                                let alert = UIAlertController(title: "发送成功", message: "请查收邮件重置密码", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) in
                                    self.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }else{
                                let alert = UIAlertController(title: "发送失败", message: "请重试", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                print(error!)
                            }
                        })
                    }else{
                        let alert = UIAlertController(title: "错误", message: "没有符合该邮箱的账号", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    print(error!)
                }
            }
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
