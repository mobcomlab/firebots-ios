//
//  ChatGalleryDataSource.swift
//  ParentsHero
//
//  Created by Ant on 26/01/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import ImageViewer
import JSQMessagesViewController

class ChatGalleryDataSource: GalleryItemsDataSource {
    
    let mediaMessages: [JSQMessageMediaData]
    
    init(mediaMessages: [JSQMessageMediaData]) {
        self.mediaMessages = mediaMessages
    }
    
    convenience init(mediaMessage: JSQMessageMediaData) {
        self.init(mediaMessages: [mediaMessage])
    }
    
    func itemCount() -> Int {
        return mediaMessages.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let mediaMessage = mediaMessages[index]
        
        if let imageMediaMessage = mediaMessage as? PhotoMediaItem {
            return .image(fetchImageBlock: { (completion) in
                completion(imageMediaMessage.image)
            })
        }
        return .image(fetchImageBlock: { completion in completion(nil) })
    }
    
}
