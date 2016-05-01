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

class FriendSearchTableViewController: PFQueryTableViewController {
    
    @IBOutlet weak var friendTableView: UITableView!

    
    let searchController = UISearchController(searchResultsController: nil)
    var usernames = [String]()
    var filteredUsernames = [String]()
    var username = String()
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // Configure the PFQueryTableView
        self.parseClassName = String(PFUser.object())
        
        self.pullToRefreshEnabled = false
        self.paginationEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        let query = PFUser.query()
        query!.whereKey("username",
                        notEqualTo: PFUser.currentUser()!.username!)
        query!.orderByAscending("username")
        return query!
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showOthersProfile"{
//            var svc = segue.destinationViewController as! OthersCollectionViewController;
//            
//            svc.userUsername = self.username
//        }
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsSearchTableviewCell
        
        let username = object!["username"] as! String
        
        cell.friendUsername.text = username
        

        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsSearchTableviewCell
        
        var othersVC = OthersCollectionViewController()
        
        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! FriendsSearchTableviewCell
        
        othersVC.userUsername = cell.friendUsername.text!
    
        print("username pass to othervc\(othersVC.userUsername)")
        
//        self.presentViewController(othersVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(othersVC, animated: true)
//        self.navigationController?.presentViewController(othersVC, animated: true, completion: nil)

    }
    
//    func filterContentForSearchText(searchText: String, scope: String = "All") {
//        filteredUsernames = usernames.filter { username in
//            return username.name.lowercaseString.containsString(searchText.lowercaseString)
//        }
        
//        tableView.reloadData()
//    }
    
}
