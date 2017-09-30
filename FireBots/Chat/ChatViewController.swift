//
//  ChatViewController.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 11/14/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage
import Photos
import ImageViewer
import AssetsLibrary

class ChatViewController: JSQMessagesViewController {
    
    // Properties JSQMessagesViewController
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    fileprivate var displayName: String!
    
    // Properties Firebase
    var chatroomRef: DatabaseReference!
    var messageRef: DatabaseReference!
    var messageQuery: DatabaseQuery!
    var newMessageRefHandle: DatabaseHandle?
    var userIsTypingRef: DatabaseReference!
    var userIsTypingRefHandle: DatabaseHandle?
    var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    var usersTypingQuery: DatabaseQuery!
    
    // Properties Normal
    let defaults = UserDefaults.standard
    var sender: User!
    var messages: [Message] = []
    var messageKeys: [String] = []
    var members: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare JSQ data
        senderId = sender.uid
        senderDisplayName = sender.username
        
        // Prepare Firebase data
        chatroomRef = FBChatroom.getChatroomRef()
        messageRef = chatroomRef.child(FBConstant.Chatroom.message)
        messageQuery = messageRef.queryOrdered(byChild: FBConstant.Message.sendingTime).queryLimited(toLast:5000)
        userIsTypingRef = chatroomRef.child(FBConstant.Chatroom.typingIndicator).child(senderId)
        usersTypingQuery = chatroomRef.child(FBConstant.Chatroom.typingIndicator).queryOrderedByValue().queryEqual(toValue: true)
        
        // MARK: Setup navigation
        // Setup navigation title and font
        title = sender.username
        
        // MARK: Override point
        // Setup background color
        collectionView?.backgroundColor = Style.Color.background
        
        // Setup message bubble style and color
        incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: Style.Color.blue)
        outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: Style.Color.white)
        
        // Setup avatar size
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        // Setup input toolbar
        inputToolbar.contentView.textView.placeHolder = NSLocalizedString("Write a comment...", comment: "")
        inputToolbar.contentView.textView.tintColor = Style.Color.blue
        inputToolbar.contentView.rightBarButtonItem.setTitleColor(.white, for: .normal)
        
        inputToolbar.contentView.leftBarButtonItem = nil
        
        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        autoHideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = userIsTypingRefHandle {
            usersTypingQuery.removeObserver(withHandle: refHandle)
        }
    }
    
    private func observeMessages() {
        if messages.count == 0 {
            messageQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.childrenCount > 0 {
                    let lastFirstObserveChild = Int(snapshot.childrenCount)
                    var currentChild = lastFirstObserveChild
                    for messageSnapshot in snapshot.children.reversed() {
                        currentChild -= 1
                        if let messageSnapshot = messageSnapshot as? DataSnapshot, let messageData = messageSnapshot.value as? [String: AnyObject] {
                            if let senderID = messageData[FBConstant.Message.senderID] as? String, let senderName = messageData[FBConstant.Message.senderName] as? String, let sendingTime = messageData[FBConstant.Message.sendingTime] as? String {
                                if let text = messageData[FBConstant.Message.text] as? String, text.characters.count > 0 {
                                    self.messages.insert(Message(id: messageSnapshot.key, senderID: senderID, displayName: senderName, text: text, sendingTime: Date(iso8601: sendingTime) ?? Date()), at: 0)
                                    self.messageKeys.append(messageSnapshot.key)
                                    if currentChild == 0 {
                                        self.finishReceivingMessage()
                                        self.dismissIndicator(view: self.mainViewController.view)
                                        self.observeNewMessage()
                                    }
                                }
                            }
                            else {
                                if currentChild == 0 {
                                    self.finishReceivingMessage()
                                    self.collectionView.isHidden = false
                                    self.dismissIndicator(view: self.mainViewController.view)
                                    self.observeNewMessage()
                                }
                                print("Error! Could not decode message data")
                            }
                        }
                        else if currentChild == 0 {
                            self.finishReceivingMessage()
                            self.collectionView.isHidden = false
                            self.dismissIndicator(view: self.mainViewController.view)
                            self.observeNewMessage()
                        }
                    }
                }
                else {
                    self.finishReceivingMessage()
                    self.collectionView.isHidden = false
                    self.dismissIndicator(view: self.mainViewController.view)
                    self.observeNewMessage()
                }
            })
        }
        else {
            observeNewMessage()
        }
    }
    
    private func observeNewMessage() {
        newMessageRefHandle = messageRef.observe(.childAdded, with: { (snapshot) in
            if !self.messageKeys.contains(snapshot.key) {
                if let messageData = snapshot.value as? [String: AnyObject] {
                    if let senderID = messageData[FBConstant.Message.senderID] as? String, let senderName = messageData[FBConstant.Message.senderName] as? String, let sendingTime = messageData[FBConstant.Message.sendingTime] as? String {
                        if let text = messageData[FBConstant.Message.text] as? String, text.characters.count > 0 {
                            self.messages.append(Message(id: snapshot.key, senderID: senderID, displayName: senderName, text: text, sendingTime: Date(iso8601: sendingTime) ?? Date()))
                            self.messageKeys.append(snapshot.key)
                            self.finishReceivingMessage()
                        }
                    }
                }
            }
        })
    }
    
    private func observeTyping() {
        userIsTypingRef.onDisconnectRemoveValue()
        
        userIsTypingRefHandle = usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    // MARK: JSQMessagesViewController method overrides
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            FBConstant.Message.senderID: senderId,
            FBConstant.Message.senderName: senderDisplayName,
            FBConstant.Message.sendingTime: Date().iso8601DateString,
            FBConstant.Message.text: text,
            ] as [String : Any]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    // function copy message
    func copyMessage(message: Message) {
        UIPasteboard.general.string = message.text
    }
    
}

//
// MARK: CollectionView
//
extension ChatViewController {
    
    //MARK: JSQMessages CollectionView DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // MARK - Setting cellTopLabel
    // cellTopLabel height
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        return 0.0
    }
    
    // cellTopLabel text
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        return nil
    }
    
    // MARK - Setting avatar
    // avatar image
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    // MARK - Setting messageBubbleTopLabel
    // messageBubbleTopLabel height
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        if messages.count == 0 {
            return 0.0
        }
        if messages[indexPath.item].senderId == senderId {
            return 8.0
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    // messageBubbleTopLabel text
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        if messages.count == 0 {
            return nil
        }
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    // MARK - Setting messageBubbleContainer
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: JSQMessagesCollectionViewCell = (super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell) {
            // Customize the shit out of this cell
            // See the docs for JSQMessagesCollectionViewCell
            let message = messages[indexPath.item]
            
            // cellTopLabel
            
            // messageBubbleTopLabel
            if message.senderId != senderId {
                cell.messageBubbleTopLabel.textColor = Style.Color.textNormal
            }
            
            // messageBubbleContainer
            if !message.isMediaMessage {
                cell.textView.isSelectable = false
                cell.textView.isUserInteractionEnabled = false
                if message.senderId == senderId {
                    cell.textView.textColor = Style.Color.textNormal
                }
            }
            
            // cellBottomLabel
            cell.cellBottomLabel.textColor = Style.Color.textNormal
            if message.senderId != senderId {
                if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .leading && $0.secondAttribute == .leading && ($0.firstItem === cell.cellBottomLabel || $0.secondItem === cell.cellBottomLabel)}.first) {
                    cell.subviews[0].removeConstraint(constraint)
                    cell.subviews[0].addConstraint(NSLayoutConstraint(item: cell.cellBottomLabel, attribute: .leading, relatedBy: .equal, toItem: cell.messageBubbleContainerView, attribute: .leading, multiplier: 1.0, constant: 8))
                    cell.layoutIfNeeded()
                    cell.cellBottomLabel.textAlignment = .left
                }
            }
            else {
                if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .trailing && $0.secondAttribute == .trailing && ($0.firstItem === cell.cellBottomLabel || $0.secondItem === cell.cellBottomLabel)}.first) {
                    cell.subviews[0].removeConstraint(constraint)
                    cell.subviews[0].addConstraint(NSLayoutConstraint(item: cell.cellBottomLabel, attribute: .trailing, relatedBy: .equal, toItem: cell.messageBubbleContainerView, attribute: .trailing, multiplier: 1.0, constant: -8))
                    cell.layoutIfNeeded()
                    cell.cellBottomLabel.textAlignment = .right
                }
            }
            return cell
        }
        else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    // messageBubbleContainer didTap
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        self.view.endEditing(true)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        self.view.endEditing(true)
        
    }
    
    // messageBubbleContainer setup show menu on long pressed
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        // Do the custom JSQM stuff
        super.collectionView(collectionView, shouldShowMenuForItemAt: indexPath)
        // And return true for all message types (we don't want the long press menu disabled for any message types)
        if messages.count == 0 {
            return false
        }
        return true
    }
    
    // messageBubbleContainer setup what action can see and can press on long pressed
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        if messages.count == 0 {
            return false
        }
        let message = messages[indexPath.row]
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            if message.isMediaMessage {
                return false
            }
            else {
                return true
            }
        }
        return false
    }
    
    // messageBubbleContainer setup action on pressed
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        
        let message = messages[indexPath.item]
        if action == #selector(copyMessage) {
            copyMessage(message: message)
        }
    }
    
    // MARK - Setting cellButtomLabel
    // cellBottomLabel height
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        if messages.count == 0 {
            return 0.0
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    // cellBottomLabel text
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        if messages.count == 0 {
            return nil
        }
        
        let message = messages[indexPath.item]

        return NSAttributedString(string: message.sendingTimeString)
    }
}

