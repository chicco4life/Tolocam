
//  ChatViewController.swift
//  ToloCam
//
//  Created by Leo Li on 18/12/2016.
//  Copyright © 2016 Federico Li. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVIMClientDelegate{
    
    var count = 0

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var client = AVIMClient(clientId: (AVUser.current()?.objectId)!)
    var conversation = AVIMConversation()
    var username = String()
    var otherUser = AVUser()
    var currentChannel = String()
    var messagePackets = [JSQMessage]()
    var selfAvatarImg = UIImage()
    var friendAvatarImg = UIImage()
    let refreshControl = UIRefreshControl()
    var firstMessageTimeStamp = NSNumber()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "PingFangSC-Medium", size: 20)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.title = otherUser.username
        
        //infinite scrolling
        self.collectionView?.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(ChatViewController.__loadEarlierMessages), for: UIControlEvents.valueChanged)
        self.refreshControl.isUserInteractionEnabled = true
        self.collectionView?.alwaysBounceVertical = true
        
        self.client.delegate = self
        self.client.open { (done:Bool, error:Error?) in
            let query = self.client.conversationQuery()
            query.whereKey("m", containsAllObjectsIn: [self.otherUser.objectId!, AVUser.current()!.objectId!])
            query.findConversations(callback: { (results:[Any]?, error:Error?) in
                if results?.count != 0{
                    self.conversation = results?[0] as! AVIMConversation
                    self.conversation.queryMessages(withLimit: 20, callback: { (results:[Any]?, error:Error?) in
                        if error==nil{
                            let messages = results as! [AVIMMessage]
                            for message in messages{
                                if message.clientId == self.otherUser.objectId{
                                    self.addMessage(withId: self.otherUser.objectId!, name: self.otherUser.username!, text: (message as! AVIMTypedMessage).text!)
                                }else{
                                    self.addMessage(withId: AVUser.current()!.objectId!, name: AVUser.current()!.username!, text: (message as! AVIMTypedMessage).text!)
                                }
                            }
                        }
                    })
                }else{
                    self.client.createConversation(withName: self.otherUser.objectId!, clientIds: [self.otherUser.objectId!], callback: { (conversation:AVIMConversation?, error:Error?) in
                        self.conversation = conversation!
                    })
                }
            })
        }
        
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
        
        //custom back button
//        self.navigationItem.hidesBackButton = true
//        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatViewController.back(sender:)))
//        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
//    func back(sender: UIBarButtonItem) {
//        self.conversation
//        _ = navigationController?.popViewController(animated: true)
//    }
    
    func __sendMessage(message:String){
        self.conversation.send(AVIMTextMessage.init(text: message, attributes: nil), callback: { (sent:Bool, error:Error?) in
            if !sent{
                print(error!.localizedDescription)
            }else{
                self.addMessage(withId: (AVUser.current()?.objectId)!, name: (AVUser.current()?.username!)!, text: message)
            }
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func conversation(_ conversation: AVIMConversation, didReceiveCommonMessage message: AVIMMessage) {
        let text = message as! AVIMTypedMessage
        addMessage(withId: self.otherUser.objectId!, name: self.otherUser.username!, text: text.text!)
    }
    
    /*
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
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
    }*/
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messagePackets.append(message)
            collectionView.reloadData()
            self.finishReceivingMessage(animated: true)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("send")
//        let messageArray = [senderId,senderDisplayName,text,"notImg"]
//        appDelegate.client?.publish(messageArray, toChannel: self.currentChannel, withCompletion: nil)
        __sendMessage(message: text)
        self.finishSendingMessage(animated: true)
        
        var chattingWithArray = manager.chattingWith
        if chattingWithArray?.contains(self.otherUser.username!) == false {
            chattingWithArray?.append(self.otherUser.username!)
            manager.chattingWith = chattingWithArray
            UserDefaults.standard.set(chattingWithArray, forKey: "chattingWithArray")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ChatVCRefresh"), object: nil)
        }
        
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
    
    func __loadEarlierMessages(){
        //load earlier messages
        
        /*self.appDelegate.client?.historyForChannel(currentChannel, start: self.firstMessageTimeStamp, end: nil, limit: 20, withCompletion: { (result:PNHistoryResult?, error:PNErrorStatus?) in
            if error == nil{
                if result?.data.messages.isEmpty == false{
                    
                    self.firstMessageTimeStamp = result!.data.start
                    
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    
                    let arrayOfMessageArrays = result?.data.messages as! [[Any]]

                    let oldBottomOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
                    
                    //-------------- load older messages
                    
                    self.collectionView.performBatchUpdates({
                        // indexPaths for earlier messages
                        let lastIdx = arrayOfMessageArrays.count - 1
                        var indexPaths: [AnyObject] = []
                        for i in 0...lastIdx {
                            indexPaths.append(IndexPath(item: i, section: 0) as AnyObject)
                        }
                        
                        //Convert the messages
                        var messages = [JSQMessage]()
                        for oneMessage in arrayOfMessageArrays {
                            let senderObjID = oneMessage[0] as! String
                            let senderName = oneMessage[1] as! String
                            let theMessage = oneMessage[2] as! String
                            messages.append(JSQMessage(senderId: senderObjID, displayName: senderName, text: theMessage))
                        }
                        
                        // insert messages and update data source.
                        var row = 0
                        for message in messages {
                            self.messagePackets.insert(message, at: row)
                            row+=1
                        }
                        self.collectionView.insertItems(at: indexPaths as! [IndexPath])
                        
                        // invalidate layout
                        self.collectionView.collectionViewLayout.invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext())
                        
                    }, completion: {(finished) in
                        
                        //scroll back to current position
                        self.finishReceivingMessage(animated: false)
                        self.collectionView.layoutIfNeeded()
                        self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentSize.height - oldBottomOffset)
                        CATransaction.commit()
                        
//                        self.collectionView.collectionViewLayout.springinessEnabled = true
                    })
                    
                    
                    //---------------------------end loading
                }
            }else{
                print("error!!!!!!::::",error.debugDescription)
                
            }
        })*/
        
        self.collectionView.reloadData()
        self.refreshControl.endRefreshing()
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
