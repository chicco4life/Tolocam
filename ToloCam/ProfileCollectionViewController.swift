//
//  ProfileCollectionViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/19/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseUI

class ProfileCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, ImageCropViewControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!

    
    var imageFiles = [PFFile]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        profileName.text = PFUser.current()?.username
        
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
//        layout.itemSize = CGSize(width: (screenWidth - 4)/3, height: (screenWidth - 4)/3)
        
        
        //query for follow
        
        let followerQuery = PFQuery(className: "Follow")
        followerQuery.whereKey("followingTo", equalTo:PFUser.current()!)
        var followerCount = Int()
        followerQuery.findObjectsInBackground { (followers:[PFObject]?, error:Error?) in
            followerCount = (followers?.count)!
            self.followersCount.text = String(followerCount-1)
        }

        
        
        //following
        
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("followFrom", equalTo:PFUser.current()!)
        var followingsCount = Int()
        followingQuery.findObjectsInBackground { (following:[PFObject]?, error:Error?) in
            followingsCount = (following?.count)!
            self.followingCount.text = String(followingsCount-1)
        }
        
        
        print("collectionviewdidload is called")

        loadData()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        if PFUser.current()?.object(forKey: "profileImg") != nil{
            print(PFUser.current()?.object(forKey: "profileImg"))
            self.profileImage.file = PFUser.current()?.object(forKey: "profileImg") as? PFFile
            self.profileImage.loadInBackground()
        }else{
            self.profileImage.image = UIImage(named: "gray")
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
        
        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        
        self.profileImage.image = croppedImage
        
        let data = croppedImage.lowQualityJPEGNSData
        let file = PFFile(data: data) as PFFile!
        
        let userObj = PFUser.current()
//        let profilePic = userObj?.object(forKey: "profileImg") as! PFFile
        userObj?.setObject(file!, forKey: "profileImg")
        
//        print(profilePic)

        
//        print(profileImages)
//        
        userObj?.saveInBackground { (done:Bool, error:Error?) in
            if !done{
                self.profileImage.image = UIImage(named: "gray")
                let alertController = UIAlertController(title: "Error", message: "Profile image upload failed", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        
        
        self.navigationController!.popViewController(animated: true)
    }
    
    func imageCropViewControllerDidCancel(_ controller: UIViewController!) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func loadData(){
        
        print("load data is called")
        //print("username is", PFUser.current()?.username)
        
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.whereKey("addedBy", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground{(posts:[PFObject]?, error: Error?) -> Void in

            if (error == nil) {
                if let posts = posts as [PFObject]! {
                    for post in posts {
                        if  post["Image"] == nil{
                        }else{
                            let imageToLoad = post["Image"]! as! PFFile
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        if self.imageFiles.count > 0
        {
            return self.imageFiles.count
        }else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileCollectionViewCell
        
        cell.imageToShow.image = UIImage(named: "gray.png")
        cell.imageToShow.file = (self.imageFiles[(indexPath as NSIndexPath).row] )
        cell.imageToShow.loadInBackground()
        cell.contentView.frame = cell.bounds
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (UIScreen.main.bounds.size.width-4) / 3, height: (UIScreen.main.bounds.size.width-4) / 3)
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
