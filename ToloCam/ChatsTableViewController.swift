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
}

class ChatsTableViewController: UITableViewController {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

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
        
        if manager.chattingWith == nil{
            manager.chattingWith = []
        }
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

        // Configure the cell...
        cell.username.text = manager.chattingWith?[indexPath.row]

        return cell
    }
    
    func __refresh(){
        self.tableView?.reloadData()
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
        let ID = manager.chattingWith?[indexPath.row]
        vc.username = ID!
        
        let userQuery = AVQuery(className: "_User")
        userQuery.whereKey("username", equalTo: ID!)
        userQuery.getFirstObjectInBackground { (result:AVObject?, error:Error?) in
            if error == nil{
                let selectedCellUser = result as! AVUser
                
                vc.otherUser = selectedCellUser
                
                //using object IDs to create a channel name
                var array = [String]()
                array.append(selectedCellUser.objectId!)
                array.append((AVUser.current()?.objectId)!)
                array.sort()
                
                let channelName = "\(array[0])-\(array[1])-channel"
                print(channelName)
                vc.currentChannel = channelName
                
//                self.appDelegate.client?.subscribeToChannels([channelName], withPresence: true)
                self.navigationController!.pushViewController(vc, animated: true)
            }else{
                print(error.debugDescription)
            }
        }
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
