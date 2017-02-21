//
//  PostTableViewController.swift
//  ToloCam
//
//  Created by Federico Li on 2/11/16.
//  Copyright © 2016 Federico Li. All rights reserved.
//
//images[0] = first post's image
//imageCaptions[0] = first post's caption
//imageDates[0] = first post's date
//imageUsers[0] = first post's addedBy

import UIKit
//import Parse
//import Bolts
//import ParseUI
import AVOSCloud

class PostTableViewController: UITableViewController {
    
    var followingWho = [String]()
    var imageFiles = [AVFile]()
    var imageCaptions = [String]()
    var imageDates = [String]()
    var imageUsers = [String]()
    var imageLikes = [Int]()
    var imageDictionaryOfLikers = [NSMutableDictionary]()
    var postObjects = [AVObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(AVUser.current())
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostTableViewController.__refreshPulled), name: NSNotification.Name(rawValue: "PostVCRefresh"), object: nil)
        
        print("viewdidload is called")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(PostTableViewController.__refreshPulled), for: UIControlEvents.valueChanged)
        self.refreshControl!.isUserInteractionEnabled = true
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        //query
        
        __loadData()
        
        self.tableView.reloadData()
    }

    func __refreshPulled() {
        self.__loadData()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func __loadData(){
        self.imageFiles = []
        self.imageCaptions = []
        self.imageDates = []
        self.imageUsers = []
        self.imageLikes = []
        self.imageDictionaryOfLikers = []
        self.postObjects = []
        let userQuery = AVQuery(className: "Follow")
        userQuery.whereKey("followFrom", equalTo: AVUser.current()!)
        let query = AVQuery(className: "Posts")
        query.whereKey("postedBy", matchesKey: "followingTo", in: userQuery)
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground{(results, error: Error?) -> Void in
            if (error == nil) {
                if let posts = results as! [AVObject]! {
                    for post in posts {
                        if  post["Image"] == nil{
                        }else{
                            let imageToLoad = post["Image"]! as! AVFile
                            self.imageFiles.append(imageToLoad)
                            self.imageCaptions.append(post["Caption"] as! String)
                            self.imageDates.append(post["date"] as! String)
                            self.imageUsers.append(post["addedBy"] as! String)
                            self.imageLikes.append(post["Likes"] as! Int)
                            self.imageDictionaryOfLikers.append(post["likedBy"] as! NSMutableDictionary)
                            self.postObjects.append(post)
                        }
                    }
                    self.tableView.reloadData()
                }
            } else {
                if error!.localizedDescription == "The Internet connection appears to be offline."{
                    let alertController = UIAlertController(title:"Error", message:"The Internet connection appears to be offline. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageFiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        let imageFile = self.imageFiles[indexPath.row]
        imageFile.getDataInBackground({ (data:Data?, error:Error?) in
            if error == nil{
                cell.postImageView.image = UIImage(data: data!)!
            }else{
                print(error!)
            }
        }) { (progress) in
            //progress
        }
        
        let imageCaption = imageCaptions[indexPath.row]
        let imageDate =  imageDates[indexPath.row]
        let imageUser = imageUsers[indexPath.row]
        let imageLikes = self.imageLikes[indexPath.row]
        let dictionaryOfLikers:NSMutableDictionary = self.imageDictionaryOfLikers[indexPath.row] 
        let yourLikes = dictionaryOfLikers[(AVUser.current()!.username)!] as? Int
        
        cell.object = self.postObjects[indexPath.row]
        //        print(object)
        
        cell.postCaption.text = imageCaption
        cell.addedBy.setTitle(imageUser, for: .normal)
        cell.dateLabel.text = imageDate
        cell.likesLabel.text = "\(imageLikes)"
        if yourLikes == nil{
            cell.yourLikesLabel.text = "0"
        }else{
            cell.yourLikesLabel.text = "\(yourLikes!)"
        }
        
        cell.addedBy.tag = indexPath.row
        cell.addedBy.addTarget(self, action: #selector(self.cellUsernameTapped), for: .touchUpInside)
        
        return cell
    }
    
    func cellUsernameTapped(sender:UIButton){
        let cellRow = sender.tag
        let path = IndexPath(row: cellRow, section: 0)
        let cell = tableView.cellForRow(at: path) as! PostTableViewCell
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OthersCollectionViewController") as! OthersCollectionViewController
        vc.userUsername = (cell.addedBy.titleLabel?.text)!
        
        print("username pass to othervc\(vc.userUsername)")
        if cell.addedBy.titleLabel?.text != AVUser.current()?.username{
            self.navigationController!.pushViewController(vc, animated: true)
        }else{
            //user tapped on own username
        }
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
