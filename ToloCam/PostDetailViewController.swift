//
//  PostDetailViewController.swift
//  ToloCam
//
//  Created by Leo Li on 04/03/2017.
//  Copyright © 2017 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud

class PostDetailViewController: UIViewController {
    var postObject = AVObject()
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postLikes: UILabel!
    @IBOutlet weak var captionView: UILabel!
    @IBOutlet weak var crownImg: UIImageView!
    
    @IBOutlet weak var postActions: UIButton!
    @IBOutlet var tagCollection: [UIButton]!
    
    @IBOutlet weak var captionViewTop: NSLayoutConstraint!
    
    @IBOutlet var likerCollection: [UIButton]!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.postObject["addedBy"] as! String) != AVUser.current()?.username{
            self.postActions.isHidden = true
        }
        
        if postObject["tags"] != nil{
            let tagArray = postObject["tags"] as! [String]
            for i in 0...tagArray.count-1{
                self.tagCollection[i].setTitle(tagArray[i], for: .normal)
                self.tagCollection[i].sizeToFit()
            }
        }
        
        self.postLikes.text = String(describing: postObject["Likes"] as! Int)
        self.captionView.text = postObject["Caption"] as? String
        
        tagCollection[3].translatesAutoresizingMaskIntoConstraints = false
        tagCollection[4].translatesAutoresizingMaskIntoConstraints = false
        
        var fourthTagIsOnFirstLine = false

        //if the fourth tag's width + the previous 3 tags' width is smaller than superview's width minus all spacing in between, don't put tag on second line
        if tagCollection[0].frame.width+tagCollection[1].frame.width+tagCollection[2].frame.width+tagCollection[3].frame.width < self.view.frame.width-84{
            let fourthTagLeading = NSLayoutConstraint(item: tagCollection[3], attribute: .leading, relatedBy: .equal, toItem: tagCollection[2], attribute: .trailing, multiplier: 1, constant: 18)
            self.view.addConstraint(fourthTagLeading)
            let fourthTagTop = NSLayoutConstraint(item: tagCollection[3], attribute: .top, relatedBy: .equal, toItem: tagCollection[2], attribute: .top, multiplier: 1, constant: 0)
            self.view.addConstraint(fourthTagTop)
            
            fourthTagIsOnFirstLine = true
            captionViewTop.constant = 13
        }else{
            //if the first 4 tags are longer than view.width, move to second line
            let fourthTagLeading = NSLayoutConstraint(item: tagCollection[3], attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 15)
            self.view.addConstraint(fourthTagLeading)
            let fourthTagTop = NSLayoutConstraint(item: tagCollection[3], attribute: .top, relatedBy: .equal, toItem: tagCollection[2], attribute: .bottom, multiplier: 1, constant: 0)
            self.view.addConstraint(fourthTagTop)
            //set caption view's y position to 13pt below lowest tag
            captionViewTop.constant = tagCollection[0].frame.height+13
        }
        
        //if the fifth tag's width + the previous 4 tags' width is smaller than superview's width minus all spacing in between, don't put tag on second line
        if tagCollection[0].frame.width+tagCollection[1].frame.width+tagCollection[2].frame.width+tagCollection[3].frame.width+tagCollection[4].frame.width < self.view.frame.width-102{
            
            print("tags width: ", tagCollection[0].frame.width+tagCollection[1].frame.width+tagCollection[2].frame.width+tagCollection[3].frame.width+tagCollection[4].frame.width)
            
            print("frame width: ", self.view.frame.width)
            
            let fifthTagLeading = NSLayoutConstraint(item: tagCollection[4], attribute: .leading, relatedBy: .equal, toItem: tagCollection[3], attribute: .trailing, multiplier: 1, constant: 18)
            self.view.addConstraint(fifthTagLeading)
            let fifthTagTop = NSLayoutConstraint(item: tagCollection[4], attribute: .top, relatedBy: .equal, toItem: tagCollection[3], attribute: .top, multiplier: 1, constant: 0)
            self.view.addConstraint(fifthTagTop)
        }else if fourthTagIsOnFirstLine == true{
            //if fourth tag is one first line, move fith to second line's first spot
            let fifthTagLeading = NSLayoutConstraint(item: tagCollection[4], attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 15)
            self.view.addConstraint(fifthTagLeading)
            let fifthTagTop = NSLayoutConstraint(item: tagCollection[4], attribute: .top, relatedBy: .equal, toItem: tagCollection[2], attribute: .bottom, multiplier: 1, constant: 0)
            self.view.addConstraint(fifthTagTop)
        }else if fourthTagIsOnFirstLine == false{
            //if fifth tag is already on second line, move to behind fourth tag
            let fifthTagLeading = NSLayoutConstraint(item: tagCollection[4], attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 18)
            self.view.addConstraint(fifthTagLeading)
            let fifthTagTop = NSLayoutConstraint(item: tagCollection[4], attribute: .top, relatedBy: .equal, toItem: tagCollection[3], attribute: .top, multiplier: 1, constant: 0)
            self.view.addConstraint(fifthTagTop)
        }
        
        if postObject["tags"] == nil{
            //if no tags captionView replaces tags' spot
            captionViewTop.constant = 0-tagCollection[0].frame.height
        }
        
        
        //title view config
        let titleView = UIView()
        titleView.frame.size.height = 37
        self.navigationItem.titleView = titleView
        
        let posterProfileImageView = UIImageView(image: #imageLiteral(resourceName: "gray"))
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
        
        let postDateLabel = UILabel()
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
        
        let posterNameLabel = UILabel()
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
                            self.__getData()
                        }else{
                            print(error.debugDescription)
                            self.__getData()
                        }
                    }
                    /*--------------------Poster's profile image query--------------------*/
                }else{
                    print(error.debugDescription)
                    self.__getData()
                }
            }else{
                posterProfileImageView.image = #imageLiteral(resourceName: "gray")
                self.__getData()
            }
            /*--------------------Poster's profile  query--------------------*/
        }
    }
    
    func __getData(){
        /*--------------------Post image query--------------------*/
        let postImageFile = self.postObject["Image"] as! AVFile
        postImageFile.getDataInBackground { (data:Data?, error:Error?) in
            if error==nil{
                self.postImage.image = UIImage(data:data!)
                
                /*--------------------Top 10 Likers' profile image query--------------------*/
                //Likers Leaderboard
                //Getting all likers and likes
                let dictionaryOfLikers = self.postObject["likedBy"] as? NSMutableDictionary
                var likersLeaderboard = [(String,Int)]()
                for pair in dictionaryOfLikers!{
                    let pairOfLikerLikes = ((pair.key as! String),(pair.value as! Int))
                    likersLeaderboard.append(pairOfLikerLikes)
                }
                //Sorting by likes
                likersLeaderboard.sort(by: { $0.1 > $1.1 })
                
                //getting top 10 likers
                var topLikers = [String]()
                if likersLeaderboard.count>0{
                    for likerRank in 0...likersLeaderboard.count-1 {
                        topLikers.append(likersLeaderboard[likerRank].0)
                    }
                }
                
                var top10LikerProfilePics = [UIImage]()
                let myGroup = DispatchGroup()
                
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
                                myGroup.leave()
                            }
                        }else{
                            print(error!.localizedDescription)
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
                    for i in 0...9{
                        self.likerCollection[i].setBackgroundImage(top10LikerProfilePics[i], for: .normal)
                    }
                    
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

    }
    @IBAction func postActions(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (action:UIAlertAction) in
            let query = AVQuery(className: "Posts")
            query.getObjectInBackground(withId: self.postObject.objectId!, block: { (object:AVObject?, error:Error?) in
                if error == nil{
                    object?.deleteInBackground({ (done:Bool, error:Error?) in
                        if error != nil{
                            print(error)
                        }else{
                            //fix dismiss
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }else{
                    print(error!)
                }
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true) { 
            
        }
    }
    
    @IBAction func showLikerLeaderboard(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "likerTableVC") as! LikerTableViewController
        vc.postObject = self.postObject
        self.navigationController?.pushViewController(vc, animated: true)
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
