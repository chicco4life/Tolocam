//
//  FriendSearchViewController.swift
//  ToloCam
//
//  Created by Federico Li on 4/23/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseUI

class FriendSearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // stores all the users that match the current search query
    var users: [PFUser]?
    
    /*
     This is a local cache. It stores all the users this user is following.
     It is used to update the UI immediately upon user interaction, instead of waiting
     for a server response.
     */
    
    // the current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did Indeed Load")

        // Do any additional setup after loading the view.
        // MARK: Users
        
        /**
         Fetch all users, except the one that's currently signed in.
         Limits the amount of users returned to 20.
         
         :param: completionBlock The completion block that is called when the query completes
         
         :returns: The generated PFQuery
         */
         func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
            
            print("allUsers fetched")
            
            let userQuery = PFQuery(className: "User")
            userQuery.orderByAscending("username")
            
            
            // exclude the current user
            //Reference Query?.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            
            
            userQuery.whereKey("username",
                           notEqualTo: PFUser.currentUser()!.username!)
            userQuery.limit = 20
            
            userQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) -> Void in })

            
            //userQuery.findObjectsInBackgroundWithBlock(completionBlock)
            
            return userQuery
            }
        
        /**
         Fetch users whose usernames match the provided search term.
         
         :param: searchText The text that should be used to search for users
         :param: completionBlock The completion block that is called when the query completes
         
         :returns: The generated PFQuery
         */
            
         func searchUsers(searchText: String, completionBlock: PFArrayResultBlock)
            -> PFQuery {
                /*
                 NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
                 Regex can be slow on large datasets. For large amount of data it's better to store
                 lowercased username in a separate column and perform a regular string compare.
                 */
                let Query = PFUser.query()!.whereKey("username",
                                                     matchesRegex: searchText, modifiers: "i")
                
                print("user searched")

                
                Query.whereKey("username",
                               notEqualTo: PFUser.currentUser()!.username!)
                
                Query.orderByAscending("username")
                Query.limit = 20
                
                Query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) -> Void in })
                
                //userQuery.findObjectsInBackgroundWithBlock(completionBlock)
                
                print("user search done")
     
                
                return Query
                
                }
        }
    
    



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

