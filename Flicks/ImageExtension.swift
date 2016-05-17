//
//  ViewControllerImageExtension.swift
//  Flicks
//
//  Created by randy_zhao on 5/17/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    public func fetchImageAndFadeIn(imageView: UIImageView!, imageUrl largeImageUrl: String, smallerImageUrl: String? = nil, duration: Double = 0.3) {
        var firstImageUrl: String?
        var secondImageUrl: String?
        if smallerImageUrl != nil{
            firstImageUrl = smallerImageUrl!
            secondImageUrl = largeImageUrl
        } else {
            firstImageUrl = largeImageUrl
        }
        imageView.setImageWithURLRequest(
            NSURLRequest(URL: NSURL(string: firstImageUrl!)!),
            placeholderImage:  nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                if imageResponse != nil {
                    imageView.alpha = 0.0
                    imageView.image = image
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        imageView.alpha = 1.0
                    }, completion: { (success) -> Void in
                        if secondImageUrl == nil { return }
                        
                        imageView.setImageWithURL(NSURL(string: secondImageUrl!)!)
                    })
                } else {
                    imageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // TODO: something here
            }
        )
    }
}