//
//  PhotoMediaItem.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 7/6/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class PhotoMediaItem: JSQPhotoMediaItem {
    
    var cachedPortraitImageView: UIImageView?
    var cachedLandscapeImageView: UIImageView?
    var cachedPortraitPlaceholderView: UIView?
    var cachedLandscapePlaceholderView: UIView?
    
    override func mediaViewDisplaySize() -> CGSize {
        var screenSize = UIScreen.main.bounds.width
        guard let image = image else {
            return CGSize(width: screenSize * 0.80, height: screenSize * 0.80)
        }
        
        if image.size.width >= image.size.height {
            screenSize = screenSize * 0.70
        }
        else {
            screenSize = screenSize * 0.50
        }
        let resizeFactor = image.size.width / screenSize
        
        return CGSize(width: image.size.width/resizeFactor, height: image.size.height/resizeFactor)
    }

    override func mediaView() -> UIView? {
        if image == nil {
            return nil
        }
        
        if image.size.width >= image.size.height {
            if cachedLandscapeImageView == nil {
                let size = self.mediaViewDisplaySize()
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero))
                if appliesMediaViewMaskAsOutgoing {
                    masker?.applyOutgoingBubbleImageMask(toMediaView: imageView)
                }
                else {
                    masker?.applyIncomingBubbleImageMask(toMediaView: imageView)
                }
                
                cachedLandscapeImageView = imageView
            }
            
            return cachedLandscapeImageView
        }
        else {
            if cachedPortraitImageView == nil {
                let size = self.mediaViewDisplaySize()
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero))
                if appliesMediaViewMaskAsOutgoing {
                    masker?.applyOutgoingBubbleImageMask(toMediaView: imageView)
                }
                else {
                    masker?.applyIncomingBubbleImageMask(toMediaView: imageView)
                }
                
                cachedPortraitImageView = imageView
            }
            
            return cachedPortraitImageView
        }
        
    }
    
//    override func mediaPlaceholderView() -> UIView! {
//        if cachedPlaceholderView == nil {
//            let size = mediaViewDisplaySize()
//            let view = JSQMessagesMediaPlaceholderView.withActivityIndicator()
//            view?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//            let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero))
//            if appliesMediaViewMaskAsOutgoing {
//                masker?.applyOutgoingBubbleImageMask(toMediaView: view)
//            }
//            else {
//                masker?.applyIncomingBubbleImageMask(toMediaView: view)
//            }
//            cachedPlaceholderView = view
//        }
//        
//        return cachedPlaceholderView
//    }
    
}
