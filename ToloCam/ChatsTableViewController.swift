//
//  ChatsTableViewController.swift
//  
//
//  Created by Leo Li on 13/02/2017.
//
//

import UIKit
import AVOSCloud

struct manager {
    static var chattingWith = UserDefaults.standard.array(forKey: "chattingWithArray") as? [String]
    static var userAndUnreadMessagesCount = UserDefaults.standard.dictionary(forKey: "userAndUnreadMessagesCount") as! [String:Int]
}

class ChatsTableViewController: UITableViewController {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var tempUserObject = [AVUser]()

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
        
        self.tabBarController?.tabBar.backgroundImage = UIImage(named: "#FFFFFF")
        
        self.refreshControl?.addTarget(self, action: #selector(ChatsTableViewController.__refresh), for: UIControlEvents.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatsTableViewController.__refresh), name: NSNotification.Name(rawValue: "ChatVCRefresh"), object: nil)
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.backgroundImage = UIImage(named: "#FFFFFF")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if manager.chattingWith?.isEmpty == false{
            return manager.chattingWith!.count
        }else{
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsTableViewCell
        
        cell.userObjectId = manager.chattingWith![indexPath.row]
        
        let query = AVQuery(className: "_User")
        query.whereKey("objectId", equalTo: manager.chattingWith?[indexPath.row])
        query.getFirstObjectInBackground { (result, error) in
            if error == nil{
                let user = result as! AVUser
                self.tempUserObject.append(user)
                cell.username.text = user.value(forKey: "nickname") as! String
                if let image = user.value(forKey: "profileIm") as? AVFile{
                    image.getDataInBackground { (data, error) in
                        if error == nil{
                            cell.profileImageView.image = UIImage(data: data!)
                        }else{
                            print(error!.localizedDescription)
                        }
                    }
                }else{
                    cell.profileImageView.image = #imageLiteral(resourceName: "gray.png")
                }
                
                cell.unreadCountLabel.isHidden = false
                if manager.userAndUnreadMessagesCount[user.objectId!] != nil && manager.userAndUnreadMessagesCount[user.objectId!] != 0{
                    cell.unreadCountLabel.text = String(describing: manager.userAndUnreadMessagesCount[user.objectId!]!)
                }else{
                    cell.unreadCountLabel.isHidden = true
                }
                
            }else{
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    func __refresh(){
        self.tableView?.reloadData()
        let tabItems = self.tabBarController!.tabBar.items!
        let tabItem = tabItems[3]
        let unreadMessages = Array(manager.userAndUnreadMessagesCount.values).reduce(0, +)
        tabItem.badgeValue = unreadMessages != 0 ? String(unreadMessages) : nil
        UIApplication.shared.applicationIconBadgeNumber = unreadMessages
        self.refreshControl?.endRefreshing()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            manager.chattingWith?.remove(at: indexPath.row)
            UserDefaults.standard.set(manager.chattingWith, forKey: "chattingWithArray")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }  
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        let userId = (self.tableView.cellForRow(at: indexPath) as! ChatsTableViewCell).userObjectId
        let ID = AVQuery.getObjectOfClass("_User", objectId: userId)?.value(forKey: "nickname") as! String
        vc.username = ID
        vc.otherUser = self.tempUserObject[indexPath.row]
        self.navigationController!.pushViewController(vc, animated: true)
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
