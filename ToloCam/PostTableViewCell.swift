//
//  PostTableViewCell.swift
//  ToloCam
//
//  Created by Federico Li on 2/11/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
//import ParseUI
import AVOSCloud


class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var addedBy: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
//    var yourLikes = Int()
    var object: AVObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gesture = UITapGestureRecognizer(target: self, action:#selector(PostTableViewCell.handleLike(_:)))
        gesture.numberOfTapsRequired = 2
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(gesture)
        
        self.profilePicImgView.layer.masksToBounds = true
        self.profilePicImgView.layer.cornerRadius = self.profilePicImgView.frame.size.width/2
        self.profilePicImgView.contentMode = .scaleAspectFill
        
       //caption displays ellipses if exceeds two lines
        self.postCaption.numberOfLines = 2
        self.postCaption.adjustsFontSizeToFitWidth = false
        self.postCaption.lineBreakMode = .byTruncatingTail
        
    }
    
    func handleLike(_ sender:AnyObject){
        print("like button pressed")
        if (object != nil){
            //1. Get total likes from Parse
            if var likes:Int = object!["Likes"] as? Int {
                
                //2. Set total likes to total likes+1, and upload.
                likes += 1
//                object!.setObject(likes!, forKey: "Likes")
                object!.setObject(likes, forKey: "Likes")
                
                //Reset the text of the total likes label.
                likesLabel?.text = "\(likes)"
                
                //if first time like, need to upload current user's username to parse
                
                //Get dictionary from Parse, and look for the value associated to the key of current user's username.
                let dictionaryOfLikers:NSMutableDictionary = (object?["likedBy"] as! NSMutableDictionary)
                let yourLikes = dictionaryOfLikers[AVUser.current()!.username!]
                
                if yourLikes == nil{
                    let currentUser = AVUser.current()!.username
                    dictionaryOfLikers[currentUser!] = 1
                    object?.setObject(dictionaryOfLikers, forKey: "likedBy")
                }
                else{
                    let currentUser = AVUser.current()!.username
                    var tempYourLikes = dictionaryOfLikers[currentUser!] as! Int
                    tempYourLikes+=1
                    dictionaryOfLikers[currentUser!] = tempYourLikes
                    object?.setObject(dictionaryOfLikers, forKey: "likedBy")
                }
                
                object!.saveInBackground()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
