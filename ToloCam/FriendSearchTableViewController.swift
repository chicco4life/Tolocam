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

class FriendSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var friendTableView: UITableView!
    
    var searchActive = false
    var data:[AVObject]!
    var filtered:[AVObject]!
    
    @IBOutlet var searchBar: UISearchBar!
    
    var usernames = [String]()
    var filteredUsernames = [String]()
    var username = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stops generating separators
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "PingFangSC-Medium", size: 20)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
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
        let query = AVQuery(className: "_User")
        //let query = AVUser.query()
        if searchBar.text != "" {
            query.whereKey("username", hasPrefix: searchBar.text!.lowercased())
            query.whereKey("username", notEqualTo: AVUser.current()!.username!)
        }else{
            query.whereKey("username", equalTo: "")
        }
        query.order(byAscending: "username")
        
        query.findObjectsInBackground({ (results:[Any]?, error:Error?) in
            if error==nil{
                if let usernames = results as? [AVObject]{
                    for oneID in usernames{
                        self.usernames.append(oneID["username"] as! String)
                    }
                }else{
                    print("no results!!!!")
                }
                self.tableView.reloadData()
            }else{
                if error!.localizedDescription == "The Internet connection appears to be offline."{
                    let alertController = UIAlertController(title:"Error", message:"The Internet connection appears to be offline. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usernames.count
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
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.usernames = []
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.usernames = []
        
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
