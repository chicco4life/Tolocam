//
//  OthersCollectionViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/19/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseUI

class OthersCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var othersCollectionView: UICollectionView!
    
    var userUsername = String()
    
    @IBOutlet var followButtonTitle: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    var images = [UIImage]()
    var currentProfilePageUser = PFUser()
    var canFollow = Bool()
        
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nav bar title attributes
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        //query for current page user
        let userQuery = PFUser.query()
        userQuery!.whereKey("username", equalTo: userUsername)
        
//        print("userUsername: \(userUsername)")
        
        print(PFUser.current()!)
        
//        userQuery!.findObjectsInBackgroundWithBlock({ (result:[PFObject]?, error:NSError?) in
//            self.currentProfilePageUser = result![0] as! PFUser
//         })
        
        
        if PFUser.current()?.objectId == nil {
            PFUser.current()?.saveInBackground(block: { (done:Bool, error:Error?) in
                userQuery!.getFirstObjectInBackground { (result:PFObject?, error:Error?) in
                    self.currentProfilePageUser = result as! PFUser
                }
            })
        } else {
            userQuery!.getFirstObjectInBackground { (result:PFObject?, error:Error?) in
                self.currentProfilePageUser = result as! PFUser
            }
        }

        
//        let screenWidth = UIScreen.main.bounds.size.width
//        let screenHeight = UIScreen.main.bounds.size.height
//        
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
//        layout.itemSize = CGSize(width: (screenWidth - 4)/3, height: (screenWidth - 4)/3)
        
//        _ = UICollectionView(frame: CGRectMake(0, 0, screenWidth, screenHeight), collectionViewLayout: layout)
        
        loadData()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if currentProfilePageUser.objectId == nil{
//            currentProfilePageUser.saveInBackgroundWithBlock({ (suceess:Bool, error: NSError?) in
//            })
//        }
        let query = PFQuery(className: "Follow")
        query.whereKey("followFrom", equalTo: PFUser.current()!)
        query.whereKey("followingTo", equalTo: self.currentProfilePageUser)
        
        if PFUser.current()?.objectId == nil{
            PFUser.current()?.saveInBackground(block: { (done:Bool, error:Error?) in
                query.getFirstObjectInBackground { (result:PFObject?, error:Error?) in
                    if error==nil{
                        if (result != nil){
                            self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
                            self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
                            self.canFollow = false
                        }
                    }else{
                        //                print("Failed with error \(error)")
                        self.followButtonTitle.setTitle("Follow", for: UIControlState())
                        self.followButtonTitle.setTitleColor(UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1), for: UIControlState())
                        self.canFollow = true
                    }
                }
            })
        }else{
            query.getFirstObjectInBackground { (result:PFObject?, error:Error?) in
                if error==nil{
                    if (result != nil){
                        self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
                        self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
                        self.canFollow = false
                    }
                }else{
                    //                print("Failed with error \(error)")
                    self.followButtonTitle.setTitle("Follow", for: UIControlState())
                    self.followButtonTitle.setTitleColor(UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1), for: UIControlState())
                    self.canFollow = true
                }
            }
        }
        
        //profile image
    
        self.profileImage.backgroundColor = UIColor.black
        self.profileImage.layer.masksToBounds = true
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.layer.borderWidth = 3
        self.profileImage.layer.borderColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
        self.profileImage.contentMode = .scaleAspectFill
        
        //query for follow
        
        let followerQuery = PFQuery(className: "Follow")
        followerQuery.whereKey("followingTo", equalTo:currentProfilePageUser)
        var followerCount = Int()
        //following
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("followFrom", equalTo:currentProfilePageUser)
        var followingsCount = Int()
        
        //query
        
        if PFUser.current()?.objectId == nil {
            PFUser.current()?.saveInBackground(block: { (done:Bool, error:Error?) in
                followerQuery.findObjectsInBackground { (followers:[PFObject]?, error:Error?) in
                    followerCount = (followers?.count)!
                    self.followerCount.text = String(followerCount-1)
                }
                followingQuery.findObjectsInBackground { (following:[PFObject]?, error:Error?) in
                    followingsCount = (following?.count)!
                    self.followingCount.text = String(followingsCount-1)
                }
            })
        }else{
            followerQuery.findObjectsInBackground { (followers:[PFObject]?, error:Error?) in
                followerCount = (followers?.count)!
                self.followerCount.text = String(followerCount-1)
            }
            followingQuery.findObjectsInBackground { (following:[PFObject]?, error:Error?) in
                followingsCount = (following?.count)!
                self.followingCount.text = String(followingsCount-1)
            }
        }
        
        //debugging stuff
        print("username in othervc \(self.userUsername)")
        self.usernameLabel.text = self.userUsername
        
    }
    
    @IBAction func followPressed(_ sender: AnyObject) {
        print("followpressed")
        if canFollow == true{
            let follow = PFObject(className: "Follow")
            follow["followFrom"] = PFUser.current()!
            follow["followingTo"] = self.currentProfilePageUser
            if PFUser.current()?.objectId == nil{
                PFUser.current()?.saveInBackground(block: { (done:Bool, error:Error?) in
                    follow.saveInBackground()
                })
            }else{
                    follow.saveInBackground()
            }
            self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
            self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
            self.canFollow = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
            
        }else{
            let query = PFQuery(className: "Follow")
            query.whereKey("followFrom", equalTo:PFUser.current()!)
            query.whereKey("followingTo", equalTo: self.currentProfilePageUser)
            if PFUser.current()?.objectId == nil{
                PFUser.current()?.saveInBackground(block: { (done:Bool, error:Error?) in
                    query.getFirstObjectInBackground(block: { (result:PFObject?, error:Error?) in
                        result?.deleteInBackground(block: nil)
                    })
                })
            }else{
                query.getFirstObjectInBackground(block: { (result:PFObject?, error:Error?) in
                    result?.deleteInBackground(block: nil)
                })
            }
            
            self.followButtonTitle.setTitle("Follow", for: UIControlState())
            self.followButtonTitle.setTitleColor(UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1), for: UIControlState())
            self.canFollow = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
        }
    }
    
    func loadData(){
        
        print("load data is called")
        print("username is", self.userUsername)
        
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.whereKey("addedBy", equalTo: self.userUsername)
        if PFUser.current()?.objectId == nil{
            PFUser.current()?.saveInBackground(block: { (done:Bool, error:Error?) in
                query.findObjectsInBackground{(posts:[PFObject]?, error: Error?) -> Void in
                    if (error == nil) {
                        if let posts = posts as [PFObject]! {
                            for post in posts {
                                if  post["Image"] == nil{
                                    print("    CHECK THIS LOL NIL )")
                                }else{
                                    print("    CHECK THIS LOL \(post["Image"])")
                                    let imageToLoad = post["Image"]! as! PFFile
                                    var imageIWillUse = UIImage()
                                    do {
                                        try imageIWillUse = UIImage(data:imageToLoad.getData())!
                                    } catch {
                                        print(error)
                                    }
                                    self.images.append(imageIWillUse)
                                }
                            }
                            self.othersCollectionView.reloadData()
                        }
                    } else {
                        //Error
                    }
                }
            })
        }else{
            query.findObjectsInBackground{(posts:[PFObject]?, error: Error?) -> Void in
                if (error == nil) {
                    if let posts = posts as [PFObject]! {
                        for post in posts {
                            if  post["Image"] == nil{
                                print("    CHECK THIS LOL NIL )")
                            }else{
                                print("    CHECK THIS LOL \(post["Image"])")
                                let imageToLoad = post["Image"]! as! PFFile
                                var imageIWillUse = UIImage()
                                do {
                                    try imageIWillUse = UIImage(data:imageToLoad.getData())!
                                } catch {
                                    print(error)
                                }
                                self.images.append(imageIWillUse)
                            }
                        }
                        self.othersCollectionView.reloadData()
                    }
                } else {
                    //Error
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        if self.images.count > 0
        {
            return self.images.count
        }else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
//        print("collectionview cell not getting called")
        //        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("othersCell", forIndexPath: indexPath) as! OthersCollectionViewCell
        let cell = self.othersCollectionView.dequeueReusableCell(withReuseIdentifier: "othersCell", for: indexPath) as! OthersCollectionViewCell
        
        cell.imageToShow.image = (self.images[(indexPath as NSIndexPath).row])
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
