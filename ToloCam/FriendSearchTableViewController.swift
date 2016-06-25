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

class FriendSearchTableViewController: PFQueryTableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var friendTableView: UITableView!
    
    var searchActive = false
    var data:[PFObject]!
    var filtered:[PFObject]!
    
    @IBOutlet var searchBar: UISearchBar!
    
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
        if searchBar.text != "" {
            query!.whereKey("username", containsString: searchBar.text!.lowercaseString)
        }
        query!.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        query!.orderByAscending("username")
        return query!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = true
        
        searchBar.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Refresh the table to ensure any data changes are displayed
        tableView.reloadData()
        
        // Delegate the search bar to this table view class
        searchBar.delegate = self
    }
    
    func search(searchText: String? = nil){
        let query = PFUser.query()
        if(searchText != nil){
            query!.whereKey("username", containsString: searchText)
        }
        query!.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            self.data = results as [PFObject]!
            self.tableView.reloadData()
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsSearchTableviewCell
        
        let username = object!["username"] as! String
        
        cell.friendUsername.text = username
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsSearchTableviewCell
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! FriendsSearchTableviewCell
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("OthersCollectionViewController") as! OthersCollectionViewController
        vc.userUsername = cell.friendUsername.text!
        
        print("username pass to othervc\(vc.userUsername)")
        
        self.navigationController!.pushViewController(vc, animated: true)
        
        
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        // Clear any search criteria
        searchBar.text = ""
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
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
    
    func searchUsers(searchText: String, completionBlock: PFQueryArrayResultBlock?)
        -> PFQuery {
            /*
             NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
             Regex can be slow on large datasets. For large amount of data it's better to store
             lowercased username in a separate column and perform a regular string compare.
             */
            let query = PFUser.query()!.whereKey("username",
                                                 matchesRegex: searchText, modifiers: "i")
            
            query.whereKey("username",
                           notEqualTo: PFUser.currentUser()!.username!)
            
            query.orderByAscending("username")
            query.limit = 20
            
            query.findObjectsInBackgroundWithBlock(completionBlock)
            
            return query
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filteredUsernames = self.usernames.filter({( newUsername : String) -> Bool in
            let categoryMatch = (scope == "All") || (newUsername == scope)
            return categoryMatch && newUsername.lowercaseString.containsString(searchText.lowercaseString)
        })
        
        tableView.reloadData()
    }
}

extension FriendSearchTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}