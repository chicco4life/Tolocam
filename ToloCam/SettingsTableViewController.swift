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
        self.email.delegate = self
        self.email.tag = 1
        self.phone.delegate = self
        self.phone.tag = 2
        self.suggestionsField.delegate= self
        self.suggestionsField.tag = 3
        
        self.tableView.separatorColor = UIColor(colorLiteralRed: 249/255, green: 249/255, blue: 249/255, alpha: 1)
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

        self.profilePic.image = image
        
        let imageData = image.lowQualityJPEGNSData
        let imageFile = AVFile(data: imageData as Data)
        
        let userObj = AVUser.current()
        userObj?.setObject(imageFile, forKey: "profileIm")
        
        userObj?.saveInBackground { (done:Bool, error:Error?) in
            if !done{
                print("set profile pic failed")
                self.navigationController?.dismiss(animated: true, completion: { 
                    self.profilePic.image = UIImage(named: "gray")
                    let alertController = UIAlertController(title: "Error", message: "Profile image upload failed", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    alertController.addTextField(configurationHandler: { (field:UITextField) in
                        
                    })
                    alertController.addAction(UIAlertAction(title: "resend", style: .default, handler: nil))
                    alertController.addAction(UIAlertAction(title: "done", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                })
            }else{
                print("set profile pic success")
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag{
        case 0:
            let alert = UIAlertController(title: "提示", message: "确定要更改昵称吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action:UIAlertAction) in
                AVUser.current()
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
        case 1:
            
        case 2:
            
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
