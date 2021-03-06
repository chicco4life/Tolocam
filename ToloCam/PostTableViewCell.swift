//
//  PostTableViewCell.swift
//  ToloCam
//
//  Created by Federico Li on 2/11/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseUI


class PostTableViewCell: PFTableViewCell {
    
    
    @IBOutlet weak var postImageView: PFImageView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var addedBy: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
//    var yourLikes = Int()
    var parseObject: PFObject?
    @IBOutlet weak var yourLikesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gesture = UITapGestureRecognizer(target: self, action:#selector(PostTableViewCell.handleLike(_:)))
        gesture.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(gesture)
        
    }
    
    func handleLike(sender:AnyObject){
        print("like button pressed")
        if (parseObject != nil){
            //1. Get total likes from Parse
            if var likes:Int? = parseObject!.objectForKey("Likes") as? Int {
                
                //2. Set total likes to total likes+1, and upload.
                likes! += 1
                parseObject!.setObject(likes!, forKey: "Likes")
                
                //Reset the text of the total likes label.
                likesLabel?.text = "\(likes!) likes"
                
                //if first time like, need to upload current user's username to parse
                
                //Get dictionary from Parse, and look for the value associated to the key of current user's username.
                let dictionaryOfLikers:NSMutableDictionary = (parseObject?.objectForKey("likedBy") as! NSMutableDictionary)
//                print("DoL.currentuser: \(dictionaryOfLikers[(PFUser.currentUser()?.username)!] as! Int)")
//                print(dictionaryOfLikers[(PFUser.currentUser()?.username)!])
                var yourLikes = dictionaryOfLikers[PFUser.currentUser()!.username!]
                
                if yourLikes == nil{
                    let currentUser = PFUser.currentUser()?.username
                    dictionaryOfLikers[currentUser!] = 1
                    parseObject?.setObject(dictionaryOfLikers, forKey: "likedBy")
                    yourLikesLabel.text = "your likes: 1"
                }
                else{
                    let currentUser = PFUser.currentUser()?.username
                    var tempYourLikes = dictionaryOfLikers[currentUser!] as! Int
                    tempYourLikes+=1
                    dictionaryOfLikers[currentUser!] = tempYourLikes
                    parseObject?.setObject(dictionaryOfLikers, forKey: "likedBy")
                    yourLikesLabel.text = "your likes: \(tempYourLikes)"
                }
                
                parseObject!.saveInBackground();
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
