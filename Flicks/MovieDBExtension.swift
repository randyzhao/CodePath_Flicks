//
//  MovieDBExtension.swift
//  Flicks
//
//  Created by randy_zhao on 5/17/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    public func largePosterUrl(posterPath: String) -> String {
        return "http://image.tmdb.org/t/p/w500" + posterPath
    }
    
    public func smallPosterUrl(posterPath: String) -> String {
        return "http://image.tmdb.org/t/p/w92" + posterPath
    }
}