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
import LeanCloud
import AVOSCloud

class PostTableViewController: UITableViewController {
    
    var followingWho = [String]()
    var imageFiles = [AVFile]()
    var imageCaptions = [String]()
    var imageDates = [String]()
    var imageUsers = [String]()
    var imageLikes = [Int]()
    var imageDictionaryOfLikers = [NSMutableDictionary]()
    var postObjects = [LCObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostTableViewController.refreshPulled), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        print("viewdidload is called")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(PostTableViewController.refreshPulled), for: UIControlEvents.valueChanged)
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

    func refreshPulled() {
//        self.loadObjects()
        self.__loadData()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func __loadData () {
        let userQuery = LCQuery(className: "Follow")
        userQuery.whereKey("followFrom", .equalTo(LCUser.current!))
        let query = LCQuery(className: "Posts")
        //            query.whereKey("postedBy", matchesKey: "followingTo", in: userQuery)
        query.whereKey("postedBy", .matchedQueryAndKey(query: userQuery, key: "followingTo"))
        query.whereKey("createdAt", .descending)
        query.find { (result) in
            if result.isSuccess {
                // no error
                if let posts = result.objects {
                    for post in posts {
                        if  post["Image"] == nil{
                            print("    CHECK THIS LOL NIL )")
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
                //Error
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        let imageFile = self.imageFiles[indexPath.row]
        var image = UIImage()
        imageFile.getDataInBackground({ (data:Data?, error:Error?) in
            image = UIImage(data: data!)!
        }) { (progress) in
            //progress
        }
        
        let imageCaption = imageCaptions[indexPath.row]
        let imageDate =  imageDates[indexPath.row]
        let imageUser = imageUsers[indexPath.row]
        let imageLikes = self.imageLikes[indexPath.row]
        let dictionaryOfLikers:NSMutableDictionary = self.imageDictionaryOfLikers[indexPath.row] 
        let yourLikes = dictionaryOfLikers[(LCUser.current!.username)!] as? Int
        
        cell.object = self.postObjects[indexPath.row]
        //        print(object)
        
        cell.postImageView.image = image
        cell.postCaption.text = imageCaption
        cell.addedBy.text = imageUser
        cell.dateLabel.text = imageDate
        cell.likesLabel.text = "\(imageLikes)"
        if yourLikes == nil{
            cell.yourLikesLabel.text = "0"
        }else{
            cell.yourLikesLabel.text = "\(yourLikes!)"
        }
        return cell
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
