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
    
    public func fetchImageAndFadeIn(imageView: UIImageView!, imageUrl: String, duration: Double = 0.3) {
        let imageRequest = NSURLRequest(URL: NSURL(string: imageUrl)!)
        imageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage:  nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                if imageResponse != nil {
                    imageView.alpha = 0.0
                    imageView.image = image
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        imageView.alpha = 1.0
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