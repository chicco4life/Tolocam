//
//  FriendSearchTableViewController.swift
//  ToloCam
//
//  Created by Leo Li on 4/30/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseUI

class FriendSearchTableViewController: UITableViewController {
    
    @IBOutlet weak var friendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getFollowingUsersForUser(user: PFUser, completionBlock: PFQueryArrayResultBlock?) {
        let query = PFQuery(className: "Follow")
        query.whereKey("followFrom", equalTo:user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFObject(className: "Follow")
        followObject.setObject(user, forKey: "followFrom")
        followObject.setObject(toUser, forKey: "followingTo")
        
        followObject.saveInBackgroundWithBlock(nil)
    }
    
    func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: "Follow")
        query.whereKey("followFrom", equalTo:user)
        query.whereKey("follwingTo", equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [PFObject]?, error: NSError?) -> Void in
            
            let results = results ?? []
            
            for follow in results {
                follow.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    
    func allUsers(completionBlock: PFQueryArrayResultBlock?) -> PFQuery {
        let query = PFUser.query()!
        // exclude the current user
        query.whereKey("username",
                       notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending("username")
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }

}
