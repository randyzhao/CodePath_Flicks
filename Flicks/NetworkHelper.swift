//
//  NetworkHelper.swift
//  Flicks
//
//  Created by randy_zhao on 5/17/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import Foundation

class NetworkHelper {
    static let API_KEY: String = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    class func getRequestByEndpoint(endPoint: String) -> NSURLRequest {
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(API_KEY)&language=\(NSLocale.preferredLanguages()[0])")
        return NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
    }
    
    class func videosUrl(id: String) -> String {
        return "http://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(API_KEY)&language=\(NSLocale.preferredLanguages()[0])"
    }
    
    class func getVideosRequest(id: String) -> NSURLRequest {
        let url = NSURL(string: self.videosUrl(id))
        print(url)
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
    
    class func fetchYoutubeLinks(id: String, successHandler: ([String]) -> Void, failureHandler: (NSError?) -> Void) {
        networkRequest(
            getVideosRequest(id),
            successHandler: { (data) -> Void in
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                    if let results = responseDictionary["results"] as? [NSDictionary] {
                        var links: Array<String> = []
                        for result in results {
                            let site = result["site"] as? String
                            let key = result["key"] as? String
                            if site == "YouTube" && key != nil {
                                links.append("https://www.youtube.com/embed/\(key!)?autoplay=1&playsinline=1")
                            }
                        }
                        print(links)
                        successHandler(links)
                    }
                }
                failureHandler(nil) // TODO: return an error here
            },
            failureHandler: { (error: NSError?) -> Void in
                failureHandler(error)
            }
        )
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
