//
//  DetailViewController.swift
//  Flicks
//
//  Created by randy_zhao on 5/16/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var trailerWebView: UIWebView!
    
    var movie: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)

        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"]
        overviewLabel.text = overview as? String
        
        overviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
            fetchImageAndFadeIn(posterImageView, imageUrl: largePosterUrl(posterPath), smallerImageUrl: smallPosterUrl(posterPath))
        }
        trailerWebView.allowsInlineMediaPlayback = true
        trailerWebView.mediaPlaybackRequiresUserAction = false
        
        
        trailerWebView.allowsInlineMediaPlayback = true
        trailerWebView.hidden = true
        NetworkHelper.fetchYoutubeLinks(
            String(self.movie["id"]!),
            successHandler: { (links: [String]) -> Void in
                if links.count > 0 { // TODO: only play first trailer now
                    let code: String = "<html><body><iframe width=\"320\" height=\"320\" src=\(links[0]) frameborder=\"0\" allowfullscreen></iframe></body></html>"
                    self.trailerWebView.hidden = false
                    self.trailerWebView.loadHTMLString(code, baseURL: NSBundle.mainBundle().bundleURL)
                }
                
            },
            failureHandler: { (error: NSError?) -> Void in }// TODO: add an error handler here
        )
        print(movie)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
