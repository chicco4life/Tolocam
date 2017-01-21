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
import LeanCloud
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
    var currentProfilePageUser = LCUser()
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
        let userQuery = LCQuery(className: "_User")
        userQuery.whereKey("username", .equalTo(userUsername))

        print(LCUser.current!)
        
        userQuery.getFirst { result in
            switch result{
            case .success(let objects):
                self.currentProfilePageUser = objects as! LCUser
                break
            case .failure(let error):
                print(error)
                break
            }
        }

        
        loadData()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //query for follow
        
        let followerQuery = LCQuery(className: "Follow")
        followerQuery.whereKey("followingTo", .equalTo(currentProfilePageUser))
        var followerCount = Int()
        
        let followingQuery = LCQuery(className: "Follow")
        followingQuery.whereKey("followFrom", .equalTo(currentProfilePageUser))
        var followingsCount = Int()
        
        followerQuery.find { (result) in
            if result.isSuccess{
                followerCount = (result.objects?.count)!
                self.followerCount.text = String(followerCount-1)
            }
        }
        
        followingQuery.find { (result) in
            if result.isSuccess{
                followingsCount = (result.objects?.count)!
                self.followingCount.text = String(followingsCount-1)
            }
        }
        
            let query = LCQuery(className: "Follow")
            query.whereKey("followFrom", .equalTo(LCUser.current!))
            query.whereKey("followingTo", .equalTo(self.currentProfilePageUser))
        
        
        query.getFirst { result in
            switch result{
            case .success(let objects):
                self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
                self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
                self.canFollow = false
                break
            case .failure(let error):
                self.followButtonTitle.setTitle("Follow", for: UIControlState())
                self.followButtonTitle.setTitleColor(UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1), for: UIControlState())
                self.canFollow = true
                break
            }
        }
    
        //profile image
    
        if self.currentProfilePageUser["profileImg"] != nil{
            let file = self.currentProfilePageUser["profileImg"] as? AVFile
            file?.getDataInBackground({ (data:Data?, error:Error?) in
                self.profileImage.image = UIImage(data: data!)
            }, progressBlock: { (progress:Int) in
                //progress is a value from 0~100
            })
//            self.profileImage.file = file
//            self.profileImage.loadInBackground()
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
        array.append((self.currentProfilePageUser.objectId?.stringValue)!)
        array.append((LCUser.current?.objectId?.stringValue)!)
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
            let follow = LCObject(className: "Follow")
            follow["followFrom"] = LCUser.current
            follow["followingTo"] = self.currentProfilePageUser
            follow.save()
            self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
            self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
            self.canFollow = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
            
        }else{
            let query = LCQuery(className: "Follow")
            query.whereKey("followFrom", .equalTo(LCUser.current!))
            query.whereKey("followingTo", .equalTo(self.currentProfilePageUser))
//            query.getFirstObjectInBackground(block: { (result:PFObject?, error:Error?) in
//                result?.deleteInBackground(block: nil)
//            })
            query.getFirst({ (result) in
                result.object?.delete({ (result) in
                    if (result.error != nil) || result.isFailure{
                        self.followButtonTitle.setTitle("Unfollow", for: UIControlState())
                        self.followButtonTitle.setTitleColor(UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1), for: UIControlState())
                        self.canFollow = false
                    }
                })
            })
            self.followButtonTitle.setTitle("Follow", for: UIControlState())
            self.followButtonTitle.setTitleColor(UIColor(red: 252/255, green: 105/255, blue: 134/255, alpha: 1), for: UIControlState())
            self.canFollow = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
        }
    }
    
    func loadData(){
        
        print("load data is called")
        print("username is", self.userUsername)
        
        let query = LCQuery(className: "Posts")
        query.whereKey("createdAt", .descending)
        query.whereKey("addedBy", .equalTo(self.userUsername))
        
        //query for post images
        query.find { (result) in
            if result.isSuccess{
                if let posts = result.objects as [LCObject]! {
                for post in posts {
                    if  post["Image"] == nil{
                    }else{
                        let imageToLoad = post["Image"]! as! AVFile
                        self.imageFiles.append(imageToLoad)
                    }
                }
                self.othersCollectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
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
}
