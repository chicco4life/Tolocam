//
//  FriendSearchTableViewController.swift
//  ToloCam
//
//  Created by Leo Li on 4/30/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
//import ParseUI
import AVOSCloud
import LeanCloud

class FriendSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var friendTableView: UITableView!
    
    var searchActive = false
    var data:[LCObject]!
    var filtered:[LCObject]!
    
    @IBOutlet var searchBar: UISearchBar!
    
    var usernames = [String]()
    var filteredUsernames = [String]()
    var username = String()
    
//    override init(style: UITableViewStyle, className: String!) {
//        super.init(style: style, className: className)
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//        
//        // Configure the PFQueryTableView
//        self.parseClassName = String(describing: PFUser.object())
//        
//        self.pullToRefreshEnabled = false
//        self.paginationEnabled = false
//    }
    
    // Define the query that will provide the data for the table view
//    override func queryForTable() -> PFQuery<PFObject> {
//        let query = PFUser.query()
//        if searchBar.text != "" {
//            query!.whereKey("username", hasPrefix: searchBar.text!.lowercased())
//            query!.whereKey("username", notEqualTo: PFUser.current()!.username!)
//        }else{
//            query!.whereKey("username", equalTo: "")
//        }
//        query!.order(byAscending: "username")
//        return query!
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        searchBar.delegate = self
        //        search()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Refresh the table to ensure any data changes are displayed
        tableView.reloadData()
        
        // Delegate the search bar to this table view class
        searchBar.delegate = self
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsSearchTableviewCell
//        
//        let username = object!["username"] as! String
//        
//        cell.friendUsername.text = username
//        
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsSearchTableviewCell

        let username = self.usernames[indexPath.row] 

        cell.friendUsername.text = username

        return cell
    }
    
    func loadData () {
//        let query = PFUser.query()
        let query = LCQuery(className: "_User")
        if searchBar.text != "" {
            query.whereKey("username", .prefixedBy(searchBar.text!.lowercased()))
            query.whereKey("username", .notEqualTo(LCUser.current!.username!))
        }else{
            query.whereKey("username", .equalTo(""))
        }
        query.whereKey("username", .ascending)
        query.find { (result) in
            if result.isSuccess {
                // no error
                if let usernames = result.objects {
                    for oneID in usernames {
                            self.usernames.append((oneID["username"]?.stringValue)!)
                        }
                    }
                    self.tableView.reloadData()
            } else {
                //Error
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendsSearchTableviewCell
        
        let cell = self.tableView.cellForRow(at: indexPath) as! FriendsSearchTableviewCell
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OthersCollectionViewController") as! OthersCollectionViewController
        vc.userUsername = cell.friendUsername.text!
        
        print("username pass to othervc\(vc.userUsername)")
        
        self.navigationController!.pushViewController(vc, animated: true)
        
        
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // Clear any search criteria
        searchBar.text = ""
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadData()
    }

//    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        self.filteredUsernames = self.usernames.filter({( newUsername : String) -> Bool in
//            let categoryMatch = (scope == "All") || (newUsername == scope)
//            return categoryMatch && newUsername.lowercased().contains(searchText.lowercased())
//        })
//        
//        tableView.reloadData()
//    }
}

//extension FriendSearchTableViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
//}
