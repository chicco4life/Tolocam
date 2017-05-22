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
    var nicknames = [String]()
    var profilePicFiles = [Any]()
    
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
        searchBar.backgroundImage =  #imageLiteral(resourceName: "#F9F9F9")
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(colorLiteralRed: 226/255, green: 226/255, blue: 226/255, alpha: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Refresh the table to ensure any data changes are displayed
        tableView.reloadData()
        
        // Delegate the search bar to this table view class
        searchBar.delegate = self
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsSearchTableviewCell

        cell.friendNickname.text = self.nicknames[indexPath.row]
        cell.cellUsername = self.usernames[indexPath.row]
        if profilePicFiles[indexPath.row] is UIImage {
            cell.friendPicture.image = #imageLiteral(resourceName: "gray")
        }else{
            (self.profilePicFiles[indexPath.row] as! AVFile).getDataInBackground { (data:Data?, error:Error?) in
                if error == nil{
                    cell.friendPicture.image = UIImage(data: data!)
                }else{
                    fatalError(error!.localizedDescription)
                }
            }
        }
        return cell
    }
    
    func loadData (){
        let query = AVQuery(className: "_User")
        let nicknameQuery = AVQuery(className: "_User")
        if searchBar.text != "" {
            query.whereKey("username", hasPrefix: searchBar.text!.lowercased())
            query.whereKey("username", notEqualTo: AVUser.current()!.username!)
            nicknameQuery.whereKey("nickname", hasPrefix: searchBar.text!.lowercased())
            nicknameQuery.whereKey("nickname", notEqualTo: AVUser.current()!.value(forKey: "nickname") as! String)
        }else{
            query.whereKey("username", equalTo: "")
            nicknameQuery.whereKey("nickname", equalTo: "")
        }
        query.order(byAscending: "username")
        nicknameQuery.order(byAscending: "nickname")
        
        let orQuery = AVQuery.orQuery(withSubqueries: [query, nicknameQuery])
        
        orQuery.findObjectsInBackground({ (results:[Any]?, error:Error?) in
            if error==nil{
                if let usernames = results as? [AVObject]{
                    for oneID in usernames{
                        self.nicknames.append(oneID["nickname"] as! String)
                        self.usernames.append(oneID["username"] as! String)
                        if oneID["profileIm"] == nil{
                            self.profilePicFiles.append(#imageLiteral(resourceName: "gray"))
                        }else{
                            self.profilePicFiles.append(oneID["profileIm"] as! AVFile)
                        }
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let view = UIImageView(image: #imageLiteral(resourceName: "searchEmpty"))
        view.frame = CGRect(x: 57, y: 76, width: 301, height: 73)
        self.tableView.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.tableView.backgroundView?.addSubview(view)
        if tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section) == 0{
            self.tableView.backgroundView?.isHidden = false
            return nil
        }else{
            self.tableView.backgroundView?.isHidden = true
            return "用户"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usernames.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! FriendsSearchTableviewCell
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OthersCollectionViewController") as! OthersCollectionViewController
        vc.userUsername = cell.cellUsername
        
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
}
