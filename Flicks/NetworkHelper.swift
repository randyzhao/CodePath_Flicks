//
//  NetworkHelper.swift
//  Flicks
//
//  Created by randy_zhao on 5/17/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import Foundation

class NetworkHelper {
    class func getRequestByEndpoint(endPoint: String) -> NSURLRequest {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)&language=\(NSLocale.preferredLanguages()[0])")
        return NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
    }
    
    class func networkRequest(request: NSURLRequest, successHandler: (NSData) -> Void, failureHandler: (NSError?) -> Void) {
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) {
            (dataOrNil, response, error) in
            if let data = dataOrNil {
                successHandler(data)
            } else {
                failureHandler(error)
            }
        }
        task.resume()
    }
    
    class func fetchMovies(request: NSURLRequest, successHandler: ([NSDictionary]) -> Void, failureHandler: (NSError?) -> Void) {
        self.networkRequest(request, successHandler: {
            (data: NSData) -> Void in
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                        if let movies = responseDictionary["results"] as? [NSDictionary] {
                            successHandler(movies)
                            return
                        }
                }
                failureHandler(nil)
        }, failureHandler: failureHandler)
    }
}
