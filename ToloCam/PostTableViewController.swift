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


class PostTableViewController: UITableViewController {
    
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
        
        self.isLoading = true
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery<PFObject> {
        /*
         make user query
         query for all users that are followed by you -> [PFUser]
         query.whereKey("postedBy", matchesQuery: userQuery)
 */
        let userQuery = PFQuery(className: "Follow")
        userQuery.whereKey("followFrom", equalTo: PFUser.current()!)
        print(PFUser.current()!.objectId!)
        let query = PFQuery(className: "Posts")
        query.whereKey("postedBy", matchesKey: "followingTo", in: userQuery)
        query.order(byDescending: "createdAt")
        print(query)
        return query
    }
    
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
        
        //Now only loading followingWho, hence loadData is commented out
        //loadData()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func refreshPulled() {
        self.loadObjects()
        self.refreshControl?.endRefreshing()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        
        // Configure the cell...

        
        let image: PFFile = object!["Image"] as! PFFile
        
        let imageCaption = object!["Caption"] as! String
        let imageDate =  object!["date"] as! String
        let imageUsers = object!["addedBy"] as! String
        let imageLikes = object!["Likes"] as! Int
        let dictionaryOfLikers:NSMutableDictionary = object!["likedBy"] as! NSMutableDictionary
        let yourLikes = dictionaryOfLikers[(PFUser.current()?.username)!] as? Int
        
        cell.parseObject = object
//        print(object)
        
        cell.postImageView.image = UIImage(named: "gray")
        cell.postImageView.file = image
        cell.postImageView.loadInBackground()
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
