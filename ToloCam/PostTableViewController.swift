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
import AVOSCloud

class PostTableViewController: UITableViewController {
    
    var followingWho = [String]()
    var imageFiles = [AVFile]()
    var imageCaptions = [String]()
    var imageDates = [String]()
    var imageUsers = [String]()
    var imageLikes = [Int]()
    var imageDictionaryOfLikers = [NSMutableDictionary]()
    var imageProfilePics = [AVFile]()
    var imageHasLikers = [Bool]()
    var postTags = [[String]]()
    var postObjects = [AVObject]()
    let thatsAll = UIImageView(image: #imageLiteral(resourceName: "thatsAll"))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 1))
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostTableViewController.__refreshPulled), name: NSNotification.Name(rawValue: "PostVCRefresh"), object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "refreshing", attributes: nil)
        self.refreshControl!.addTarget(self, action: #selector(PostTableViewController.__refreshPulled), for: UIControlEvents.valueChanged)
        self.refreshControl!.isUserInteractionEnabled = true
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "PingFangSC-Medium", size: 20)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        __loadData()
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.backgroundImage = UIImage(named: "#FFFFFF")
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
        self.imageProfilePics = []
        self.imageHasLikers = []
        
        let userQuery = AVQuery(className: "Follow")
        userQuery.whereKey("followFrom", equalTo: AVUser.current()!)
        let query = AVQuery(className: "Posts")
        query.whereKey("postedBy", matchesKey: "followingTo", in: userQuery)
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground{(results, error: Error?) -> Void in
            if (error == nil) {
                if let posts = results as! [AVObject]! {
                    for post in posts {
                        if  post["Image"] != nil{
                            let imageToLoad = post["Image"]! as! AVFile
                            self.imageFiles.append(imageToLoad)
                            self.imageCaptions.append(post["Caption"] as! String)
                            self.imageDates.append(post["date"] as! String)
                            self.imageUsers.append(post["addedBy"] as! String)
                            self.imageLikes.append(post["Likes"] as! Int)
                            self.imageDictionaryOfLikers.append(post["likedBy"] as! NSMutableDictionary)
                            
                            if (post["likedBy"] as! NSMutableDictionary).count == 0{
                                self.imageHasLikers.append(false)
                            }else{
                                self.imageHasLikers.append(true)
                            }
                            
                            if post["tags"] != nil{
                                let tagArray = post["tags"] as! [String]
                                    self.postTags.append(tagArray)
                            }else{
                                self.postTags.append([])
                            }
                            
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
        
        if indexPath.row == 0 {
            self.thatsAll.removeFromSuperview()
            thatsAll.frame = CGRect(x: 0, y: self.tableView.contentSize.height+10, width: self.view.frame.width, height: self.view.frame.width*0.1208)
            self.view.insertSubview(thatsAll, belowSubview: tableView)
        }
        
        
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
        let thisPostObject = self.postObjects[indexPath.row]
        var profilePicFile = AVFile()
        let imageHasLiker = self.imageHasLikers[indexPath.row]
        let postTags = self.postTags[indexPath.row]
        
        let pointer = thisPostObject["postedBy"] as! AVObject
        let posterObjId = pointer["objectId"] as! String
        let userQuery = AVQuery(className: "_User")
        userQuery.whereKey("objectId", equalTo: posterObjId)
        userQuery.getFirstObjectInBackground { (user:AVObject?, error:Error?) in
            if error==nil{
                if user?["profileIm"] != nil{
                    let profilePicFile = user?["profileIm"] as! AVFile
                    profilePicFile.getDataInBackground { (data:Data?, error:Error?) in
                        if error==nil{
                            cell.profilePicImgView.image = UIImage(data:data!)
                        }else{
                            print(error.debugDescription)
                        }
                    }
                }else{
                        cell.profilePicImgView.image = #imageLiteral(resourceName: "gray.png")
                }
            }else{
                print(error.debugDescription)
            }
        }
        
        cell.object = self.postObjects[indexPath.row]
        

        
        cell.postCaption.text = imageCaption
        cell.postCaption.text = cell.postCaption.text!.components(separatedBy: CharacterSet.newlines).joined(separator: " ")
        cell.addedBy.setTitle(imageUser, for: .normal)
        cell.dateLabel.text = imageDate
        cell.likesLabel.text = "\(imageLikes)"
        
        if imageHasLiker{
            cell.crownImg.image = #imageLiteral(resourceName: "crown")
        }else{
            cell.crownImg.image = #imageLiteral(resourceName: "clearImg")
        }
        
        print("Row: ",indexPath.row)
        
        
        cell.addedBy.tag = indexPath.row
        cell.addedBy.addTarget(self, action: #selector(self.cellUsernameTapped), for: .touchUpInside)
        
        cell.postCaption.tag = indexPath.row
        let oneTap = UITapGestureRecognizer(target: self, action:#selector(PostTableViewController.tappedCaption))
        cell.postCaption.isUserInteractionEnabled = true
        cell.postCaption.addGestureRecognizer(oneTap)
        
        
        //-- -- - - - - - - - - -  fix tags issue!!!! - - - - - -- - - - - - - -- -
        if postTags.count != 0{
            for i in 0...postTags.count-1{
                cell.tagCollection[i].setTitle(postTags[i], for: .normal)
                cell.tagCollection[i].sizeToFit()
            }
        }
        
        if indexPath.row == self.postObjects.count-1{
            cell.separator.isHidden = true
        }

        cell.tagCollection[3].translatesAutoresizingMaskIntoConstraints = false
        cell.tagCollection[4].translatesAutoresizingMaskIntoConstraints = false
        
        var fourthTagIsOnFirstLine = false
        
        //if the fourth tag's width + the previous 3 tags' width is smaller than superview's width minus all spacing in between, don't put tag on second line
        if cell.tagCollection[0].frame.width+cell.tagCollection[1].frame.width+cell.tagCollection[2].frame.width+cell.tagCollection[3].frame.width < self.view.frame.width-84{
            let fourthTagLeading = NSLayoutConstraint(item: cell.tagCollection[3], attribute: .leading, relatedBy: .equal, toItem: cell.tagCollection[2], attribute: .trailing, multiplier: 1, constant: 18)
            cell.contentView.addConstraint(fourthTagLeading)
            let fourthTagTop = NSLayoutConstraint(item: cell.tagCollection[3], attribute: .top, relatedBy: .equal, toItem: cell.tagCollection[2], attribute: .top, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(fourthTagTop)
            
            fourthTagIsOnFirstLine = true
//            captionViewTop.constant = 13
        }else{
            //if the first 4 tags are longer than view.width, move to second line
            let fourthTagLeading = NSLayoutConstraint(item: cell.tagCollection[3], attribute: .leading, relatedBy: .equal, toItem: cell.tagCollection[0], attribute: .leading, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(fourthTagLeading)
            let fourthTagTop = NSLayoutConstraint(item: cell.tagCollection[3], attribute: .top, relatedBy: .equal, toItem: cell.tagCollection[2], attribute: .bottom, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(fourthTagTop)
            //set caption view's y position to 13pt below lowest tag
//            captionViewTop.constant = cell.tagCollection[0].frame.height+13
        }
        
        //if the fifth tag's width + the previous 4 tags' width is smaller than superview's width minus all spacing in between, don't put tag on second line
        if cell.tagCollection[0].frame.width+cell.tagCollection[1].frame.width+cell.tagCollection[2].frame.width+cell.tagCollection[3].frame.width+cell.tagCollection[4].frame.width < self.view.frame.width-102{
            
            print("tags width: ", cell.tagCollection[0].frame.width+cell.tagCollection[1].frame.width+cell.tagCollection[2].frame.width+cell.tagCollection[3].frame.width+cell.tagCollection[4].frame.width)
            
            print("frame width: ", self.view.frame.width)
            
            let fifthTagLeading = NSLayoutConstraint(item: cell.tagCollection[4], attribute: .leading, relatedBy: .equal, toItem: cell.tagCollection[3], attribute: .trailing, multiplier: 1, constant: 18)
            cell.contentView.addConstraint(fifthTagLeading)
            let fifthTagTop = NSLayoutConstraint(item: cell.tagCollection[4], attribute: .top, relatedBy: .equal, toItem: cell.tagCollection[3], attribute: .top, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(fifthTagTop)
        }else if fourthTagIsOnFirstLine == true{
            //if fourth tag is one first line, move fith to second line's first spot
            let fifthTagLeading = NSLayoutConstraint(item: cell.tagCollection[4], attribute: .leading, relatedBy: .equal, toItem: cell.tagCollection[0], attribute: .leading, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(fifthTagLeading)
            let fifthTagTop = NSLayoutConstraint(item: cell.tagCollection[4], attribute: .top, relatedBy: .equal, toItem: cell.tagCollection[2], attribute: .bottom, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(fifthTagTop)
        }else if fourthTagIsOnFirstLine == false{
            //if fourth tag is already on second line, move to behind fourth tag
            let fifthTagLeading = NSLayoutConstraint(item: cell.tagCollection[4], attribute: .leading, relatedBy: .equal, toItem: cell.tagCollection[3], attribute: .trailing, multiplier: 1, constant: 18)
            cell.contentView.addConstraint(fifthTagLeading)
            let fifthTagTop = NSLayoutConstraint(item: cell.tagCollection[4], attribute: .top, relatedBy: .equal, toItem: cell.tagCollection[3], attribute: .top, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(fifthTagTop)
        }
        
        if thisPostObject["tags"] == nil{

        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = postObjects[indexPath.row]
        
        //will not use buttons and label, just simulating what the height will be
        
        var buttons = [UIButton]()
        var tagNil = false
        if object["tags"] != nil{
            let tagArray = object["tags"] as! [String]
            for i in 0...tagArray.count-1{
                let button = UIButton()
                button.setTitle(tagArray[i], for: .normal)
                button.sizeToFit()
                buttons.append(button)
            }
            if buttons.count != 5{
                for _ in buttons.count...5{
                    let button = UIButton()
                    buttons.append(button)
                }
            }
        }else{
            tagNil = true
            for _ in 0...5{
                let button = UIButton()
                buttons.append(button)
            }
        }
        
        var label = UILabel()
        var labelNil = false
        if object["Caption"] != nil{
            let caption = object["Caption"] as! String
            let attributes = [
                NSFontAttributeName : UIFont(name: "PingFangSC-Light", size: 14)! // Note the !
            ]
            label.attributedText = NSAttributedString(string: caption, attributes: attributes)
            label.text = label.text?.components(separatedBy: CharacterSet.newlines).joined(separator: " ")
            label.numberOfLines = 2
            label.frame.size.width = self.view.frame.width-30
            label.lineBreakMode = .byWordWrapping
            label.frame.size.height = CGFloat(MAXFLOAT)
            label.sizeToFit()
        }else{
            labelNil = true
        }
        
        //if likedBy is not nil, add height of king of the likes profile image and crown
        if (object["likedBy"] as! NSMutableDictionary).count == 0{
            //no king of the likes
            if buttons[0].frame.width+buttons[1].frame.width+buttons[2].frame.width+buttons[3].frame.width < self.view.frame.width-84{
                //one line of tag
                if !tagNil{
                    if !labelNil{
                        //has tag has label
                        let height = self.view.frame.width+10+36+15+label.frame.height+13+buttons[0].frame.height+23+8
                        return height
                    }else{
                        //has tag no label
                        let height = self.view.frame.width+10+36+13+buttons[0].frame.height+23+8
                        return height
                    }
                }else{
                    if !labelNil{
                        //no tag has label
                        print("caption: ", object["Caption"] as! String)
                        print("label height: ", label.frame.height)
                        let height = self.view.frame.width+10+36+15+label.frame.height+23+8
                        return height
                    }else{
                        //no tag no label
                        let height = self.view.frame.width+10+36+23+8
                        return height
                    }
                }
            }else{
                //two lines of tags
                if !tagNil{
                    if !labelNil{
                        //has tag has label
                        let height = self.view.frame.width+10+36+15+label.frame.height+13+buttons[0].frame.height+23+8
                        return height+buttons[0].frame.height
                    }else{
                        //has tag no label
                        let height = self.view.frame.width+10+36+13+buttons[0].frame.height+23+8
                        return height+buttons[0].frame.height
                    }
                }else{
                    if !labelNil{
                        //no tag has label
                        let height = self.view.frame.width+10+36+15+label.frame.height+23+8
                        return height+buttons[0].frame.height
                    }else{
                        //no tag no label
                        let height = self.view.frame.width+10+36+23+8
                        return height+buttons[0].frame.height
                    }
                }
            }
            //has king of the likes
            if !tagNil{
                //one line of tags
                if !labelNil{
                    //has tag has label
                    let height = self.view.frame.width+10+36+15+label.frame.height+13+buttons[0].frame.height+23+8
                    return height
                }else{
                    //has tag no label
                    let height = self.view.frame.width+10+36+13+buttons[0].frame.height+23+8
                    return height
                }
            }else{
                if !labelNil{
                    //no tag has label
                    let height = self.view.frame.width+10+36+15+label.frame.height+23+8
                    return height+44
                }else{
                    //no tag no label
                    let height = self.view.frame.width+10+36+23+8
                    return height+44
                }
            }
        }else{
            //two lines of tags
            if !tagNil{
                if !labelNil{
                    //has tag has label
                    let height = self.view.frame.width+10+36+15+label.frame.height+13+buttons[0].frame.height+23+8
                    return height+buttons[0].frame.height
                }else{
                    //has tag no label
                    let height = self.view.frame.width+10+36+13+buttons[0].frame.height+23+8
                    return height+buttons[0].frame.height
                }
            }else{
                if !labelNil{
                    //no tag has label
                    let height = self.view.frame.width+10+36+15+label.frame.height+23+8
                    return height+buttons[0].frame.height+44
                }else{
                    //no tag no label
                    let height = self.view.frame.width+10+36+23+8
                    return height+buttons[0].frame.height+44
                }
            }
        }
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
            self.tabBarController?.selectedIndex = 4
        }
    }
    
    func tappedCaption(sender:UITapGestureRecognizer){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postDetailVC") as! PostDetailViewController
        let row = sender.view?.tag
        vc.postObject = self.postObjects[row!]
        self.navigationController?.pushViewController(vc, animated: true)
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
