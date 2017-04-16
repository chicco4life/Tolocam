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
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var suggestionsField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePic.image = self.tempProfilePic
        self.username.text = AVUser.current()?.username
        self.nickname.text = ""
        self.emailLabel.text = AVUser.current()?.email
        self.phoneNumberLabel.text = AVUser.current()?.mobilePhoneNumber
        self.suggestionsField.delegate = self
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
                //send reset pw mail
            }
        default:
            break
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let chattingWithArray:[String] = []
        manager.chattingWith = chattingWithArray
        UserDefaults.standard.set(chattingWithArray, forKey: "chattingWithArray")
        
        AVUser.logOut()
        let vc = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.present(vc, animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        
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
        return true
    }
    
}
