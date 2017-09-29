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
    var readRef: DatabaseReference!
    var messageRef: DatabaseReference!
    var messageQuery: DatabaseQuery!
    var newMessageRefHandle: DatabaseHandle?
    var newReadRefHandle: DatabaseHandle?
    var updateReadRefHandle: DatabaseHandle?
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
    var storageRef = Storage.storage().reference()
    let imageURLNotSetKey = "NOTSET"
    var photoMessageMap = [String: PhotoMediaItem]()
    var photoMessageMapCount = 0
    var photoMessageLoadedCount = 0
    var updatedMessageRefHandle: DatabaseHandle?
    var removedMessageRefHandle: DatabaseHandle?
    var updateThisUserBadgeRefHandle: DatabaseHandle?
    
    // Properties for gallery image preview
    var indexPathForSelectedMedia: IndexPath?
    var galleryViewController: GalleryViewController!
    var galleryFooterView: UIToolbar {
        let toolbar = UIToolbar()
        let saveBarButton = setUpBarbutton(image: UIImage(named: "ic_download")!, title: NSLocalizedString("Save", comment: ""), action: "gallerySavePressed")
        let shareBarButton = setUpBarbutton(image: UIImage(named: "ic_share")!, title: NSLocalizedString("Share", comment: ""), action: "gallerySharePressed")
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [space, saveBarButton, space, shareBarButton, space]
        toolbar.isTranslucent = true
        return toolbar
    }
    var galleryConfiguration: GalleryConfiguration = [
        .thumbnailsButtonMode(.none),
        .closeButtonMode(.builtIn),
        .hideDecorationViewsOnLaunch(true),
        .footerViewLayout(FooterLayout.pinBoth(0, 0, 0)),
        .deleteButtonMode(.none)
    ]
    
    // Properties Normal
    let defaults = UserDefaults.standard
    var sender: User!
    var messages: [Message] = []
    var messageKeys: [String] = []
    var members: [User] = []
    var userLastReadMessageIDs: [String: String] = [:]
    var thisUserLastReadMessageID: String = ""
    var firstTimeLastMessageIndex: Int = 0
    var lastDeleteMessageIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare JSQ data
        senderId = sender.uid
        senderDisplayName = sender.username
        
        // Prepare Firebase data
        chatroomRef = FBChatroom.getChatroomRef()
        readRef = chatroomRef.child(FBConstant.Chatroom.read)
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
//        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        // Setup input toolbar
        inputToolbar.contentView.textView.placeHolder = NSLocalizedString("Write a comment...", comment: "")
        inputToolbar.contentView.textView.tintColor = Style.Color.blue
        inputToolbar.contentView.rightBarButtonItem.setTitleColor(.white, for: .normal)
        
        if let leftButton = inputToolbar.contentView.leftBarButtonItem {
            let cameraImage = UIImage(named: "ic_camera")
            let normalCameraImage = cameraImage!.jsq_imageMasked(with: .white)
            let highlightedCameraImage = cameraImage!.jsq_imageMasked(with: Style.Color.lightGray)
            leftButton.imageView?.contentMode = .scaleAspectFit
            leftButton.setImage(normalCameraImage, for: .normal)
            leftButton.setImage(highlightedCameraImage, for: .highlighted)
        }
        
        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        // Check last read message
        readRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for userLastReadMessageSnapshot in snapshot.children {
                    if let userLastReadMessageSnapshot = userLastReadMessageSnapshot as? DataSnapshot {
                        if userLastReadMessageSnapshot.key == self.senderId {
                            self.thisUserLastReadMessageID = userLastReadMessageSnapshot.value as! String
                        }
                        else {
                            self.userLastReadMessageIDs[userLastReadMessageSnapshot.key] = userLastReadMessageSnapshot.value as? String ?? ""
                        }
                    }
                }
            }
            self.observeRead()
        })
        
        autoHideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateThisUserBadge()
        observeMessages()
        observeRead()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for refHandle in [newMessageRefHandle, updatedMessageRefHandle, removedMessageRefHandle] {
            if let refHandle = refHandle {
                messageRef.removeObserver(withHandle: refHandle)
            }
        }
        
        for refHandle in [newReadRefHandle, updateReadRefHandle] {
            if let refHandle = refHandle {
                readRef.removeObserver(withHandle: refHandle)
            }
        }
        
        if let refHandle = userIsTypingRefHandle {
            usersTypingQuery.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updateThisUserBadgeRefHandle {
            chatroomRef.child(FBConstant.Chatroom.user).removeObserver(withHandle: refHandle)
        }
    }
    
    private func updateBadge() {
//        chatroomRef.child(FBConstant.Chatroom.user).observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.childrenCount > 0 {
//                for chatroomUserSnapshot in snapshot.children {
//                    if let chatroomUserSnapshot = chatroomUserSnapshot as? DataSnapshot {
//                        if chatroomUserSnapshot.key != self.senderId {
//                            let chatroomUserBadge = chatroomUserSnapshot.value as! Int
//                            let chatroomUserBadgeUpdate = [chatroomUserSnapshot.key: chatroomUserBadge + 1]
//                            snapshot.ref.updateChildValues(chatroomUserBadgeUpdate)
//                            
//                            FBUser.getUserRef().child(chatroomUserSnapshot.key).child(FBConstant.User.badge).observeSingleEvent(of: .value, with: { (userBadgeSnapshot) in
//                                if let userBadgeSnapshotValue = userBadgeSnapshot.value as? [String: AnyObject] {
//                                    let messageBadge = userBadgeSnapshotValue[FBConstant.User.message] as! Int
//                                    let userBadgeUpdate = [FBConstant.User.message: messageBadge + 1]
//                                    userBadgeSnapshot.ref.updateChildValues(userBadgeUpdate)
//                                }
//                            })
//                        }
//                    }
//                }
//            }
//        })
    }
    
    private func updateThisUserBadge() {
//        updateThisUserBadgeRefHandle = chatroomRef.child(FBConstant.Chatroom.user).observe(.childChanged, with: { (snapshot) in
//            if snapshot.key == self.senderId {
//                let chatroomUserBadge = snapshot.value as! Int
//                if chatroomUserBadge > 0 {
//                    let chatroomUserBadgeUpdate = [snapshot.key: 0]
//                    self.chatroomRef.child(FBConstant.Chatroom.user).updateChildValues(chatroomUserBadgeUpdate)
//
//                    FBUser.getUserRef().child(snapshot.key).child(FBConstant.User.badge).observeSingleEvent(of: .value, with: { (userBadgeSnapshot) in
//                        if let userBadgeSnapshotValue = userBadgeSnapshot.value as? [String: AnyObject] {
//                            let messageBadge = userBadgeSnapshotValue[FBConstant.User.message] as! Int
//                            let newBadge = messageBadge - chatroomUserBadge
//                            let userBadgeUpdate = [FBConstant.User.message: newBadge >= 0 ? newBadge : 0]
//                            userBadgeSnapshot.ref.updateChildValues(userBadgeUpdate)
//                        }
//                    })
//                }
//            }
//        })
    }
    
    private func observeMessages() {
        if messages.count == 0 {
            messageQuery.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.childrenCount > 0 {
                    let lastFirstObserveChild = Int(snapshot.childrenCount)
                    if self.firstTimeLastMessageIndex == 0 {
                        self.firstTimeLastMessageIndex = lastFirstObserveChild-1
                    }
                    var currentChild = lastFirstObserveChild
                    for messageSnapshot in snapshot.children.reversed() {
                        currentChild -= 1
                        if let messageSnapshot = messageSnapshot as? DataSnapshot, let messageData = messageSnapshot.value as? [String: AnyObject] {
                            let isFirstMessageOfDate = messageData[FBConstant.Message.isFirstMessageOfDate] as? Bool ?? false
                            if let senderID = messageData[FBConstant.Message.senderID] as? String, let senderName = messageData[FBConstant.Message.senderName] as? String, let sendingTime = messageData[FBConstant.Message.sendingTime] as? String {
                                if let text = messageData[FBConstant.Message.text] as? String, text.characters.count > 0 {
                                    self.messages.insert(Message(id: messageSnapshot.key, senderID: senderID, displayName: senderName, text: text, sendingTime: Date(iso8601: sendingTime) ?? Date(), isFirstMessageOfDate: isFirstMessageOfDate), at: 0)
                                    self.messageKeys.append(messageSnapshot.key)
                                    print("TESTTEST \(messageSnapshot.key)")
                                    if currentChild == 0 {
                                        FBChatroom.updateChatroomUserRead(messageID: messageSnapshot.key)
                                        self.finishReceivingMessage()
                                        self.dismissIndicator(view: self.mainViewController.view)
                                        self.observeNewMessage()
                                    }
                                } else if let photoURL = messageData[FBConstant.Message.photoURL] as? String {
                                    if let mediaItem = PhotoMediaItem(maskAsOutgoing: senderID == self.senderId) {
                                        self.messages.insert(Message(id: messageSnapshot.key, senderID: senderID, displayName: senderName, media: mediaItem, photoURL: photoURL, sendingTime: Date(iso8601: sendingTime) ?? Date(), isFirstMessageOfDate: isFirstMessageOfDate), at: 0)
                                        self.messageKeys.append(messageSnapshot.key)
                                        if photoURL.hasPrefix("gs://") {
                                            self.photoMessageMap[messageSnapshot.key] = mediaItem
                                            self.photoMessageMapCount += 1
                                            self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: messageSnapshot.key)
                                        }
                                        
                                        if currentChild == 0 {
                                            FBChatroom.updateChatroomUserRead(messageID: messageSnapshot.key)
                                            self.finishReceivingMessage()
                                            self.dismissIndicator(view: self.mainViewController.view)
                                            self.observeNewMessage()
                                        }
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
                    // If not have message but have read remove read
                    if self.userLastReadMessageIDs.count > 0 {
                        FBChatroom.removeChatroomUserRead()
                    }
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
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            print("TESTTEST3")
            let key = snapshot.key
            let messageData = snapshot.value as! [String: AnyObject]
            
            if let photoURL = messageData[FBConstant.Message.photoURL] as! String! {
                print("TESTTEST3 \(photoURL)")
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                    for message in self.messages {
                        if message.id == key {
                            message.photoURL = photoURL
                        }
                    }
                }
            }
        })
        
        // observe remove message
        removedMessageRefHandle = messageRef.observe(.childRemoved, with: { (snapshot) in
            let removeMessageKey = snapshot.key
            if self.messageKeys.contains(removeMessageKey) {
                if let indexPath = self.lastDeleteMessageIndex {
                    self.messages.remove(at: indexPath.item)
                    if self.messages.count > 0 {
                        self.collectionView.deleteItems(at: [indexPath])
                    }
                    else {
                        self.collectionView.reloadData()
                        FBChatroom.removeChatroomUserRead()
                    }
                    self.lastDeleteMessageIndex = nil
                }
                else {
                    for i in 0..<self.messages.count {
                        let message = self.messages[i]
                        if message.id == removeMessageKey {
                            self.messages.remove(at: i)
                            if self.messages.count > 0 {
                                self.collectionView.deleteItems(at: [IndexPath.init(row: i, section: 0)])
                            }
                            else {
                                self.collectionView.reloadData()
                                FBChatroom.removeChatroomUserRead()
                                
                            }
                            break
                        }
                    }
                }
                self.messageKeys.remove(at: self.messageKeys.index(of: removeMessageKey)!)
            }
        })
        
    }
    
    private func observeNewMessage() {
        newMessageRefHandle = messageRef.observe(.childAdded, with: { (snapshot) in
            if !self.messageKeys.contains(snapshot.key) {
                if let messageData = snapshot.value as? [String: AnyObject] {
                    let isFirstMessageOfDate = messageData[FBConstant.Message.isFirstMessageOfDate] as? Bool ?? false
                    if let senderID = messageData[FBConstant.Message.senderID] as? String, let senderName = messageData[FBConstant.Message.senderName] as? String, let sendingTime = messageData[FBConstant.Message.sendingTime] as? String {
                        if let text = messageData[FBConstant.Message.text] as? String, text.characters.count > 0 {
                            self.messages.append(Message(id: snapshot.key, senderID: senderID, displayName: senderName, text: text, sendingTime: Date(iso8601: sendingTime) ?? Date(), isFirstMessageOfDate: isFirstMessageOfDate))
                            self.messageKeys.append(snapshot.key)
                            print("TESTTEST2 \(snapshot.key)")
                            FBChatroom.updateChatroomUserRead(messageID: snapshot.key)
                            self.finishReceivingMessage()
                        } else if let photoURL = messageData[FBConstant.Message.photoURL] as? String {
                            if let mediaItem = PhotoMediaItem(maskAsOutgoing: senderID == self.senderId) {
                                
                                self.messages.append(Message(id: snapshot.key, senderID: senderID, displayName: senderName, media: mediaItem, photoURL: photoURL, sendingTime: Date(iso8601: sendingTime) ?? Date(), isFirstMessageOfDate: isFirstMessageOfDate))
                                self.messageKeys.append(snapshot.key)
                                
                                if photoURL.hasPrefix("gs://") {
                                    self.photoMessageMap[snapshot.key] = mediaItem
                                    self.photoMessageMapCount += 1
                                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: snapshot.key)
                                } else if mediaItem.image == nil {
                                    self.photoMessageMap[snapshot.key] = mediaItem
                                    self.photoMessageMapCount += 1
                                }
                                
                                FBChatroom.updateChatroomUserRead(messageID: snapshot.key)
                                self.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
    }
    
    private func observeRead() {
        newReadRefHandle = readRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.key != self.senderId && self.userLastReadMessageIDs[snapshot.key] == nil {
                self.userLastReadMessageIDs[snapshot.key] = snapshot.value as? String
                self.collectionView.reloadData()
            }
        })
        
        updateReadRefHandle = readRef.observe(.childChanged, with: { (snapshot) in
            if snapshot.key != self.senderId {
                self.userLastReadMessageIDs[snapshot.key] = snapshot.value as? String
                self.collectionView.reloadData()
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
        
        var isFirstMessageOfDate = false
        if (messages.count > 0) {
            isFirstMessageOfDate = !Calendar.current.isDate(messages[messages.count-1].sendingTime, inSameDayAs: Date(iso8601: Date().iso8601DateString)!)
        }
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            FBConstant.Message.senderID: senderId,
            FBConstant.Message.senderName: senderDisplayName,
            FBConstant.Message.sendingTime: Date().iso8601DateString,
            FBConstant.Message.text: text,
            FBConstant.Message.isFirstMessageOfDate: isFirstMessageOfDate
            ] as [String : Any]
        
        itemRef.setValue(messageItem)
        updateBadge()
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let actionCamera = UIAlertAction(title: NSLocalizedString("Take photo", comment: ""), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.uploadImageCamera()
            })
            alert.addAction(actionCamera)
            
            let actionGallery = UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.uploadImageLibrary()
            })
            alert.addAction(actionGallery)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            self.uploadImageLibrary()
        }
    }
    
    // MARK: ChatViewController method private
    private func uploadImageCamera() {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera
            
            present(picker, animated: true, completion: nil)
        } else {
            // If device hasn't camera
            showNoCameraAlert()
        }
    }
    
    private func uploadImageLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        present(picker, animated: true, completion:nil)
    }
    
    func sendPhotoMessage() -> String? {
        var isFirstMessageOfDate = false
        if (messages.count > 0) {
            isFirstMessageOfDate = !Calendar.current.isDate(messages[messages.count-1].sendingTime, inSameDayAs: Date(iso8601: Date().iso8601DateString)!)
        }
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            FBConstant.Message.senderID: senderId!,
            FBConstant.Message.senderName: senderDisplayName!,
            FBConstant.Message.sendingTime: Date().iso8601DateString,
            FBConstant.Message.photoURL: imageURLNotSetKey,
            FBConstant.Message.isFirstMessageOfDate: isFirstMessageOfDate
            ] as [String : Any]
        
        itemRef.setValue(messageItem)
        updateBadge()
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, size: CGSize, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues([
            FBConstant.Message.photoURL: url,
            FBConstant.Message.height: "\(Int(size.height))",
            FBConstant.Message.width: "\(Int(size.width))"
            ])
    }
    
//    func getAvatar(_ uid: String) -> JSQMessagesAvatarImage {
//        for member in members {
//            if member.id == uid {
//                if let avatarImage = member.avatarImage {
//                    return avatarImage
//                }
//                break
//            }
//        }
//        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"ic_profile"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//    }
    
    func getRead(_ messageID: String) -> Int {
        var read = 0
        for userLastReadMessageID in userLastReadMessageIDs {
            if messageID <= userLastReadMessageID.value {
                read += 1
            }
        }
        return read
    }
    
    // function copy message
    func copyMessage(message: Message) {
        UIPasteboard.general.string = message.text
    }
    
    // function delete message
    func deleteMessage(message: Message, indexPath: IndexPath) {
        showYesNoAlert(
            title: NSLocalizedString("Delete message", comment: ""),
            message: NSLocalizedString("Are you sure you want to delete this message", comment: ""),
            positiveButtonText: nil,
            negativeButtonText: nil,
            positiveCompletion: { (_) in
                FBChatroom.removeMessage(message: message)
                self.lastDeleteMessageIndex = indexPath
        },
            negativeCompletion: nil
        )
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: PhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        storageRef.getData(maxSize: INT64_MAX) { data, error in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.getMetadata { metadata, metadataErr in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gifWithData(data!)
                } else {
                    mediaItem.image = UIImage(data: data!)
                }
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
                self.photoMessageMapCount -= 1
                self.photoMessageLoadedCount += 1
                if self.photoMessageLoadedCount % 5 == 0 || self.photoMessageMapCount <= 0 {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
//        if let viewController = segue.destination as? GroupMembersViewController {
//            viewController.members = members
//        }
    }
}

//
// MARK: Gallery view
//
extension ChatViewController {
    
    func gallerySharePressed() {
        guard let indexPath = indexPathForSelectedMedia, let messageMedia = messages[indexPath.item].media as? PhotoMediaItem, let image = messageMedia.image else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: [])
        galleryViewController.present(activityViewController, animated: true, completion: nil)
    }
    
    func gallerySavePressed() {
        guard let indexPath = indexPathForSelectedMedia, let messageMedia = messages[indexPath.item].media as? PhotoMediaItem, let image = messageMedia.image else {
            return
        }
        showIndicator(view: mainViewController.view, title: NSLocalizedString("Saving", comment: ""))
        PHPhotoLibrary.shared().savePhoto(image: image, albumName: "ParentsHero") { _ in
            self.dismissIndicator(view: self.mainViewController.view)
            self.galleryViewController.close()
        }
    }
    
    func setUpBarbutton(image: UIImage, title: String, action: String) -> UIBarButtonItem {
        let view = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(30), height: CGFloat(35)))
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        if action == "gallerySharePressed" {
            button.addTarget(target(forAction: #selector(gallerySharePressed), withSender: nil), action: #selector(gallerySharePressed), for: .touchUpInside)
        }
        else {
            button.addTarget(target(forAction: #selector(gallerySavePressed), withSender: nil), action: #selector(gallerySavePressed), for: .touchUpInside)
        }
        button.frame = CGRect(x: CGFloat(2), y: CGFloat(0), width: CGFloat(25), height: CGFloat(25))
        view.addSubview(button)
        let label = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(27), width: CGFloat(30), height: CGFloat(8)))
        label.font = Style.Font.chatGalleryFont
        label.text = title
        label.textAlignment = .center
        label.textColor = Style.Color.white
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        return UIBarButtonItem(customView: view)
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
        
        let message = messages[indexPath.item]
        if message.isFirstMessageOfDate {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    // cellTopLabel text
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        let message = messages[indexPath.item]
        if message.isFirstMessageOfDate {
            return NSAttributedString(string: message.sendingTime.localizedDateString)
        }
        
        return nil
    }
    
    // MARK - Setting avatar
    // avatar image
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
//        if messages.count == 0 {
//            return nil
//        }
//        
//        let message = messages[indexPath.row]
//        if message.senderId == senderId {
//            return nil
//        }
//        
//        return getAvatar(message.senderId)
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
            if message.isFirstMessageOfDate {
                cell.cellTopLabel.textColor = Style.Color.white
                cell.cellTopLabel.backgroundColor = Style.Color.black
                cell.cellTopLabel.alpha = 0.5
                cell.cellTopLabel.layer.cornerRadius = kJSQMessagesCollectionViewCellLabelHeightDefault/2
                
                if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .leading && $0.secondAttribute == .leading && ($0.firstItem === cell.cellTopLabel || $0.secondItem === cell.cellTopLabel)}.first) {
                    constraint.constant = cell.frame.width/3
                    cell.layoutIfNeeded()
                }
                if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .trailing && $0.secondAttribute == .trailing && ($0.firstItem === cell.cellTopLabel || $0.secondItem === cell.cellTopLabel)}.first) {
                    constraint.constant = cell.frame.width/3
                    cell.layoutIfNeeded()
                }
            }
            else {
                if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .top && $0.secondAttribute == .bottom && $0.firstItem === cell.messageBubbleTopLabel && $0.secondItem === cell.cellTopLabel}.first) {
                    constraint.constant = 0
                    cell.layoutIfNeeded()
                }
            }
            
            // messageAvatar
//            if message.senderId != senderId {
//                if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .top && $0.secondAttribute == .bottom && $0.firstItem === cell.cellBottomLabel && $0.secondItem === cell.avatarContainerView}.first) {
//                    cell.subviews[0].removeConstraint(constraint)
//                    cell.subviews[0].addConstraint(NSLayoutConstraint(item: cell.avatarContainerView, attribute: .top, relatedBy: .equal, toItem: cell.messageBubbleTopLabel, attribute: .top, multiplier: 1.0, constant: 7))
//                }
//            }
            
            // messageBubbleTopLabel
            if message.senderId != senderId {
                cell.messageBubbleTopLabel.textColor = Style.Color.textNormal
//                cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0, kJSQMessagesCollectionViewAvatarSizeDefault+8, 0, 0)
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
                let read = getRead(message.id)
                if read > 0 {
                    cell.cellBottomLabel.numberOfLines = 2
                }
                if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .trailing && $0.secondAttribute == .trailing && ($0.firstItem === cell.cellBottomLabel || $0.secondItem === cell.cellBottomLabel)}.first) {
                    cell.subviews[0].removeConstraint(constraint)
                    cell.subviews[0].addConstraint(NSLayoutConstraint(item: cell.cellBottomLabel, attribute: .trailing, relatedBy: .equal, toItem: cell.messageBubbleContainerView, attribute: .trailing, multiplier: 1.0, constant: -8))
                    cell.layoutIfNeeded()
                    cell.cellBottomLabel.textAlignment = .right
                }
            }
            // Unread add label
            //            if message.id == thisUserLastReadMessageID {
            //                if message.id != messages[firstTimeLastMessageIndex].id {
            //                    if cell.subviews[0].subviews.last === cell.cellBottomLabel {
            //                        let unreadLabel = UILabel(frame: CGRect(x: cell.frame.size.width/4, y: cell.cellBottomLabel.frame.origin.y, width: cell.frame.size.width/2, height: kJSQMessagesCollectionViewCellLabelHeightDefault))
            //                        unreadLabel.textColor = Style.Color.white
            //                        unreadLabel.textAlignment = .center
            //                        unreadLabel.font = cell.cellBottomLabel.font
            //                        unreadLabel.backgroundColor = Style.Color.black
            //                        unreadLabel.alpha = 0.5
            //                        unreadLabel.layer.masksToBounds = true
            //                        unreadLabel.layer.cornerRadius = kJSQMessagesCollectionViewCellLabelHeightDefault/2
            //                        cell.subviews[0].addSubview(unreadLabel)
            //                        cell.subviews[0].addConstraint(NSLayoutConstraint(item: unreadLabel, attribute: .bottom, relatedBy: .equal, toItem: cell.cellBottomLabel, attribute: .bottom, multiplier: 1.0, constant: 0))
            //                        cell.layoutIfNeeded()
            //                        unreadLabel.text = NSLocalizedString("Unread message below", comment: "")
            //                    }
            //                }
            //                else {
            //                    if let lastSubview = cell.subviews[0].subviews.last {
            //                        if lastSubview !== cell.cellBottomLabel {
            //                            lastSubview.removeFromSuperview()
            //                        }
            //                    }
            //                }
            //            }
            //            else {
            //                if let lastSubview = cell.subviews[0].subviews.last {
            //                    if lastSubview !== cell.cellBottomLabel {
            //                        lastSubview.removeFromSuperview()
            //                    }
            //                }
            //            }
            
            // Unread cellBottomLabel
            //            if message.id == thisUserLastReadMessageID {
            //                if message.id != messages[firstTimeLastMessageIndex].id {
            //                    cell.cellBottomLabel.textColor = Style.Color.white
            //                    cell.cellBottomLabel.backgroundColor = Style.Color.black
            //                    cell.cellBottomLabel.alpha = 0.5
            //                    cell.cellBottomLabel.layer.cornerRadius = kJSQMessagesCollectionViewCellLabelHeightDefault/2
            //                    cell.cellBottomLabel.textAlignment = .center
            //
            //                    if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .leading && $0.secondAttribute == .leading && ($0.firstItem === cell.cellBottomLabel || $0.secondItem === cell.cellBottomLabel)}.first) {
            //                        constraint.constant = cell.frame.width/4
            //                        cell.layoutIfNeeded()
            //                    }
            //                    if let constraint = (cell.subviews[0].constraints.filter{$0.firstAttribute == .trailing && $0.secondAttribute == .trailing && ($0.firstItem === cell.cellBottomLabel || $0.secondItem === cell.cellBottomLabel)}.first) {
            //                        constraint.constant = cell.frame.width/4
            //                        cell.layoutIfNeeded()
            //                    }
            //                }
            //            }
            
            
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
        
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            indexPathForSelectedMedia = indexPath
            galleryViewController = GalleryViewController(startIndex: 0, itemsDataSource: ChatGalleryDataSource(mediaMessage: message.media), configuration: galleryConfiguration)
            galleryViewController.footerView = galleryFooterView
            presentImageGallery(galleryViewController)
        }
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
        else if action == #selector(deleteMessage) {
            deleteMessage(message: message, indexPath: indexPath)
        }
    }
    
    // MARK - Setting cellButtomLabel
    // cellBottomLabel height
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        if messages.count == 0 {
            return 0.0
        }
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            let read = getRead(message.id)
            if read > 0 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault + 8
            }
        }
        
        // For unread buttom
        //        if message.id == thisUserLastReadMessageID {
        //            if message.id == messages[firstTimeLastMessageIndex].id {
        //                return 0.0
        //            }
        //            else {
        //                return kJSQMessagesCollectionViewCellLabelHeightDefault
        //            }
        //        }
        //        else {
        //            return 0.0
        //        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    // cellBottomLabel text
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        if messages.count == 0 {
            return nil
        }
        
        let message = messages[indexPath.item]
        var cellBottomLabelText = message.sendingTimeString
        if message.senderId == senderId {
            let read = getRead(message.id)
            if read > 0 {
                cellBottomLabelText = "\(cellBottomLabelText) \n\(NSLocalizedString("Read", comment: "")) \(read)"
            }
        }
        return NSAttributedString(string: cellBottomLabelText)
        
        // For unread message
        //        if message.id == thisUserLastReadMessageID {
        //            if message.id != messages[firstTimeLastMessageIndex].id {
        //                cellBottomLabelText = "\(NSLocalizedString("Unread message below", comment: "")) \(cellBottomLabelText)"
        //            }
        //        }
    }
    
}

//
// MARK: Image Picker Delegate
//
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        if let key = sendPhotoMessage() {
            let desiredPxWidthHeight: CGFloat = 1024
            let size: CGFloat = desiredPxWidthHeight / UIScreen.main.scale
            let resizedImage = image.resizedImageWithinRect(rectSize: CGSize(width: size, height: size))
            let imageData = UIImageJPEGRepresentation(resizedImage, 0.6)
            let imagePath = "chatroom/\(self.senderId!)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading photo: \(error)")
                    return
                }
                self.setImageURL(self.storageRef.child((metadata!.path)!).description, size: image.size,
                                 forPhotoMessageWithKey: key)
                if picker.sourceType == UIImagePickerControllerSourceType.camera {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
}


