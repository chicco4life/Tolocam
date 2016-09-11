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
import Parse
import Bolts
import ParseUI


class PostTableViewController: PFQueryTableViewController {
    
//    var images = [UIImage]()
//    var imageCaptions = [String]()
//    var imageDates = [String]()
//    var imageUsers = [String]()
//    var imageLikes = [Int]()
//    var yourLikes = [Int]()
    var followingWho = [String]()
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // Configure the PFQueryTableView
        self.parseClassName = "Posts"
        
        self.pullToRefreshEnabled = true
        
        self.paginationEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        /*
         make user query
         query for all users that are followed by you -> [PFUser]
         query.whereKey("postedBy", matchesQuery: userQuery)
 */
        let userQuery = PFQuery(className: "Follow")
        userQuery.whereKey("followFrom", equalTo: PFUser.currentUser()!)
        print(PFUser.currentUser()!.objectId!)
        let query = PFQuery(className: "Posts")
        query.whereKey("postedBy", matchesKey: "followingTo", inQuery: userQuery)
        query.orderByDescending("date")
        print(query)
        return query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPulled", name: "refresh", object: nil)
        
        print("viewdidload is called")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(PostTableViewController.refreshPulled), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl!.userInteractionEnabled = true
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
//        let userQuery = PFUser.query()
//        userQuery?.whereKey("username", equalTo: PFUser.currentUser()!.username!)
//        userQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                // no error
//                if let objects = objects {
//                    for object in objects {
//                        self.followingWho = object["followingWho"] as! [String]
//                        self.tableView.reloadData()
//                    }
//                }
//            }else {
//                //error
//                NSLog("Error")
//                
//            }
//        })
        
        
        //Now only loading followingWho, hence loadData is commented out
        //loadData()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func refreshPulled() {
        self.loadObjects()
//        self.tableView.performSelectorInBackground(#selector(self.loadObjects), withObject: nil)
//        self.performSelectorInBackground(#selector(self.loadObjects), withObject: nil)
        
        self.refreshControl?.endRefreshing()
        
    }
    
//    func loadData (followingWho: NSArray) {
//        
//        let query = PFQuery(className: "Posts")
//        query.whereKey("addedBy", containedIn: followingWho as [AnyObject])
//        query.orderByDescending("createdAt")
//        query.findObjectsInBackgroundWithBlock {
//            (posts: [PFObject]?, error: NSError?) -> Void in
//            
//            if (error == nil) {
//                // no error
//                
//                if let posts = posts as [PFObject]! {
//                    for post in posts {
//                        
//                        //print("------1\(post["Image"])-----")
//                        //print("------2\(posts.count)-----")
//                        
//                        
//                        if  post["Image"] == nil{
//                            print("    CHECK THIS LOL NIL )")
//                        }else{
//                            
//                            
//                            print("    CHECK THIS LOL \(post["Image"])")
//                            
//                            let imageToLoad = post["Image"]! as! PFFile
//                            
//                            var imageIWillUse = UIImage()
//                            
//                            do {
//                                try imageIWillUse = UIImage(data:imageToLoad.getData())!
//                                
//                            } catch {
//                                
//                                print(error)
//                            }
//                            
//                            
//                            
//                            self.images.append(imageIWillUse)
//                            self.imageCaptions.append(post["Caption"] as! String)
//                            self.imageDates.append(post["date"] as! String)
//                            self.imageUsers.append(post["addedBy"] as! String)
//                            self.imageLikes.append(post["Likes"] as! Int)
//                            
//                            let dictionaryOfLikers:NSMutableDictionary = (post.objectForKey("likedBy") as! NSMutableDictionary)
//                            print(dictionaryOfLikers)
//                            if var yourLikes = dictionaryOfLikers[PFUser.currentUser()!.username!] as? Int{
////                                print(PFUser.currentUser()?.username!)
////                                print (dictionaryOfLikers[PFUser.currentUser()!.username!] as? String)
//                                print(yourLikes)
//                                self.yourLikes.append(yourLikes)
//                            }else{
//                                print(0)
//                                self.yourLikes.append(0)
//                            }
//                        }
//                        
//                        
//                        
//                    }
//                    
//                    self.tableView.reloadData()
//                }
//                
//            } else {
//                //Error
//                
//            }
//            
//        }
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        
        // Configure the cell...
        let imageWillUse = object!["Image"] as! PFFile
        var imageToLoad = UIImage()
        do {
            try imageToLoad = UIImage(data:imageWillUse.getData())!
            
        } catch {
            
            print(error)
        }
        let imageCaption = object!["Caption"] as! String
        let imageDate =  object!["date"] as! String
        let imageUsers = object!["addedBy"] as! String
        let imageLikes = object!["Likes"] as! Int
        let dictionaryOfLikers:NSMutableDictionary = object!["likedBy"] as! NSMutableDictionary
        let yourLikes = dictionaryOfLikers[(PFUser.currentUser()?.username)!] as? Int
        
        cell.parseObject = object
        
        cell.postImageView.image = imageToLoad
        cell.postCaption.text = imageCaption
        cell.addedBy.text = imageUsers
        cell.dateLabel.text = imageDate
        cell.likesLabel.text = "\(imageLikes)"
        if yourLikes == nil{
            cell.yourLikesLabel.text = "0"
        }else{
        cell.yourLikesLabel.text = "\(yourLikes!)"
        }
        
        print("cell for row is called")

        //Create the object you want to get the data from. It will have to be a variable because you might recieve the image from the server or you might not.
        
        //Start your error catching by using this format do { try *func* } catch { *error handling* }
        
        //var imageData = NSData()
        
        //do
        //    {
        //    imageData = try imageToLoad.getData()
        //    }
        //    catch
        //    {
        //        print("Error: \(error)")
        //Handle the error instead of print probably
        //    }
        //let finalizedImage = UIImage(data:imageData)
        
        
        //once finished autolayout, change cell to cellCoded
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
