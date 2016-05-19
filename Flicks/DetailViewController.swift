//
//  DetailViewController.swift
//  Flicks
//
//  Created by randy_zhao on 5/16/16.
//  Copyright © 2016 randy_zhao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dropbackImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var trailerWebView: UIWebView!
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var voteAverageLabel: UILabel!
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    @IBOutlet weak var detailsTableView: UITableView!
    
    @IBOutlet weak var castProfileImageView: UICollectionView!
    
    @IBAction func watchTrailerButtonClicked(sender: AnyObject) {
        if trailerLinks.count > 0 {
            let code: String = "<html><body><iframe width=\"320\" height=\"320\" src=\(trailerLinks[0]) frameborder=\"0\" allowfullscreen></iframe></body></html>"
            self.trailerWebView.hidden = false
            self.trailerWebView.loadHTMLString(code, baseURL: NSBundle.mainBundle().bundleURL)
        }

    }
    var movie: NSDictionary!
    
    var trailerLinks: Array<String> = []
    
    var details: Array<(String, String)> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"]
        overviewLabel.text = overview as? String
        
        //overviewLabel.sizeToFit()
        
        //if let posterPath = movie["poster_path"] as? String {
        if let backdropPath = movie["backdrop_path"] as? String {
            //fetchImageAndFadeIn(posterImageView, imageUrl: largePosterUrl(posterPath), smallerImageUrl: smallPosterUrl(posterPath))
            fetchImageAndFadeIn(dropbackImageView, imageUrl: largePosterUrl(backdropPath))
        }
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
                self.trailerLinks = links
                if links.count > 0 { // TODO: only play first trailer now
                    let code: String = "<html><body><iframe width=\"320\" height=\"320\" src=\(links[0]) frameborder=\"0\" allowfullscreen></iframe></body></html>"
                    //self.trailerWebView.hidden = false
                    self.trailerWebView.loadHTMLString(code, baseURL: NSBundle.mainBundle().bundleURL)
                }
                
            },
            failureHandler: { (error: NSError?) -> Void in }// TODO: add an error handler here
        )
        
        voteAverageLabel.text = "\(movie["vote_average"]!)/10"
        voteCountLabel.text = String(movie["vote_count"]! )
        
        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        
        NetworkHelper.networkRequest(
            NetworkHelper.urlRequestFromString("http://api.themoviedb.org/3/movie/" + String(movie["id"]!)),
            successHandler: {
                (data: NSData) -> Void in
                self.generateMovieDetails(data)
            },
            failureHandler: {
                (error: NSError?) -> Void in
                // TODO: something here
            }
        )
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailsTableView.frame.origin.y + detailsTableView.frame.size.height)
        
        print(movie)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateMovieDetails(data: NSData) -> Void {
        details = []
        if let rd = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
            if let releaseDate = rd["release_date"] as? String {
                let outputFormatter = NSDateFormatter()
                outputFormatter.dateFormat = "MMMM d, yyyy"
                
                let inputFormatter = NSDateFormatter()
                inputFormatter.dateFormat = "yyyy-MM-dd"
                
                let dateString = outputFormatter.stringFromDate(inputFormatter.dateFromString(releaseDate)!)
                details.append(("Release Date", dateString))
            }
            
            if let languageList = rd["spoken_languages"] as? NSArray {
                var languages: Array<String> = []
                for language in languageList {
                    languages.append(language["name"] as! String)
                }
                details.append(("Languages", languages.joinWithSeparator(", ")))
            }
            
            if let genreList = rd["genres"] as? NSArray {
                var genres: Array<String> = []
                for genre in genreList {
                    genres.append(genre["name"] as! String)
                }
                details.append(("Genres", genres.joinWithSeparator(", ")))
            }
        }
        detailsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailsTableViewCell", forIndexPath: indexPath) as! DetailsTableViewCell
        cell.setContent(details[indexPath.row].0, value: details[indexPath.row].1)
        return cell
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
