//
//  ProfileCollectionViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/19/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
//import ParseUI
import AVOSCloud

class ProfileCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, ImageCropViewControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!

    
    var imageFiles = [AVFile]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        profileName.text = AVUser.current()?.username
        
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
//        layout.itemSize = CGSize(width: (screenWidth - 4)/3, height: (screenWidth - 4)/3)
        
        
        let followerQuery = AVQuery(className: "Follow")
        followerQuery.whereKey("followingTo", equalTo:AVUser.current()!)
        var followerCount = Int()
        
        let followingQuery = AVQuery(className: "Follow")
        followingQuery.whereKey("followFrom", equalTo:AVUser.current()!)
        var followingsCount = Int()
        
        followerQuery.findObjectsInBackground({ (results, error) in
            if error==nil{
                followerCount = results!.count
                self.followersCount.text = String(followerCount-1)
            }
        })
        
        followingQuery.findObjectsInBackground({ (results, error) in
            if error==nil{
                followingsCount = results!.count
                self.followingCount.text = String(followingsCount-1)
            }
        })
        
        print("collectionviewdidload is called")
    
        __loadData()
    }
    
    override func viewDidLayoutSubviews() {
        
        let userQuery = AVQuery(className: "_User")
        userQuery.getObjectInBackground(withId: AVUser.current()!.objectId!) { (result:AVObject?, error:Error?) in
            if error==nil{
                if let file = result?["profileIm"] as? AVFile{
                    file.getDataInBackground({ (data:Data?, error:Error?) in
                        if error==nil{
                            self.profileImage.image = UIImage(data: data!)
                        }else{
                            //getData error
                            print(error!)
                        }
                    }, progressBlock: { (progress:Int) in
                        //progress is a value from 0~100
                    })
                }else{
                    //user has no profile image
                    self.profileImage.image = UIImage(named: "gray")!
                }
                //end of getData
            }else{
                //getObject's error
                print(error!)
            }
        }
        
            self.profileImage.layer.masksToBounds = true
        //        self.profileImage.clipsToBounds = true
            self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
            print("size.width is ",self.profileImage.frame.size.width)
            print("width is",self.profileImage.frame.width)
            self.profileImage.layer.borderWidth = 3
            self.profileImage.layer.borderColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
            self.profileImage.contentMode = .scaleAspectFill
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("hey there")
        
    }
    
    @IBAction func proflieImgBtn(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let controller = ImageCropViewController.init(image: image)
        controller?.delegate = self
        controller?.blurredBackground = true
        self.navigationController?.pushViewController(controller!, animated: true)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imageCropViewControllerSuccess(_ controller: UIViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        
//        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        
        self.profileImage.image = croppedImage
        
        let imageData = croppedImage.lowQualityJPEGNSData
        //let file = AVFile(data: data) as AVFile!
        let imageFile = AVFile(data: imageData)
        
        let userObj = AVUser.current()
//        let profilePic = userObj?.object(forKey: "profileImg") as! PFFile
//        userObj?.setObject(file!, forKey: "profileImg")
//        userObj?.set("profileImg", value: file!)
        userObj?.setObject(imageFile, forKey: "profileIm")

        userObj?.saveInBackground { (done:Bool, error:Error?) in
            if !done{
                print("set profile pic failed")
                self.profileImage.image = UIImage(named: "gray")
                let alertController = UIAlertController(title: "Error", message: "Profile image upload failed", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }else{
                print("set profile pic success")
                self.navigationController!.popViewController(animated: true)
            }
        }
        
    }
    
    func imageCropViewControllerDidCancel(_ controller: UIViewController!) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func __loadData(){
        
        print("load data is called")
        //print("username is", PFUser.current()?.username)
        
        let query = AVQuery(className: "Posts")
        query.addDescendingOrder("createdAt")
        let username = AVUser.current()!.username!
        query.whereKey("addedBy", equalTo: username)
        query.findObjectsInBackground{(results, error: Error?) -> Void in
            if (error == nil) {
                if let posts = results as! [AVObject]! {
                    for post in posts {
                        if  post["Image"] == nil{
                        }else{
                            let imageToLoad = post["Image"]! as! AVFile
                            self.imageFiles.append(imageToLoad)
                        }
                    }
                    self.collectionView.reloadData()
                }
            } else {
                print(error!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.imageFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileCollectionViewCell
        
        cell.imageToShow.image = UIImage(named: "gray.png")
        if self.imageFiles.count != 0{
            let file = self.imageFiles[indexPath.row]
            file.getDataInBackground({ (data:Data?, error:Error?) in
                cell.imageToShow.image = UIImage(data: data!)
            }) { (progress:Int) in
            }
        }
//        cell.imageToShow.file = (self.imageFiles[(indexPath as NSIndexPath).row] )
//        cell.imageToShow.loadInBackground()
        cell.contentView.frame = cell.bounds
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (UIScreen.main.bounds.size.width-4) / 3, height: (UIScreen.main.bounds.size.width-4) / 3)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        AVUser.logOut()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
