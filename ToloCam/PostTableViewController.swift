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
    
    var images = [UIImage]()
    var imageCaptions = [String]()
    var imageDates = [String]()
    var imageUsers = [String]()
    var imageLikes = [Int]()
    
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
        let query = PFQuery(className: "Posts")
        query.orderByDescending("date")
        return query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print("viewdidload is called")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(PostTableViewController.refreshPulled), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl!.userInteractionEnabled = true
        
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        userQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // no error
                if let objects = objects {
                    for object in objects {
                        let followingWho = object["followingWho"] as! NSArray
                        self.loadData(followingWho)
                    }
                    
                }
                
                
            }else {
                //error
                NSLog("Error")
                
            }
            
            
        })
        
        
        //Now only loading followingWho, hence loadData is commented out
        //loadData()
        self.tableView.reloadData()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func refreshPulled() {
        
        print("refresh method pulled")
        
        //loadData() Commented out since loading followingWho only
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        userQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // no error
                if let objects = objects {
                    for object in objects {
                        let followingWho = object["followingWho"] as! NSArray
                        self.loadData(followingWho)
                    }
                    
                }
                
                
            }else {
                //error
                NSLog("Error")
                
            }
            
            
        })
        
        self.tableView.reloadData()
        
        refreshControl?.endRefreshing()
        
    }
    
    func loadData (followingWho: NSArray) {
        
        let query = PFQuery(className: "Posts")
        query.whereKey("addedBy", containedIn: followingWho as [AnyObject])
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (posts: [PFObject]?, error: NSError?) -> Void in
            
            if (error == nil) {
                // no error
                
                if let posts = posts as [PFObject]! {
                    for post in posts {
                        
                        //print("------1\(post["Image"])-----")
                        //print("------2\(posts.count)-----")
                        
                        
                        if  post["Image"] == nil{
                            print("    CHECK THIS LOL NIL )")
                        }else{
                            
                            
                            print("    CHECK THIS LOL \(post["Image"])")
                            
                            let imageToLoad = post["Image"]! as! PFFile
                            
                            var imageIWillUse = UIImage()
                            
                            do {
                                try imageIWillUse = UIImage(data:imageToLoad.getData())!
                                
                            } catch {
                                
                                print(error)
                            }
                            
                            
                            
                            self.images.append(imageIWillUse)
                            self.imageCaptions.append(post["Caption"] as! String)
                            self.imageDates.append(post["date"] as! String)
                            self.imageUsers.append(post["addedBy"] as! String)
                            self.imageLikes.append(post["Likes"] as! Int)
                        }
                        
                        
                        
                    }
                    
                    self.tableView.reloadData()
                }
                
            } else {
                //Error
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (self.images.count == 0){
            return 0
        }else{
            return self.images.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        
        // Configure the cell...
        let imageToLoad = self.images[indexPath.row]
        let imageCaption = self.imageCaptions[indexPath.row] as String
        let imageDate = self.imageDates[indexPath.row] as String
        let imageUsers = self.imageUsers[indexPath.row] as String
        let imageLikes = self.imageLikes[indexPath.row] as Int
        
        cell.parseObject = object
        
        
        
        
        
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
        
        
        cell.postImageView.image = imageToLoad
        cell.postCaption.text = imageCaption
        cell.addedBy.text = imageUsers
        cell.dateLabel.text = imageDate
        cell.likesLabel.text = "Likes: \(imageLikes)"
        
        print("cell for row is called")
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
