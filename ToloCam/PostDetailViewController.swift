//
//  PostDetailViewController.swift
//  ToloCam
//
//  Created by Leo Li on 04/03/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud

class LikerLikesPair {
    var liker = String()
    var likes = Int()
}

class PostDetailViewController: UIViewController {
    var postObject = AVObject()
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postLikes: UILabel!
    @IBOutlet weak var captionView: UILabel!
    @IBOutlet weak var crownImg: UIImageView!
    
    @IBOutlet var tagCollection: [UIButton]!
    @IBOutlet weak var fourthTagLeading: NSLayoutConstraint!
    @IBOutlet weak var fourthTagTop: NSLayoutConstraint!
    @IBOutlet weak var fifthTagLeading: NSLayoutConstraint!
    @IBOutlet weak var fifthTagTop: NSLayoutConstraint!
    
    
    @IBOutlet var likerCollection: [UIButton]!
    @IBOutlet weak var liker1: UIButton!
    @IBOutlet weak var liker2: UIButton!
    @IBOutlet weak var liker3: UIButton!
    @IBOutlet weak var liker4: UIButton!
    @IBOutlet weak var liker5: UIButton!
    @IBOutlet weak var liker6: UIButton!
    @IBOutlet weak var liker7: UIButton!
    @IBOutlet weak var liker8: UIButton!
    @IBOutlet weak var liker9: UIButton!
    @IBOutlet weak var liker10: UIButton!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tagCollection[0].frame.width+tagCollection[1].frame.width+tagCollection[2].frame.width+tagCollection[3].frame.width < self.view.frame.width-30{
            fourthTagLeading = NSLayoutConstraint(item: tagCollection[3], attribute: .leading, relatedBy: .equal, toItem: tagCollection[2], attribute: .trailing, multiplier: 1, constant: 18)
            fourthTagTop = NSLayoutConstraint(item: tagCollection[3], attribute: .top, relatedBy: .equal, toItem: tagCollection[2], attribute: .top, multiplier: 1, constant: 0)
        }
        
        
        //title view config
        var titleView = UIView()
        titleView.frame.size.height = 37
        self.navigationItem.titleView = titleView
        
        var posterProfileImageView = UIImageView(image: #imageLiteral(resourceName: "gray"))
        posterProfileImageView.frame.size.height = 36
        posterProfileImageView.frame.size.width = 36
        posterProfileImageView.layer.masksToBounds = true
        posterProfileImageView.layer.cornerRadius = posterProfileImageView.frame.size.width/2
        posterProfileImageView.contentMode = .scaleAspectFill
        titleView.addSubview(posterProfileImageView)
        
        let posterProfImageTopConstraint = NSLayoutConstraint(item: posterProfileImageView, attribute: .top, relatedBy: .equal, toItem: titleView, attribute: .top, multiplier: 1, constant: 0)
        titleView.addConstraint(posterProfImageTopConstraint)
        
        let posterProfImageLeadingConstraint = NSLayoutConstraint(item: posterProfileImageView, attribute: .leading, relatedBy: .equal, toItem: titleView, attribute: .leading, multiplier: 1, constant: 0)
        titleView.addConstraint(posterProfImageLeadingConstraint)
        
        let posterProfImageBottomConstraint = NSLayoutConstraint(item: posterProfileImageView, attribute: .bottom, relatedBy: .equal, toItem: titleView, attribute: .bottom, multiplier: 1, constant: 0)
        titleView.addConstraint(posterProfImageBottomConstraint)
        
        var postDateLabel = UILabel()
        postDateLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(postDateLabel)
        let postDateLabelAttributes = [
            NSForegroundColorAttributeName: UIColor(red: 151/255, green: 147/255, blue: 147/255, alpha: 1),
            NSFontAttributeName : UIFont(name: "Avenir-Roman", size: 12)! // Note the !
        ]
        postDateLabel.attributedText = NSAttributedString(string: postObject["date"] as! String, attributes: postDateLabelAttributes)
        postDateLabel.sizeToFit()
        
        let postDateLabelLeadingConstraint = NSLayoutConstraint(item: postDateLabel, attribute: .leading, relatedBy: .equal, toItem: posterProfileImageView, attribute: .trailing, multiplier: 1, constant: 9)
        titleView.addConstraint(postDateLabelLeadingConstraint)
        
        let postDateLabelBottomConstraint = NSLayoutConstraint(item: postDateLabel, attribute: .bottom, relatedBy: .equal, toItem: titleView, attribute: .bottom, multiplier: 1, constant: 0)
        titleView.addConstraint(postDateLabelBottomConstraint)
        
        var posterNameLabel = UILabel()
        posterNameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(posterNameLabel)
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 80/255, green: 79/255, blue: 79/255, alpha: 1),
            NSFontAttributeName : UIFont(name: "PingFangSC-Medium", size: 14)! // Note the !
        ]
        posterNameLabel.attributedText = NSAttributedString(string: postObject["addedBy"] as! String, attributes: attributes)
        posterNameLabel.sizeToFit()
        
        let posterNameBottomConstraint = NSLayoutConstraint(item: postDateLabel, attribute: .top, relatedBy: .equal, toItem: posterNameLabel, attribute: .bottom, multiplier: 1, constant: 1)
        titleView.addConstraint(posterNameBottomConstraint)
        let posterNameLeadingConstraint = NSLayoutConstraint(item: posterNameLabel, attribute: .leading, relatedBy: .equal, toItem: posterProfileImageView, attribute: .trailing, multiplier: 1, constant: 9)
        
        titleView.addConstraint(posterNameLeadingConstraint)
        
        if postDateLabel.frame.width>=posterNameLabel.frame.width{
            titleView.frame.size.width = posterProfileImageView.frame.width+9+postDateLabel.frame.width
        }else{
            titleView.frame.size.width = posterProfileImageView.frame.width+9+posterNameLabel.frame.width
        }
        
        
        //poster profilePic
        var profilePicFile = AVFile()
        let pointer = postObject["postedBy"] as! AVObject
        let posterObjId = pointer["objectId"] as! String
        let userQuery = AVQuery(className: "_User")
        userQuery.whereKey("objectId", equalTo: posterObjId)
        /*--------------------Poster's profile  query--------------------*/
        userQuery.getFirstObjectInBackground { (user:AVObject?, error:Error?) in
            if error==nil{
                /*--------------------Poster's profile image query--------------------*/
                if user?["profileIm"] != nil{
                    profilePicFile = user?["profileIm"] as! AVFile
                    profilePicFile.getDataInBackground { (data:Data?, error:Error?) in
                        if error==nil{
                            posterProfileImageView.image = UIImage(data:data!)
                            
                            /*--------------------Post image query--------------------*/
                            var postImageFile = self.postObject["Image"] as! AVFile
                            postImageFile.getDataInBackground { (data:Data?, error:Error?) in
                                if error==nil{
                                    self.postImage.image = UIImage(data:data!)
                                    
                                    /*--------------------Top 10 Liker's profile image query--------------------*/
                                    //Likers Leaderboard
                                    //Getting all likers and likes
                                    let dictionaryOfLikers = self.postObject["likedBy"] as? NSMutableDictionary
                                    var likersLeaderboard = [LikerLikesPair]()
                                    for pair in dictionaryOfLikers!{
                                        let pairOfLikerLikes = LikerLikesPair()
                                        pairOfLikerLikes.liker = pair.key as! String
                                        pairOfLikerLikes.likes = pair.value as! Int
                                        likersLeaderboard.append(pairOfLikerLikes)
                                    }
                                    //Sorting by likes
                                    likersLeaderboard.sort(by: { $0.likes > $1.likes })
                                    
                                    //getting top 10 likers
                                    var topLikers = [String]()
                                    if likersLeaderboard.count>0{
                                        for likerRank in 0...likersLeaderboard.count-1 {
                                            topLikers.append(likersLeaderboard[likerRank].liker)
                                        }
                                    }
                                    
                                    var top10LikerProfilePics = [UIImage]()
                                    var myGroup = DispatchGroup()
                                    
                                    for liker in topLikers{
                                        myGroup.enter()
                                        
                                        let query = AVQuery(className: "_User")
                                        query.whereKey("username", equalTo: liker)
                                        query.getFirstObjectInBackground({ (result:AVObject?, error:Error?) in
                                            if error == nil{
                                                if result?["profileIm"] != nil{
                                                    let profileImgFile = result?["profileIm"] as? AVFile
                                                    profileImgFile?.getDataInBackground({ (data:Data?, error:Error?) in
                                                        print("Loaded a user profile pic")
                                                        myGroup.leave()
                                                        top10LikerProfilePics.append(UIImage(data: data!)!)
                                                        
                                                    })
                                                }else{
                                                    //no profile image
                                                    top10LikerProfilePics.append(#imageLiteral(resourceName: "gray.png"))
                                                }
                                            }else{
                                                print(error?.localizedDescription)
                                                
                                            }
                                        })
                                    }
                                    
                                    //sets images after data requests are finished
                                    myGroup.notify(queue: .main, execute: {
                                        //hide crown if no likers
                                        if top10LikerProfilePics.count != 0{
                                            self.crownImg.alpha = 1
                                        }
                                        
                                        //if less than 10 likers, append clear images
                                        if top10LikerProfilePics.count<10{
                                            print(top10LikerProfilePics.count)
                                            
                                            for _ in 1...10-top10LikerProfilePics.count{
                                                top10LikerProfilePics.append(#imageLiteral(resourceName: "clearImg"))
                                                
                                            }
                                            
                                        }
                                        
                                        //setting the profile pics for profile buttons
                                        self.liker1.setBackgroundImage(top10LikerProfilePics[0], for: .normal)
                                        self.liker2.setBackgroundImage(top10LikerProfilePics[1], for: .normal)
                                        self.liker3.setBackgroundImage(top10LikerProfilePics[2], for: .normal)
                                        self.liker4.setBackgroundImage(top10LikerProfilePics[3], for: .normal)
                                        self.liker5.setBackgroundImage(top10LikerProfilePics[4], for: .normal)
                                        self.liker6.setBackgroundImage(top10LikerProfilePics[5], for: .normal)
                                        self.liker7.setBackgroundImage(top10LikerProfilePics[6], for: .normal)
                                        self.liker8.setBackgroundImage(top10LikerProfilePics[7], for: .normal)
                                        self.liker9.setBackgroundImage(top10LikerProfilePics[8], for: .normal)
                                        self.liker10.setBackgroundImage(top10LikerProfilePics[9], for: .normal)
                                        
                                        for button in self.likerCollection{
                                            button.layer.masksToBounds = true
                                            button.layer.cornerRadius = button.frame.size.width/2
                                            button.contentMode = .scaleAspectFill
                                        }
                                    })
                                    
                                    /*--------------------Top 10 Liker's profile image query--------------------*/
                                    
                                }else{
                                    print(error.debugDescription)
                                }
                            }
                            /*--------------------Post image query--------------------*/
                        }else{
                            print(error.debugDescription)
                        }
                    }
                    /*--------------------Poster's profile image query--------------------*/
                }else{
                    print(error.debugDescription)
                }
            }else{
                posterProfileImageView.image = #imageLiteral(resourceName: "gray")
            }
            /*--------------------Poster's profile  query--------------------*/
        }
        
        
        
        
        self.postLikes.text = String(describing: postObject["Likes"] as! Int)
        self.captionView.text = postObject["Caption"] as? String
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //size of content view depending on label height
        let bottom = self.captionView.frame.maxY+89
        self.contentViewHeight.constant = bottom
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
