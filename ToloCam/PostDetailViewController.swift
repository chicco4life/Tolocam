//
//  PostDetailViewController.swift
//  ToloCam
//
//  Created by Leo Li on 04/03/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud

class likerLikesPair {
    var liker = String()
    var likes = Int()
}

class PostDetailViewController: UIViewController {
    var postObject = AVObject()
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var posterProfileImage: UIImageView!
    @IBOutlet weak var posterUsername: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postLikes: UILabel!
    @IBOutlet weak var kingOfTheLikesProfilePic: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var captionView: UILabel!
    
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
                profilePicFile = user?["profileIm"] as! AVFile
                profilePicFile.getDataInBackground { (data:Data?, error:Error?) in
                    if error==nil{
                        self.posterProfileImage.image = UIImage(data:data!)
                        
                        /*--------------------Post image query--------------------*/
                        var postImageFile = self.postObject["Image"] as! AVFile
                        postImageFile.getDataInBackground { (data:Data?, error:Error?) in
                            if error==nil{
                                self.postImage.image = UIImage(data:data!)
                                
                                /*--------------------Top 10 Liker's profile image query--------------------*/
                                //Likers Leaderboard
                                //Getting all likers and likes
//                                let likedBy = self.postObject["likedBy"] as! AVObject
//                                let dictionaryOfLikers = likedBy.dictionaryForObject()
                                let dictionaryOfLikers = self.postObject["likedBy"] as? NSMutableDictionary
                                var likersLeaderboard = [likerLikesPair]()
                                for pair in dictionaryOfLikers!{
                                    let pairOfLikerLikes = likerLikesPair()
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
                                for liker in topLikers{
                                    let query = AVQuery(className: "_User")
                                    query.whereKey("username", equalTo: liker)
                                    query.getFirstObjectInBackground({ (result:AVObject?, error:Error?) in
                                        if error == nil{
                                            if result?["profileIm"] != nil{
                                                let profileImgFile = result?["profileIm"] as? AVFile
                                                profileImgFile?.getDataInBackground({ (data:Data?, error:Error?) in
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
                                //if less than 10 likers, append clear images
                                if top10LikerProfilePics.count<10{
                                    print(top10LikerProfilePics.count)
                                    
                                    for _ in 1...10-top10LikerProfilePics.count{
                                        top10LikerProfilePics.append(#imageLiteral(resourceName: "clearImg"))
                                        
                                    }
                                    
                                }
                                
                                print(top10LikerProfilePics.count)
                                
                                //setting the profile pics for profile buttons
                                self.liker1.setImage(top10LikerProfilePics[0], for: .normal)
                                self.liker2.setImage(top10LikerProfilePics[1], for: .normal)
                                self.liker3.setImage(top10LikerProfilePics[2], for: .normal)
                                self.liker4.setImage(top10LikerProfilePics[3], for: .normal)
                                self.liker5.setImage(top10LikerProfilePics[4], for: .normal)
                                self.liker6.setImage(top10LikerProfilePics[5], for: .normal)
                                self.liker7.setImage(top10LikerProfilePics[6], for: .normal)
                                self.liker8.setImage(top10LikerProfilePics[7], for: .normal)
                                self.liker9.setImage(top10LikerProfilePics[8], for: .normal)
                                self.liker10.setImage(top10LikerProfilePics[9], for: .normal)
                                
                                //king of the likes profile pic
                                self.kingOfTheLikesProfilePic.image = top10LikerProfilePics[0]
                                
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
            /*--------------------Poster's profile  query--------------------*/
        }
        
        //poster details
        self.posterUsername.text = postObject["addedBy"] as? String
        self.posterProfileImage.layer.masksToBounds = true
        self.posterProfileImage.layer.cornerRadius = self.posterProfileImage.frame.size.width/2
        self.posterProfileImage.contentMode = .scaleAspectFill
        self.postDate.text = postObject["date"] as? String
        var tagsLabelText = ""
        if postObject["tags"] != nil{
            let tags = postObject["tags"] as? Array<String>
            var tagNumber = 0
            for tag in tags!{
                tagNumber+=1
                if tagNumber != 5{
                    //if not last tag add tag with 5 spaces after it
                    tagsLabelText+="\(tag)     "
                }else{
                    tagsLabelText+=tag
                }
            }
            self.tagsLabel.text = tagsLabelText
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
