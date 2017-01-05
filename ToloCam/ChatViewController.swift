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

class ChatViewController: JSQMessagesViewController, PNObjectEventListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var textField: UITextField!

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var username = String()
    var currentChannel = String()
    var messages = [String]()
    var messagePackets = [JSQMessage]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.username
        appDelegate.client?.addListener(self)
        
        //no avatar for now, setup later
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.senderId = PFUser.current()?.objectId
        self.senderDisplayName = PFUser.current()?.username
        self.automaticallyScrollsToMostRecentMessage = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("received message")
        print(message)
        print(message.data.channel) //channel
        var messageArray = message.data.message as! Array<Any>
        if  messageArray[3] as! String == "img"{
            let data = NSData(base64Encoded: messageArray[2] as! String, options: .ignoreUnknownCharacters)
            var image = UIImage(data: data as! Data)
            //display image
        }else{
            let senderObjID = messageArray[0] as! String
            let senderName = messageArray[1] as! String
            let theMessage = messageArray[2] as! String
            if message.data.channel == self.currentChannel{
                addMessage(withId: senderObjID , name: senderName , text: theMessage)
                print("is a message for this channel")
                }
        }
    }
    
    @IBAction func send(_ sender: Any) {
        appDelegate.client?.publish([PFUser.current()?.objectId, self.textField.text], toChannel: self.username, compressed: false, withCompletion: nil)
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messagePackets.append(message)
            collectionView.reloadData()
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("send")
        self.inputToolbar.contentView.textView.text = ""
        let messageArray = [senderId,senderDisplayName,text,"notImg"]
        appDelegate.client?.publish(messageArray, toChannel: self.currentChannel, withCompletion: nil)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.allowsEditing = false
        
//        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageToSendString:String = UIImageJPEGRepresentation(image, 0.0)!.base64EncodedString()
            let messageArray = [senderId,senderDisplayName,imageToSendString,"img"] as [Any]
            
//            save image to parse then send image link?
//            appDelegate.client?.publish(messageArray, toChannel: self.currentChannel, withCompletion: nil)
        } else{
            print("Something went wrong")
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messagePackets[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagePackets.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messagePackets[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    //setup avatar later, nil for now
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 1))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(red: 93/255, green: 215/255, blue: 217/255, alpha: 1))
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
