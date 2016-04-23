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
    var yourLikes = NSUserDefaults.standardUserDefaults().integerForKey("yourLikes")
    var parseObject: PFObject?
    @IBOutlet weak var yourLikesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gesture = UITapGestureRecognizer(target: self, action:#selector(PostTableViewCell.handleLike(_:)))
        gesture.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(gesture)
        if yourLikes == 1{
            yourLikesLabel.text = "You liked 1 time"
        }else{
            yourLikesLabel.text = "You liked \(NSUserDefaults.standardUserDefaults().integerForKey("yourLikes"))times"
        }
    }
    
    func handleLike(sender:AnyObject){
        print("like button pressed")
        if (parseObject != nil){
            if var likes:Int? = parseObject!.objectForKey("Likes") as? Int {
                likes! += 1
                
                parseObject!.setObject(likes!, forKey: "Likes");
                
                likesLabel?.text = "\(likes!) likes";
                if yourLikes == 0 {
                    //                    add currentuser username to fromUser array
                    var username = PFUser.currentUser()?.username
                    parseObject?.addObject(username!, forKey: "likedBy")
                }
                yourLikes+=1
                yourLikesLabel.text = "You liked \(yourLikes) times"
                NSUserDefaults.standardUserDefaults().setInteger(yourLikes, forKey: "yourLikes")
                parseObject!.saveInBackground();
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
