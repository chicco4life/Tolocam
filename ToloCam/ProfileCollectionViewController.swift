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

class ProfileCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!

    
    var images = [UIImage]()
    
    
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
            self.profileImage.backgroundColor = UIColor.black
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
    
    
    func loadData(){
        
        print("load data is called")
        print("username is", PFUser.current()?.username)
        
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.whereKey("addedBy", equalTo: (PFUser.current()?.username)!)
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
                            
                            
                            self.images.append(imageIWillUse )
                        }
                    }
                    
                    self.collectionView.reloadData()
                    
                    
                }
            } else {
                //Error
                
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
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileCollectionViewCell
        
        
        cell.imageToShow.image = (self.images[(indexPath as NSIndexPath).row] )
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
