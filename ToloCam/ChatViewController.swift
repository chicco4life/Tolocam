
//  ChatViewController.swift
//  ToloCam
//
//  Created by Leo Li on 18/12/2016.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
//import Parse
//import ParseUI
//import Bolts
import AVOSCloud
import PubNub
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, PNObjectEventListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var count = 0

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var username = String()
    var currentChannel = String()
    var messagePackets = [JSQMessage]()
    var selfAvatarImg = UIImage()
    var friendAvatarImg = UIImage()
    var otherUser = AVUser()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.username
        appDelegate.client?.addListener(self)
        
        if AVUser.current()?["profileIm"] != nil{
            let file = AVUser.current()?["profileIm"] as? AVFile
            file?.getDataInBackground({ (data:Data?, error:Error?) in
                self.selfAvatarImg = UIImage(data: data!)!
            }, progressBlock: { (progress:Int) in
                //progress
            })
        }else{
            self.selfAvatarImg = UIImage(named: "gray")!
        }
        
        if self.otherUser["profileIm"] != nil{
            let file = self.otherUser["profileIm"] as? AVFile
            file?.getDataInBackground({ (data:Data?, error:Error?) in
                self.friendAvatarImg = UIImage(data: data!)!
            }, progressBlock: { (progress:Int) in
                //progress
            })
        }else{
            self.friendAvatarImg = UIImage(named: "gray")!
        }
        
        
        self.senderId = AVUser.current()?.objectId
        self.senderDisplayName = AVUser.current()?.username
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
//        print("received message")
//        print(message)
//        print(message.data.channel) //channel
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
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messagePackets.append(message)
            collectionView.reloadData()
            self.finishReceivingMessage(animated: true)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("send")
        let messageArray = [senderId,senderDisplayName,text,"notImg"]
        appDelegate.client?.publish(messageArray, toChannel: self.currentChannel, withCompletion: nil)
        self.finishSendingMessage(animated: true)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print(collectionView!.collectionViewLayout.incomingAvatarViewSize.width)
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
        let currentMessage = messagePackets[indexPath.item]
        let placeholderImg = UIImage(named: "gray")
        let avatarImg = JSQMessagesAvatarImage.init(avatarImage: nil, highlightedImage: nil, placeholderImage: placeholderImg)
        if currentMessage.senderId == AVUser.current()?.objectId{
//            avatarImg = JSQMessagesAvatarImage.init(avatarImage: self.selfAvatarImg, highlightedImage: self.selfAvatarImg, placeholderImage: placeholderImg)
            avatarImg?.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(self.selfAvatarImg, withDiameter:UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            avatarImg?.avatarHighlightedImage = JSQMessagesAvatarImageFactory.circularAvatarImage(self.selfAvatarImg, withDiameter:UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }else{
//            avatarImg = JSQMessagesAvatarImage.init(avatarImage: self.friendAvatarImg, highlightedImage: self.friendAvatarImg, placeholderImage: placeholderImg)
            avatarImg?.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(self.friendAvatarImg, withDiameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            avatarImg?.avatarHighlightedImage = JSQMessagesAvatarImageFactory.circularAvatarImage(self.friendAvatarImg, withDiameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
        
        return avatarImg
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
