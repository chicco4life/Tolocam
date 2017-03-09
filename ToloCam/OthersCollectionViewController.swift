//
//  OthersCollectionViewController.swift
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

class OthersCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.imageFiles.count > 0{
            return self.imageFiles.count
        }else{
            return 0
        }
    }
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.othersCollectionView.dequeueReusableCell(withReuseIdentifier: "othersCell", for: indexPath) as! OthersCollectionViewCell
        
        cell.imageToShow.image = UIImage(named: "gray.png")
        let file = self.imageFiles[indexPath.row]
        file.getDataInBackground({ (data:Data?, error:Error?) in
            cell.imageToShow.image = UIImage(data: data!)
        }, progressBlock: { (progress:Int) in
            //progress is a value from 0~100
        })
        
        cell.contentView.frame = cell.bounds
        
        return cell
    }

    
    @IBOutlet weak var othersCollectionView: UICollectionView!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var userUsername = String()
    
    @IBOutlet var followButtonTitle: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    var imageFiles = [AVFile]()
    var currentProfilePageUser = AVUser()
    var canFollow = Bool()
        
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nav bar title attributes
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "PingFangSC-Medium", size: 20)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        //query for current page user
        let userQuery = AVQuery(className: "_User")
        userQuery.whereKey("username", equalTo:userUsername)
        
        userQuery.getFirstObjectInBackground({ (result, error) in
            if error==nil{
                self.currentProfilePageUser = result as! AVUser
                //use result of query here
                
                //query for follow
                
                let followerQuery = AVQuery(className: "Follow")
                followerQuery.whereKey("followingTo", equalTo:self.currentProfilePageUser)
                var followerCount = Int()
                
                let followingQuery = AVQuery(className: "Follow")
                followingQuery.whereKey("followFrom", equalTo:self.currentProfilePageUser)
                var followingsCount = Int()
                
                followerQuery.findObjectsInBackground({ (results, error) in
                    if error==nil{
                        followerCount = (results?.count)!
                        self.followerCount.text = String(followerCount-1)
                    }
                })
                
                followingQuery.findObjectsInBackground({ (results, error) in
                    if error==nil{
                        followingsCount = (results!.count)
                        self.followingCount.text = String(followingsCount-1)
                    }
                })
                
                let query = AVQuery(className: "Follow")
                query.whereKey("followFrom", equalTo:AVUser.current()!)
                query.whereKey("followingTo", equalTo:self.currentProfilePageUser)
                
                
                query.getFirstObjectInBackground({ (results, error) in
                    if error==nil{
                        self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
                        self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
                        self.canFollow = false
                    }else{
                        self.followButtonTitle.setTitle("Follow", for: UIControlState())
                        self.followButtonTitle.setTitleColor(UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1), for: UIControlState())
                        self.canFollow = true
                    }
                })
                
                //profile image
                
                print(self.currentProfilePageUser)
                
                if self.currentProfilePageUser["profileIm"] != nil{
                    let file = self.currentProfilePageUser["profileIm"] as? AVFile
                    file?.getDataInBackground({ (data:Data?, error:Error?) in
                        self.profileImage.image = UIImage(data: data!)
                    }, progressBlock: { (progress:Int) in
                        //progress is a value from 0~100
                    })
                }else{
                    self.profileImage.image = UIImage(named: "gray")!
                }
                
                self.profileImage.layer.masksToBounds = true
                self.profileImage.clipsToBounds = true
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
                self.profileImage.layer.borderWidth = 3
                self.profileImage.layer.borderColor = UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1).cgColor
                self.profileImage.contentMode = .scaleAspectFill
                
                //debugging stuff
                print("username in othervc \(self.userUsername)")
                
                self.usernameLabel.text = self.userUsername
                
            }else{
                print(error!)
            }
        })
        
        //layout
        let screenWidth = UIScreen.main.bounds.size.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: (screenWidth-2) / 3, height: (screenWidth-2) / 3)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        self.othersCollectionView!.collectionViewLayout = layout
        
        loadData()
        
        
    }
    
    @IBAction func chatBtn(_ sender: Any) {
        print("Chat btn pressed")
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        let ID = self.userUsername
        vc.username = ID
        vc.otherUser = self.currentProfilePageUser
        
        //using object IDs to create a channel name
        var array = [String]()
        array.append((self.currentProfilePageUser.objectId)!)
        array.append((AVUser.current()?.objectId)!)
        array.sort()
        
        let channelName = "\(array[0])-\(array[1])-channel"
        print(channelName)
        vc.currentChannel = channelName
        
        appDelegate.client?.subscribeToChannels([channelName], withPresence: true)
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func followPressed(_ sender: AnyObject) {
        print("followpressed")
        if canFollow == true{
            let follow = AVObject(className: "Follow")
            follow["followFrom"] = AVUser.current()
            follow["followingTo"] = self.currentProfilePageUser
            follow.save()
            self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
            self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
            self.canFollow = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
            
        }else{
            let query = AVQuery(className: "Follow")
            query.whereKey("followFrom", equalTo:AVUser.current()!)
            query.whereKey("followingTo", equalTo:self.currentProfilePageUser)
//            query.getFirstObjectInBackground(block: { (result:PFObject?, error:Error?) in
//                result?.deleteInBackground(block: nil)
//            })
            
            query.getFirstObjectInBackground({ (result, error) in
                if error==nil{
                    result?.deleteInBackground({ (done, failed) in
                        if (failed != nil){
                            //failed to delete
                            print(failed!)
                            self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
                            self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
                            self.canFollow = false
                        }else{
                            //successfully deleted
                            self.followButtonTitle.setTitle("Follow", for: UIControlState())
                            self.followButtonTitle.setTitleColor(UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1), for: UIControlState())
                            self.canFollow = true
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
                        }
                    })
                }else{
                    //error getting object
                    print(error!)
                }
            })
        }
    }
    
    func loadData(){
        
        print("load data is called")
        print("username is", self.userUsername)
        
        let query = AVQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.whereKey("addedBy", equalTo:self.userUsername)

        query.findObjectsInBackground { (results, error) in
            if error==nil{
                //retrieve data
                if let posts = results as? [AVObject]{
                    for post in posts{
                        if post["Image"] != nil{
                            let imageToLoad = post["Image"] as! AVFile
                            self.imageFiles.append(imageToLoad)
                        }
                    }
                }
                //end of retrieving data
                self.othersCollectionView.reloadData()
            }else{
                if error!.localizedDescription == "The Internet connection appears to be offline."{
                    let alertController = UIAlertController(title:"Error", message:"The Internet connection appears to be offline. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
//    func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
//    func collectionView(_ collectionView: UICollectionView!, numberOfItemsInSection section: Int!) -> Int!{
//        if self.imageFiles.count > 0{
//            return self.imageFiles.count
//        }else{
//            return 0
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView!, cellForItemAt indexPath: IndexPath!) -> UICollectionViewCell! {
//        
//        let cell = self.othersCollectionView.dequeueReusableCell(withReuseIdentifier: "othersCell", for: indexPath) as! OthersCollectionViewCell
//        
//        cell.imageToShow.image = UIImage(named: "gray.png")
//        let file = self.imageFiles[indexPath.row]
//        file.getDataInBackground({ (data:Data?, error:Error?) in
//            cell.imageToShow.image = UIImage(data: data!)
//        }, progressBlock: { (progress:Int) in
//            //progress is a value from 0~100
//        })
//
//        cell.contentView.frame = cell.bounds
//
//        return cell
//    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width-4) / 3, height: (UIScreen.main.bounds.size.width-4) / 3)
    }*/
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
