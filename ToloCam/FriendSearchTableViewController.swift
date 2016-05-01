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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsSearchTableviewCell
        
        let username = object!["username"] as! String
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
