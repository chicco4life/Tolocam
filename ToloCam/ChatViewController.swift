//
//  ChatViewController.swift
//  ToloCam
//
//  Created by Leo Li on 18/12/2016.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Bolts
import PubNub
import JSQMessagesViewController

class ChatViewController: UIViewController, PNObjectEventListener, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var username = String()
    var messages = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.username
        appDelegate.client?.addListener(self)
        
        table.delegate = self
        table.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print(message.data.channel) //channel
        var messageArray = message.data.message as! Array<Any>
        let sender = messageArray[0]
        let theMessage = messageArray[1]
        if message.data.channel == self.username{
            messages.append("\(sender): \(theMessage)")
            self.table.reloadData()
        }
    }
    
    @IBAction func send(_ sender: Any) {
        appDelegate.client?.publish([PFUser.current()?.objectId, self.textField.text], toChannel: self.username, compressed: false, withCompletion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")! as UITableViewCell
        cell.textLabel?.text = self.messages[indexPath.row]
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
