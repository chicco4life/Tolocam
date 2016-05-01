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
    
    
    //    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var othersCollectionView: UICollectionView!
    
    var userUsername = String()
    
    @IBOutlet var followButtonTitle: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    var images = [UIImage]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userQuery = PFUser.query()
        userQuery!.whereKey("username", equalTo: userUsername)
        
//        print("userUsername: \(userUsername)")
        
        print(PFUser.currentUser()!)

        var currentProfilePageUser = PFUser()
        
        userQuery!.findObjectsInBackgroundWithBlock({ (result:[PFObject]?, error:NSError?) in
            currentProfilePageUser = result![0] as! PFUser
         })
        
        let query = PFQuery(className: "Follow")
        query.whereKey("followFrom", equalTo: PFUser.currentUser()!.objectId!)
        query.whereKey("followingTo", equalTo: currentProfilePageUser)
        print(currentProfilePageUser)
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) in
            if result == nil{
                print("currentuser is not following this user")
                self.followButtonTitle.setTitle("Follow", forState: .Normal)
            }else{
                print("currentuser is follwing this user")
                self.followButtonTitle.setTitle("Unfollow", forState: .Normal)
            }
        }
        
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: (screenWidth - 4)/3, height: (screenWidth - 4)/3)
        
        _ = UICollectionView(frame: CGRectMake(0, 0, screenWidth, screenHeight), collectionViewLayout: layout)
        
        print("username in othervc \(self.userUsername)")
        self.usernameLabel.text = self.userUsername
        
//        othersCollectionView.backgroundColor = UIColor.redColor()
        loadData()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func followPressed(sender: AnyObject) {
    }
    
    func loadData(){
        
        print("load data is called")
        print("username is", self.userUsername)
        
        let query = PFQuery(className: "Posts")
        query.orderByDescending("createdAt")
        query.whereKey("addedBy", equalTo: self.userUsername)
        query.findObjectsInBackgroundWithBlock{
            (posts:[PFObject]?, error: NSError?) -> Void in
            
            
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        if self.images.count > 0
        {
            return self.images.count
        }else
        {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
//        print("collectionview cell not getting called")
        //        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("othersCell", forIndexPath: indexPath) as! OthersCollectionViewCell
        let cell = self.othersCollectionView.dequeueReusableCellWithReuseIdentifier("othersCell", forIndexPath: indexPath) as! OthersCollectionViewCell
        
        cell.imageToShow.image = (self.images[indexPath.row] )
        cell.contentView.frame = cell.bounds
        
        
        return cell
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: (UIScreen.mainScreen().bounds.size.width-4) / 3, height: (UIScreen.mainScreen().bounds.size.width-4) / 3)
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
