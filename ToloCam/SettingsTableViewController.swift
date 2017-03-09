//
//  SettingsTableViewController.swift
//  ToloCam
//
//  Created by Leo Li on 04/03/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
                self.profilePic.image = UIImage(named: "gray")
                let alertController = UIAlertController(title: "Error", message: "Profile image upload failed", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }else{
                print("set profile pic success")
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
}
