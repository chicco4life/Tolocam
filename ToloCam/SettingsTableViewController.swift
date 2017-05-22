//
//  SettingsTableViewController.swift
//  ToloCam
//
//  Created by Leo Li on 04/03/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    var tempProfilePic = UIImage()
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var suggestionsField: UITextField!
    @IBOutlet weak var logoutBtn: UIButton!
    var timer = Timer()
    var timerCount = 60

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePic.image = self.tempProfilePic
        self.username.text = AVUser.current()?.username
        let query = AVQuery(className: "_User")
        query.whereKey("objectId", equalTo: AVUser.current()!.objectId!)
        query.getFirstObjectInBackground { (user:AVObject?, error:Error?) in
            if error == nil{
                self.nickname.text = (user!["nickname"] as! String)
            }else{
                print(error!.localizedDescription)
            }
        }
        self.email.text = AVUser.current()?.email
        self.phone.text = AVUser.current()?.mobilePhoneNumber
        self.nickname.delegate = self
        self.nickname.tag = 0
        self.nickname.borderStyle = .none
        self.email.delegate = self
        self.email.tag = 1
        self.phone.delegate = self
        self.phone.tag = 2
        self.suggestionsField.delegate = self
        self.suggestionsField.tag = 3
        
        self.tableView.separatorColor = UIColor(colorLiteralRed: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        self.profilePic.layer.masksToBounds = true
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
        self.profilePic.contentMode = .scaleAspectFill
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section",indexPath.section)
        print("row",indexPath.row)
        switch indexPath.section{
        case 0:
            if indexPath.row == 0{
                //profileimg
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }else if indexPath.row == 2{
                //edit nickname
            }
        case 1:
            if indexPath.row == 0{
                //mail
            }else if indexPath.row == 1{
                //phone
            }else if indexPath.row == 2{
                //reset pw
                let alert = UIAlertController(title: nil, message: "选择身份验证方式", preferredStyle: UIAlertControllerStyle.actionSheet)
                alert.addAction(UIAlertAction.init(title: "邮箱", style: .default, handler: { (action:UIAlertAction) in
                    //send email
                    AVUser.requestPasswordResetForEmail(inBackground: (AVUser.current()?.email)!, block: { (done:Bool, error:Error?) in
                        if error == nil{
                            let alertView = UIAlertController(title: "重置密码", message: "已向您的邮箱发送重置密码邮件", preferredStyle: UIAlertControllerStyle.alert)
                            alertView.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                            self.present(alertView, animated: true, completion: nil)
                        }else{
                            let alertView = UIAlertController(title: "失败", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alertView.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.cancel, handler: nil))
                            self.present(alertView, animated: true, completion: nil)
                        }
                    })
                }))
                alert.addAction(UIAlertAction.init(title: "手机", style: .default, handler: { (action:UIAlertAction) in
                    //show vc
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsResetPWPhoneVC") as! SettingsResetPWPhoneViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }))
                alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "提示", message: "确认要登出吗？", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.destructive, handler: { (action:UIAlertAction) in
            let chattingWithArray:[String] = []
            manager.chattingWith = chattingWithArray
            UserDefaults.standard.set(chattingWithArray, forKey: "chattingWithArray")
            
            AVUser.logOut()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            self.present(vc, animated: false, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let imageData = image.lowQualityJPEGNSData
        let imageFile = AVFile(data: imageData as Data)
        
        let userObj = AVUser.current()
        userObj?.setObject(imageFile, forKey: "profileIm")
        
        userObj?.saveInBackground { (done:Bool, error:Error?) in
            if !done{
                print("set profile pic failed")
                self.navigationController?.dismiss(animated: true, completion: { 
                    let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                })
            }else{
                print("set profile pic success")
                self.profilePic.image = image
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag{
        case 0:
            var length = 0
            for char in textField.text!.characters {
                // 判断是否中文，是中文+2 ，不是+1
                length += "\(char)".lengthOfBytes(using: String.Encoding.utf8) == 3 ? 2 : 1
            }
            if textField.text == ""{
                let failAlert = UIAlertController(title: "错误", message: "请输入昵称", preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(failAlert, animated: true, completion: nil)
            }else if length>20{
                let failAlert = UIAlertController(title: "错误", message: "昵称字数超过限制", preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(failAlert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "提示", message: "确定要更改昵称吗？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action:UIAlertAction) in
                    let user = AVUser.current()
                    user?.setObject(textField.text, forKey: "nickname")
                    user?.saveInBackground({ (done:Bool, error:Error?) in
                        if done{
                            textField.resignFirstResponder()
                        }else{
                            let failAlert = UIAlertController(title: "更改名称失败", message: error?.localizedDescription, preferredStyle: .alert)
                            failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            self.present(failAlert, animated: true, completion: nil)
                        }
                    })
                }))
                self.present(alert, animated: true, completion: nil)
            }
        /*case 1:
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            
            if email.text == "" {
                let alertController = UIAlertController(title:"错误", message:"请输入邮箱地址", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }else if emailTest.evaluate(with: email.text) == false{
                let alertController = UIAlertController(title:"错误", message:"请输入正确的邮箱地址", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "提示", message: "确定要更改邮箱吗？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {(action:UIAlertAction) in
                    let userObj = AVUser.current()
                    userObj!.setObject(false, forKey: "emailVerified")
                    userObj!.saveInBackground({ (done:Bool, error:Error?) in
                        if error == nil{
                            AVUser.requestEmailVerify(self.email.text!, with: { (done:Bool, error:Error?) in
                                if error == nil{
                                    let alertController = UIAlertController(title: "提示", message: "请查收邮件验证邮箱", preferredStyle: UIAlertControllerStyle.alert)
                                    alertController.addAction(UIAlertAction(title: "重发邮件", style: UIAlertActionStyle.default, handler: { (actionUIAlertAction) in
                                        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer:Timer) in
                                            self.timerCount -= 1
                                            if self.timerCount == 0 {
                                                timer.invalidate()
                                                alert.actions[0].setValue("重发邮件", forKey: "title")
                                                alert.actions[0].isEnabled = true
                                            } else {
                                                alert.actions[0].setValue("\(self.timerCount)s", forKey: "title")
                                            }
                                        })
                                        alert.actions[0].isEnabled = false
                                    }))
                                    alertController.addAction(UIAlertAction(title: "验证完毕", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
                                        AVUser.current()?.refresh()
                                        if (AVUser.current()?.value(forKey: "emailVerified") as! Bool) == false{
                                            let failAlert = UIAlertController(title: "错误", message: "邮箱未被验证", preferredStyle: .alert)
                                            failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                                            self.present(failAlert, animated: true, completion: nil)
                                            textField.text = AVUser.current()?.email
                                        }else{
                                            let alert = UIAlertController(title: "成功", message: "邮箱地址已被更新", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
                                                AVUser.current()?.setObject(textField.text, forKey: "email")
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }))
                                    alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action:UIAlertAction) in
                                        textField.text = AVUser.current()?.email
                                    }))
                                    self.present(alertController, animated: true, completion: nil)
                                }else{
                                    let failAlert = UIAlertController(title: "错误", message: error!.localizedDescription, preferredStyle: .alert)
                                    failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                                    self.present(failAlert, animated: true, completion: nil)
                                }
                            })
                        }else{
                            let failAlert = UIAlertController(title: "错误", message: error!.localizedDescription, preferredStyle: .alert)
                            failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            self.present(failAlert, animated: true, completion: nil)
                        }
                    })
                }))
                self.present(alert, animated: true, completion: nil)
            }*/
            
//        case 2:
            
        case 3:
            let alert = UIAlertController(title: "提示", message: "确定要提交反馈吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action:UIAlertAction) in
                var feedbackObject = AVObject(className: "Feedback")
                feedbackObject["text"] = textField.text
                feedbackObject.saveInBackground({ (done:Bool, error:Error?) in
                    if done{
                        textField.resignFirstResponder()
                        textField.text = ""
                    }else{
                        let failAlert = UIAlertController(title: "错误", message: "提交反馈失败", preferredStyle: .alert)
                        failAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        self.present(failAlert, animated: true, completion: nil)
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
        return true
    }
    
}
