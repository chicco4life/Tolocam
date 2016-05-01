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
    

    @IBOutlet weak var collectionView: UICollectionView!

    
    var images = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: (screenWidth - 4)/3, height: (screenWidth - 4)/3)
        
        _ = UICollectionView(frame: CGRectMake(0, 0, screenWidth, screenHeight), collectionViewLayout: layout)
        
        print("collectionviewdidload is called")

        loadData()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print("hey there")
        
    }
    
    
    func loadData(){
        
        print("load data is called")
        print("username is", PFUser.currentUser()?.username)
        
        let query = PFQuery(className: "Posts")
        query.orderByDescending("createdAt")
        query.whereKey("addedBy", equalTo: (PFUser.currentUser()?.username)!)
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
        
        
        print("collectionview cell not getting called")
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ProfileCollectionViewCell
        
        
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
